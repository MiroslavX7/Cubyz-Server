const std = @import("std");

const root = @import("root");
const chunk = root.chunk;
const ServerChunk = chunk.ServerChunk;
const game = root.game;
const graphics = root.graphics;
const ZonElement = root.ZonElement;
const renderer = root.renderer;
const settings = root.settings;
const utils = root.utils;
const BinaryReader = utils.BinaryReader;
const BinaryWriter = utils.BinaryWriter;
const vec = root.vec;
const Mat4f = vec.Mat4f;
const Vec3d = vec.Vec3d;
const Vec3f = vec.Vec3f;
const Vec4f = vec.Vec4f;
const Vec3i = vec.Vec3i;
const NeverFailingAllocator = root.heap.NeverFailingAllocator;
const blocks = root.blocks;
const World = game.World;
const ServerWorld = root.server.ServerWorld;
const items = root.items;
const ItemStack = items.ItemStack;
const random = root.random;

const c = @import("c");

const entityComponent = root.entityComponent;

// ############################# Client only stuff ################################
pub const client = struct {
	pub fn init() void {}
	pub fn deinit() void {}
	pub fn clear() void {}

	pub fn render(ambientLight: Vec3f, playerPos: Vec3d, deltaTime: f64) void {
		_ = ambientLight;
		_ = playerPos;
		_ = deltaTime;
	}
	pub fn renderHud(ambientLight: Vec3f, playerPos: Vec3d) void {
		_ = ambientLight;
		_ = playerPos;
	}
};
// ############################# Server only stuff ################################
pub const server = struct {
	pub fn init() void {}
	pub fn deinit() void {}

	pub fn update() void {}
};
