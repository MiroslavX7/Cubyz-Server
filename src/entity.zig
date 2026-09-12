const std = @import("std");
const main = @import("main.zig");
const vec = main.vec;
const Mat4f = vec.Mat4f;
const Vec3d = vec.Vec3d;
const Vec3f = vec.Vec3f;
const Vec4f = vec.Vec4f;

pub const components = @import("entityComponent/_list.zig");

pub const EntityNetworkData = struct {
	id: root.entity.Entity,
	pos: Vec3d,
	vel: Vec3d,
	rot: Vec3f,
};

pub const EntityComponentLoadError = error{
	DecodingBase64,
	UnreadableId,
	UnreadableVersion,
	UnreadableComponentData,
	UnknownComponentId,
	InvalidComponentVersion,
};
pub const Entity = enum(u32) {
	noValue = std.math.maxInt(u32),
	_,
};
pub const EntityComponentId = u32;
const EntityComponentVTable = struct {
	serverLoad: *const fn (entity: Entity, reader: *root.utils.BinaryReader, version: u32) EntityComponentLoadError!void,
	clientLoad: *const fn (entity: Entity, reader: *root.utils.BinaryReader, version: u32) EntityComponentLoadError!void,
	serverUnload: *const fn (entity: Entity) void,
	clientUnload: *const fn (entity: Entity) void,
};
var componentList: []?EntityComponentVTable = undefined;

pub fn initComponents() void {
	var tmpComponentList: main.List(?EntityComponentVTable) = .empty;
	inline for (@typeInfo(components).@"struct".decls) |decl| {
		@field(components, decl.name).client.init();
		const componentId = @field(components, decl.name).entityComponentID;

		if (tmpComponentList.items.len <= componentId) {
			tmpComponentList.appendNTimes(root.worldArena, null, componentId + 1 - tmpComponentList.items.len);
		}
		if (tmpComponentList.items[componentId] == null) {
			tmpComponentList.items[componentId] = .{
				.serverLoad = @field(components, decl.name).server.loadFromData,
				.clientLoad = @field(components, decl.name).client.load,
				.serverUnload = @field(components, decl.name).server.unload,
				.clientUnload = @field(components, decl.name).client.unload,
			};
		} else {
			std.log.err("entity components: Duplicate list id {}.", .{componentId});
		}
	}
	componentList = tmpComponentList.items;
}
pub fn deinitComponents() void {
	componentList = undefined;
}
pub fn loadComponent(comptime side: root.sync.Side, componentId: EntityComponentId, entity: Entity, componentData: []const u8, componentVersion: u32) EntityComponentLoadError!void {
	if (componentId >= componentList.len) {
		std.log.err("unknown Component Id {} ", .{componentId});
		return error.UnknownComponentId;
	}
	var componentReader = root.utils.BinaryReader.init(componentData);
	if (componentList[componentId]) |vtable| {
		switch (side) {
			.server => vtable.serverLoad(entity, &componentReader, componentVersion) catch |err| {
				return err;
			},
			.client => vtable.clientLoad(entity, &componentReader, componentVersion) catch |err| {
				return err;
			},
		}
	} else {
		std.log.err("unknown Component Id {} ", .{componentId});
		return error.UnknownComponentId;
	}
}
pub fn unloadComponent(comptime side: root.sync.Side, componentId: EntityComponentId, entity: Entity) EntityComponentLoadError!void {
	if (componentId >= componentList.len) {
		std.log.err("unknown Component Id {} ", .{componentId});
		return error.UnknownComponentId;
	}
	if (componentList[componentId]) |vtable| {
		switch (side) {
			.server => vtable.serverUnload(entity),
			.client => vtable.clientUnload(entity),
		}
	} else {
		std.log.err("unknown Component Id {} ", .{componentId});
		return error.UnknownComponentId;
	}
}

