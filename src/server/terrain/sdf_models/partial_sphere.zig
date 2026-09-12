const std = @import("std");

const root = @import("root");
const Array3D = root.utils.Array3D;
const NeverFailingAllocator = root.heap.NeverFailingAllocator;
const sdf = root.server.terrain.sdf;
const SdfInstance = sdf.SdfInstance;
const vec = root.vec;
const Vec3f = vec.Vec3f;
const Vec3i = vec.Vec3i;
const ZonElement = root.ZonElement;

pub const id = "cubyz:partial_sphere";

minRadius: f32,
maxRadius: f32,
cutPercentage: f32,
cutDirection: Vec3f,
cutDirectionRandomness: f32,

const Instance = struct {
	radius: f32,
	cutPercentage: f32,
	cutDirection: Vec3f,
};

pub fn initAndGetExtend(zon: ZonElement) sdf.SdfModel.InitResult {
	const self = root.worldArena.create(@This());
	self.minRadius = zon.get(f32, "minRadius") orelse 16;
	self.maxRadius = zon.get(f32, "maxRadius") orelse self.minRadius;
	self.cutPercentage = zon.get(f32, "cutPercentage") orelse 0.5;
	self.cutDirection = vec.normalize(zon.get(Vec3f, "cutDirection") orelse .{0, 0, -1});
	self.cutDirectionRandomness = zon.get(f32, "cutDirectionRandomness") orelse 0;

	return .{.model = self, .maxExtend = .{
		.min = @splat(@floor(-self.maxRadius)),
		.max = @splat(@ceil(self.maxRadius)),
	}};
}

pub fn instantiate(self: *@This(), arena: NeverFailingAllocator, seed: *u64) SdfInstance {
	const instance = arena.create(Instance);
	instance.* = .{
		.radius = self.minRadius + (self.maxRadius - self.minRadius)*root.random.nextFloat(seed),
		.cutDirection = vec.normalize(self.cutDirection + root.random.nextFloatVectorSigned(3, seed)*@as(Vec3f, @splat(self.cutDirectionRandomness))),
		.cutPercentage = self.cutPercentage,
	};
	const bounds: Vec3f = @splat(instance.radius);
	const offset: Vec3f = instance.cutDirection*@as(Vec3f, @splat(self.cutPercentage/2*instance.radius));
	return .{
		.data = instance,
		.generateFn = root.meta.castFunctionSelfToAnyopaque(generate),
		.minBounds = @floor(-bounds + offset),
		.maxBounds = @ceil(bounds + offset),
		.centerPosOffset = @ceil(bounds),
	};
}

pub fn generate(self: *Instance, samplePos: Vec3f) f32 {
	const sphereSdf = vec.length(samplePos) - self.radius;
	const planeSdf = vec.dot(self.cutDirection, samplePos) - self.radius + self.cutPercentage*self.radius*2;
	return sdf.intersection(sphereSdf, planeSdf);
}
