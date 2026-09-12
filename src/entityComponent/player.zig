const std = @import("std");

const root = @import("root");
const chunk = root.chunk;
const Entity = root.entity.Entity;
const game = root.game;
const graphics = root.graphics;
const c = graphics.c;
const ZonElement = root.ZonElement;
const renderer = root.renderer;
const settings = root.settings;
const utils = root.utils;
const vec = root.vec;
const Mat4f = vec.Mat4f;
const Vec3d = vec.Vec3d;
const Vec3f = vec.Vec3f;
const Vec4f = vec.Vec4f;
const NeverFailingAllocator = root.heap.NeverFailingAllocator;

const BinaryReader = root.utils.BinaryReader;

pub var entityComponentID: root.entity.EntityComponentId = undefined;
pub const entityComponentVersion = 0;

// ############################# Client only stuff ################################
pub const client = struct {
	const Component = struct {
		playerIndex: u32,
	};
	pub var components: root.utils.SparseSet(Component, Entity) = .{};

	pub fn init() void {}
	pub fn deinit() void {
		components.deinit(root.globalAllocator);
	}
	pub fn clear() void {
		components.clear();
	}
	pub fn load(entity: Entity, reader: *utils.BinaryReader, version: u32) root.entity.EntityComponentLoadError!void {
		if (version != 0) return error.InvalidComponentVersion;
		const playerIndex = reader.readVarInt(u32) catch return error.UnreadableComponentData;

		const ptr = components.get(entity) orelse components.add(root.globalAllocator, entity);
		ptr.* = Component{
			.playerIndex = playerIndex,
		};
	}
	pub fn unload(entity: Entity) void {
		components.remove(entity) catch {};
	}
	pub fn get(entity: Entity) ?*Component {
		return components.get(entity);
	}
};

// ############################# Server only stuff ################################

pub const server = struct {
	pub const Component = struct {
		playerIndex: u32, // model
		pub fn save(self: Component, writer: *utils.BinaryWriter, audience: root.entity.AudienceInfo) root.entity.ComponentSaveBehaviour {
			writer.writeVarInt(u32, self.playerIndex);
			if (audience == .disk) return .discard;
			return .save;
		}
	};
	var components: root.utils.SparseSet(Component, Entity) = undefined;
	pub fn init() void {
		components = .{};
	}
	pub fn deinit() void {
		components.deinit(root.globalAllocator);
	}
	pub fn loadFromData(entity: Entity, reader: *utils.BinaryReader, version: u32) root.entity.EntityComponentLoadError!void {
		if (version != 0) return error.InvalidComponentVersion;
		const playerIndex = reader.readVarInt(u32) catch return error.UnreadableComponentData;

		load(entity, playerIndex);
	}
	pub fn load(entity: Entity, playerIndex: u32) void {
		put(entity, Component{
			.playerIndex = playerIndex,
		});
	}
	pub fn unload(entity: Entity) void {
		components.remove(entity) catch {};
	}
	pub fn put(entity: Entity, renderComponent: Component) void {
		const ptr = components.get(entity) orelse components.add(root.globalAllocator, entity);
		ptr.* = renderComponent;
	}
	pub fn get(entity: Entity) ?*Component {
		return components.get(entity);
	}
};
