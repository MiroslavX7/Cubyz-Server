const std = @import("std");

const root = @import("root");
const Entity = root.entity.Entity;
const utils = root.utils;
const BinaryReader = utils.BinaryReader;
const BinaryWriter = utils.BinaryWriter;
const NeverFailingAllocator = root.heap.NeverFailingAllocator;

pub var entityComponentID: root.entity.EntityComponentId = undefined;
pub const entityComponentVersion = 0;

// ############################# Client only stuff ################################
pub const client = struct {
	pub fn load(entity: Entity, reader: *BinaryReader, version: u32) root.entity.EntityComponentLoadError!void {
		_ = entity;
		_ = reader;
		_ = version;
	}
	pub fn unload(entity: Entity) void {
		_ = entity;
	}
	pub fn init() void {}
	pub fn deinit() void {}
	pub fn clear() void {}
};
// ############################# Server only stuff ################################
pub const server = struct {
	pub const Component = struct {
		permissions: root.server.permission.Permissions,
		permissionGroups: std.AutoHashMapUnmanaged(root.server.permission.Group, void),

		pub fn save(self: Component, writer: *BinaryWriter, audience: root.entity.AudienceInfo) root.entity.ComponentSaveBehaviour {
			if (audience != .disk) return .discard;
			self.permissions.toBytes(writer);

			writer.writeVarInt(usize, self.permissionGroups.count());
			var it = self.permissionGroups.keyIterator();
			while (it.next()) |group| {
				group.toBytes(writer);
			}
			return .save;
		}
	};
	pub var components: root.utils.SparseSet(Component, Entity) = .{};

	pub fn init() void {
		components = .{};
	}

	pub fn deinit() void {
		components.deinit(root.globalAllocator);
	}

	pub fn get(entity: Entity) ?Component {
		return (components.get(entity) orelse return null).*;
	}

	pub fn getPermissions(entity: Entity) ?*root.server.permission.Permissions {
		return &(components.get(entity) orelse return null).permissions;
	}

	pub fn getPermissionGroups(entity: Entity) ?*std.AutoHashMapUnmanaged(root.server.permission.Group, void) {
		return &(components.get(entity) orelse return null).permissionGroups;
	}

	pub fn hasPermission(entity: Entity, permissionPath: []const u8) bool {
		switch ((getPermissions(entity) orelse return false).hasPermission(permissionPath)) {
			.yes => return true,
			.no => return false,
			.neutral => {},
		}
		var groupIt = (getPermissionGroups(entity).?).keyIterator();
		while (groupIt.next()) |group| {
			const result = group.hasPermission(permissionPath) catch blk: {
				std.debug.assert(removeFromGroup(entity, group.*) == true);
				break :blk .no;
			};
			if (result == .yes) return true;
		}
		return false;
	}

	pub fn addPermission(entity: Entity, listType: root.server.permission.Permissions.ListType, permissionPath: []const u8) void {
		(getPermissions(entity) orelse return).addPermission(listType, permissionPath);
	}

	pub fn removePermission(entity: Entity, listType: root.server.permission.Permissions.ListType, permissionPath: []const u8) bool {
		return (getPermissions(entity) orelse return false).removePermission(listType, permissionPath);
	}

	pub fn addToGroup(entity: Entity, group: root.server.permission.Group) void {
		(getPermissionGroups(entity) orelse return).put(root.globalAllocator.allocator, group, {}) catch unreachable;
	}

	pub fn removeFromGroup(entity: Entity, group: root.server.permission.Group) bool {
		return getPermissionGroups(entity).?.remove(group);
	}

	pub fn loadFromData(entity: Entity, reader: *BinaryReader, version: u32) root.entity.EntityComponentLoadError!void {
		if (version != entityComponentVersion) return error.InvalidComponentVersion;
		const component = components.add(root.globalAllocator, entity);
		component.permissions = .init(root.globalAllocator);
		component.permissions.fromBytes(reader) catch return error.UnreadableComponentData;
		component.permissionGroups = .empty;
		const len = reader.readVarInt(usize) catch return;
		for (0..len) |_| {
			const group = root.server.permission.Group.fromBytes(reader) catch |err| {
				if (err == error.GroupNotFound) continue; // if the group is not found we just skip it.
				return error.UnreadableComponentData;
			};
			addToGroup(entity, group);
		}
	}

	pub fn loadEmpty(entity: Entity) void {
		const component = components.add(root.globalAllocator, entity);
		component.permissions = .init(root.globalAllocator);
		component.permissionGroups = .empty;
	}

	pub fn unload(entity: Entity) void {
		var component = components.fetchRemove(entity) catch return;
		component.permissions.deinit();
		component.permissionGroups.deinit(root.globalAllocator.allocator);
	}
};
