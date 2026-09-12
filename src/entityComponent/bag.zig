const std = @import("std");

const root = @import("root");
const chunk = main.chunk;
const Entity = root.entity.Entity;
const ServerChunk = chunk.ServerChunk;
const game = main.game;
const graphics = main.graphics;
const ZonElement = main.ZonElement;
const renderer = main.renderer;
const settings = main.settings;
const utils = main.utils;
const BinaryReader = utils.BinaryReader;
const BinaryWriter = utils.BinaryWriter;
const vec = main.vec;
const Mat4f = vec.Mat4f;
const Vec3d = vec.Vec3d;
const Vec3f = vec.Vec3f;
const Vec4f = vec.Vec4f;
const Vec3i = vec.Vec3i;
const NeverFailingAllocator = root.heap.NeverFailingAllocator;
const blocks = main.blocks;
const World = game.World;
const ServerWorld = root.server.ServerWorld;
const items = main.items;
const ItemStack = items.ItemStack;
const random = main.random;

const c = @import("c");

pub var entityComponentID: root.entity.EntityComponentId = undefined;
pub const entityComponentVersion = 0;

const playerBagSizeLimit = 120;

// ############################# Client only stuff ################################
pub const client = struct {
	const Component = struct {
		bag: items.Inventory.BagInventory,
	};
	pub var components: root.utils.SparseSet(Component, Entity) = .{};

	pub fn init() void {}
	pub fn deinit() void {
		components.deinit(root.globalAllocator);
	}
	pub fn clear() void {
		components.clear();
	}

	pub fn getBag(entity: Entity) ?*items.Inventory.BagInventory {
		return &(components.get(entity) orelse return null).bag;
	}

	pub fn load(entity: Entity, reader: *utils.BinaryReader, version: u32) root.entity.EntityComponentLoadError!void {
		if (version != entityComponentVersion) return error.InvalidComponentVersion;
		const bag = &components.add(root.globalAllocator, entity).bag;
		bag.* = .init(root.globalAllocator, playerBagSizeLimit);
		bag.fromBytes(reader) catch return error.UnreadableComponentData;
	}
	pub fn unload(entity: Entity) void {
		const bag = components.fetchRemove(entity) catch return;
		bag.bag.deinit();
	}
};

// ############################# Server only stuff ################################
pub const server = struct {
	pub const Component = struct {
		bag: items.Inventory.BagInventory,
		pub fn save(self: Component, writer: *utils.BinaryWriter, audience: root.entity.AudienceInfo) root.entity.ComponentSaveBehaviour {
			if (audience != .disk and audience != .playerHimself) return .discard;
			self.bag.toBytes(writer);
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
	pub fn getBag(entity: Entity) ?*items.Inventory.BagInventory {
		return &(components.get(entity) orelse return null).bag;
	}
	pub fn loadFromData(entity: Entity, reader: *utils.BinaryReader, version: u32) root.entity.EntityComponentLoadError!void {
		if (version != entityComponentVersion) return error.InvalidComponentVersion;
		const bag = &components.add(root.globalAllocator, entity).bag;
		bag.* = .init(root.globalAllocator, playerBagSizeLimit);
		bag.fromBytes(reader) catch return error.UnreadableComponentData;
	}
	pub fn loadEmpty(entity: Entity) void {
		const bag = &components.add(root.globalAllocator, entity).bag;
		bag.* = .init(root.globalAllocator, playerBagSizeLimit);
	}
	pub fn unload(entity: Entity) void {
		const bag = components.fetchRemove(entity) catch return;
		bag.bag.deinit();
	}
};
