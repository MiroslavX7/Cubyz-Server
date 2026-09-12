const std = @import("std");

const root = @import("root");
const Array3D = root.utils.Array3D;
const NeverFailingAllocator = root.heap.NeverFailingAllocator;
const sdf = root.server.terrain.sdf;
const SdfInstance = sdf.SdfInstance;
const vec = root.vec;
const Vec2f = vec.Vec2f;
const Vec2i = vec.Vec2i;
const Vec3f = vec.Vec3f;
const Vec3i = vec.Vec3i;
const ZonElement = root.ZonElement;

pub const id = "cubyz:cylinder";

minRadius: f32,
maxRadius: f32,
minHalfHeight: f32,
maxHalfHeight: f32,

const Instance = struct {
	radius: f32,
	halfHeight: f32,
};

pub fn initAndGetExtend(zon: ZonElement) sdf.SdfModel.InitResult {
	const self = root.worldArena.create(@This());
	self.minRadius = zon.get(f32, "minRadius") orelse 16;
	self.maxRadius = zon.get(f32, "maxRadius") orelse self.minRadius;
	self.minHalfHeight = (zon.get(f32, "minHeight") orelse 32)/2;
	self.maxHalfHeight = (zon.get(f32, "maxfHeight") orelse self.minHalfHeight*2)/2;

	return .{.model = self, .maxExtend = .{
		.min = .{@floor(-self.maxRadius), @floor(-self.maxRadius), @floor(-self.maxHalfHeight)},
		.max = .{@ceil(self.maxRadius), @ceil(self.maxRadius), @ceil(self.maxHalfHeight)},
	}};
}

pub fn instantiate(self: *@This(), arena: NeverFailingAllocator, seed: *u64) SdfInstance {
	const instance = arena.create(Instance);
	instance.* = .{
		.radius = self.minRadius + (self.maxRadius - self.minRadius)*root.random.nextFloat(seed),
		.halfHeight = self.minHalfHeight + (self.maxHalfHeight - self.minHalfHeight)*root.random.nextFloat(seed),
	};
	const bounds: Vec3f = .{instance.radius, instance.radius, instance.halfHeight};
	return .{
		.data = instance,
		.generateFn = root.meta.castFunctionSelfToAnyopaque(generate),
		.minBounds = @floor(-bounds),
		.maxBounds = @ceil(bounds),
		.centerPosOffset = @ceil(bounds),
	};
}

pub fn generate(self: *Instance, samplePos: Vec3f) f32 {
	const circleSdf: f32 = vec.length(vec.xy(samplePos)) - self.radius;
	const heightSdf: f32 = @abs(samplePos[2]) - self.halfHeight;
	return vec.length(@max(Vec2f{heightSdf, circleSdf}, Vec2f{0, 0})) + @min(0, @max(circleSdf, heightSdf));
}