pub const client = struct {
	pub fn init() void {
		inline for (@typeInfo(components).@"struct".decls) |decl| {
			@field(components, decl.name).client.init();
		}
		root.client.entity_manager.init();
	}
	pub fn deinit() void {
		root.client.entity_manager.deinit();
		inline for (@typeInfo(components).@"struct".decls) |decl| {
			@field(components, decl.name).client.deinit();
		}
	}
	pub fn clear() void {
		root.client.entity_manager.clear();
		inline for (@typeInfo(components).@"struct".decls) |decl| {
			@field(components, decl.name).client.clear();
		}
	}
	pub fn removeAllComponents(entity: Entity) void {
		const list = root.entity.components;
		inline for (@typeInfo(list).@"struct".decls) |decl| {
			@field(list, decl.name).client.unload(entity);
		}
	}
};
pub const server = struct {
	pub fn init() void {
		inline for (@typeInfo(components).@"struct".decls) |decl| {
			@field(components, decl.name).server.init();
		}
	}
	pub fn deinit() void {
		inline for (@typeInfo(components).@"struct".decls) |decl| {
			@field(components, decl.name).server.deinit();
		}
	}
	pub fn componentsToBase64(allocator: root.heap.NeverFailingAllocator, entity: Entity, audience: root.entity.AudienceInfo) root.utils.Base64 {
		var writer = root.utils.BinaryWriter.init(root.stackAllocator);
		defer writer.deinit();

		inline for (@typeInfo(root.entity.components).@"struct".decls) |decl| {
			if (@field(root.entity.components, decl.name).server.get(entity)) |component| {
				var writerComponent = root.utils.BinaryWriter.init(root.stackAllocator);
				defer writerComponent.deinit();

				if (component.save(&writerComponent, audience) == .save) {
					writer.writeVarInt(u32, @field(root.entity.components, decl.name).entityComponentID);
					writer.writeVarInt(u32, @field(root.entity.components, decl.name).entityComponentVersion);
					writer.writeSliceWithSize(writerComponent.data.items);
				}
			}
		}
		return root.utils.Base64.toBase64(allocator, writer.data.items);
	}

	pub fn removeAllComponents(entity: Entity) void {
		const list = root.entity.components;
		inline for (@typeInfo(list).@"struct".decls) |decl| {
			@field(list, decl.name).server.unload(entity);
		}
	}

	pub fn transmitChange(EntityComponent: type, entity: Entity) void {
		var binaryWriter = root.utils.BinaryWriter.init(root.stackAllocator);
		defer binaryWriter.deinit();

		const users = root.server.getUserList(root.stackAllocator);
		defer root.stackAllocator.free(users);

		if (EntityComponent.server.get(entity)) |ptr| {
			if (ptr.save(&binaryWriter, .playerNearby) == .save) {
				for (users) |user| {
					root.network.protocols.EntityComponentUpdate.load(user.conn, entity, EntityComponent.entityComponentID, EntityComponent.entityComponentVersion, binaryWriter.data.items);
				}
			}
		} else {
			for (users) |user| {
				root.network.protocols.EntityComponentUpdate.unload(user.conn, entity, EntityComponent.entityComponentID);
			}
		}
	}
};

pub fn loadComponentsFromBase64(base64Data: []const u8, entity: Entity, comptime side: root.sync.Side) EntityComponentLoadError!void {
	const data = root.utils.fromBase64(root.stackAllocator, base64Data) catch return EntityComponentLoadError.DecodingBase64;
	defer root.stackAllocator.free(data);

	var reader = root.utils.BinaryReader.init(data);
	var lastError: EntityComponentLoadError!void = {};
	while (reader.remaining.len != 0) {
		const componentId: EntityComponentId = reader.readVarInt(EntityComponentId) catch return EntityComponentLoadError.UnreadableId;
		const componentVersion: u32 = reader.readVarInt(u32) catch return EntityComponentLoadError.UnreadableVersion;
		const componentData = reader.readSliceWithSize() catch return EntityComponentLoadError.UnreadableComponentData;

		lastError = loadComponent(side, componentId, entity, componentData, componentVersion);
	}
	return lastError;
}

// Depending on who the audience is, we want to serialize different informations.
pub const AudienceInfo = enum {
	disk,
	playerHimself,
	playerNearby,
	playerFaraway,
};

pub const ComponentSaveBehaviour = enum {
	save,
	discard,
};
