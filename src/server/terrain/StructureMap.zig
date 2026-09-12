const std = @import("std");
const Atomic = std.atomic.Value;

const root = @import("root");
const ServerChunk = root.chunk.ServerChunk;
const ChunkPosition = root.chunk.ChunkPosition;
const Cache = root.utils.Cache;
const ZonElement = root.ZonElement;
const NeverFailingAllocator = root.heap.NeverFailingAllocator;
const vec = root.vec;
const Vec3i = vec.Vec3i;

const terrain = @import("terrain.zig");
const GeneratorState = terrain.GeneratorState;
const TerrainGenerationProfile = terrain.TerrainGenerationProfile;

pub const structure_map_generators = @import("structuremapgen/_list.zig");

const StructureInternal = struct {
	generateFn: *const fn (self: *const anyopaque, chunk: *ServerChunk, caveMap: terrain.CaveMap.CaveMapView, biomeMap: terrain.CaveBiomeMap.CaveBiomeMapView) void,
	data: *const anyopaque,

	pub fn generate(self: StructureInternal, chunk: *ServerChunk, caveMap: terrain.CaveMap.CaveMapView, biomeMap: terrain.CaveBiomeMap.CaveBiomeMapView) void {
		self.generateFn(self.data, chunk, caveMap, biomeMap);
	}
};

pub const Structure = struct {
	internal: StructureInternal,
	priority: f32,

	fn lessThan(_: void, lhs: Structure, rhs: Structure) bool {
		return lhs.priority < rhs.priority;
	}
};

pub const StructureMapFragment = struct {
	pub const size = 1 << 7;
	pub const sizeMask = size - 1;
	pub const chunkedSize = size >> root.chunk.chunkShift;

	data: [chunkedSize*chunkedSize*chunkedSize][]StructureInternal = undefined,

	pos: ChunkPosition,
	voxelShift: u5,
	arena: root.heap.NeverFailingArenaAllocator,
	allocator: root.heap.NeverFailingAllocator,

	tempData: struct {
		lists: *[chunkedSize*chunkedSize*chunkedSize]root.List(Structure),
		allocator: NeverFailingAllocator,
	},

	pub fn init(self: *StructureMapFragment, tempAllocator: NeverFailingAllocator, wx: i32, wy: i32, wz: i32, voxelSize: u31) void {
		self.* = .{
			.pos = .{
				.wx = wx,
				.wy = wy,
				.wz = wz,
				.voxelSize = voxelSize,
			},
			.voxelShift = @ctz(voxelSize),
			.arena = .init(root.globalAllocator),
			.allocator = self.arena.allocator(),
			.tempData = .{
				.lists = tempAllocator.create([chunkedSize*chunkedSize*chunkedSize]root.List(Structure)),
				.allocator = tempAllocator,
			},
		};
		@memset(self.tempData.lists, .empty);
	}

	fn privateDeinit(self: *StructureMapFragment) void {
		self.arena.deinit();
		memoryPool.destroy(self);
	}

	pub fn deferredDeinit(self: *StructureMapFragment) void {
		root.heap.GarbageCollection.deferredFree(.{.ptr = self, .freeFunction = root.meta.castFunctionSelfToAnyopaque(privateDeinit)});
	}

	fn finishGeneration(self: *StructureMapFragment) void {
		for (0..self.data.len) |i| {
			std.sort.insertion(Structure, self.tempData.lists[i].items, {}, Structure.lessThan);
			self.data[i] = self.allocator.alloc(StructureInternal, self.tempData.lists[i].items.len);
			for (0..self.tempData.lists[i].items.len) |j| {
				self.data[i][j] = self.tempData.lists[i].items[j].internal;
			}
			self.tempData.lists[i].deinit(self.tempData.allocator);
			self.tempData.lists[i] = undefined;
		}
		self.tempData.allocator.destroy(self.tempData.lists);
		self.tempData = undefined;
		self.arena.shrinkAndFree();
	}

	fn getIndex(self: *const StructureMapFragment, x: i32, y: i32, z: i32) usize {
		std.debug.assert(x >= 0 and x < size*self.pos.voxelSize and y >= 0 and y < size*self.pos.voxelSize and z >= 0 and z < size*self.pos.voxelSize); // Coordinates out of range.
		return @intCast(((x >> root.chunk.chunkShift + self.voxelShift)*chunkedSize + (y >> root.chunk.chunkShift + self.voxelShift))*chunkedSize + (z >> root.chunk.chunkShift + self.voxelShift));
	}

	pub fn generateStructuresInChunk(self: *const StructureMapFragment, chunk: *ServerChunk, caveMap: terrain.CaveMap.CaveMapView, biomeMap: terrain.CaveBiomeMap.CaveBiomeMapView) void {
		const index = self.getIndex(chunk.super.pos.wx - self.pos.wx, chunk.super.pos.wy - self.pos.wy, chunk.super.pos.wz - self.pos.wz);
		for (self.data[index]) |structure| {
			structure.generate(chunk, caveMap, biomeMap);
		}
	}

	pub fn addStructure(self: *StructureMapFragment, structure: Structure, min: Vec3i, max: Vec3i) void {
		var x = min[0] & ~@as(i32, root.chunk.chunkMask << self.voxelShift | self.pos.voxelSize - 1);
		while (x < max[0]) : (x += root.chunk.chunkSize << self.voxelShift) {
			if (x < 0 or x >= size*self.pos.voxelSize) continue;
			var y = min[1] & ~@as(i32, root.chunk.chunkMask << self.voxelShift | self.pos.voxelSize - 1);
			while (y < max[1]) : (y += root.chunk.chunkSize << self.voxelShift) {
				if (y < 0 or y >= size*self.pos.voxelSize) continue;
				var z = min[2] & ~@as(i32, root.chunk.chunkMask << self.voxelShift | self.pos.voxelSize - 1);
				while (z < max[2]) : (z += root.chunk.chunkSize << self.voxelShift) {
					if (z < 0 or z >= size*self.pos.voxelSize) continue;
					self.tempData.lists[self.getIndex(x, y, z)].append(self.tempData.allocator, structure);
				}
			}
		}
	}
};

/// A generator for the cave map.
pub const StructureMapGenerator = struct {
	init: *const fn (parameters: ZonElement) void,
	generate: *const fn (map: *StructureMapFragment, seed: u64) void,
	/// Used to prioritize certain generators over others.
	priority: i32,
	/// To avoid duplicate seeds in similar generation algorithms, the SurfaceGenerator xors the world-seed with the generator specific seed.
	generatorSeed: u64,
	defaultState: GeneratorState,

	const generatorRegistry: std.StaticStringMap(StructureMapGenerator) = .initComptime(blk: {
		const decls = @typeInfo(structure_map_generators).@"struct".decls;
		var generators: [decls.len]struct { []const u8, StructureMapGenerator } = undefined;
		for (0..decls.len) |i| {
			const Generator = @field(structure_map_generators, decls[i].name);
			generators[i] = .{Generator.id, .{
				.init = &Generator.init,
				.generate = &Generator.generate,
				.priority = Generator.priority,
				.generatorSeed = Generator.generatorSeed,
				.defaultState = Generator.defaultState,
			}};
		}
		break :blk generators;
	});

	pub fn getAndInitGenerators(allocator: NeverFailingAllocator, settings: ZonElement) []StructureMapGenerator {
		var list: root.List(StructureMapGenerator) = .initCapacity(allocator, generatorRegistry.values().len);
		for (generatorRegistry.keys(), generatorRegistry.values()) |id, generator| {
			const generatorSettings = settings.getChild(id);
			if ((generatorSettings.get(GeneratorState, "state") orelse generator.defaultState) == .disabled) continue;
			generator.init(generatorSettings);
			list.appendAssumeCapacity(generator);
		}
		const lessThan = struct {
			fn lessThan(_: void, lhs: StructureMapGenerator, rhs: StructureMapGenerator) bool {
				return lhs.priority < rhs.priority;
			}
		}.lessThan;
		std.sort.insertion(StructureMapGenerator, list.items, {}, lessThan);
		return list.toOwnedSlice(allocator);
	}
};

const cacheSize = 1 << 10; // Must be a power of 2!
const associativity = 8;
var cache: Cache(StructureMapFragment, cacheSize, associativity, StructureMapFragment.deferredDeinit) = .{};
var profile: TerrainGenerationProfile = undefined;

var memoryPool: root.heap.MemoryPool(StructureMapFragment) = .init(root.globalArena);

fn cacheInit(pos: ChunkPosition) *StructureMapFragment {
	const mapFragment = memoryPool.create();
	mapFragment.init(root.stackAllocator, pos.wx, pos.wy, pos.wz, pos.voxelSize);
	for (profile.structureMapGenerators) |generator| {
		generator.generate(mapFragment, profile.seed ^ generator.generatorSeed);
	}
	mapFragment.finishGeneration();
	return mapFragment;
}

pub fn init(_profile: TerrainGenerationProfile) void {
	profile = _profile;
}

pub fn deinit() void {
	cache.clear();
}

pub fn getOrGenerateFragment(wx: i32, wy: i32, wz: i32, voxelSize: u31) *StructureMapFragment {
	const compare = ChunkPosition{
		.wx = wx & ~@as(i32, StructureMapFragment.sizeMask*voxelSize | voxelSize - 1),
		.wy = wy & ~@as(i32, StructureMapFragment.sizeMask*voxelSize | voxelSize - 1),
		.wz = wz & ~@as(i32, StructureMapFragment.sizeMask*voxelSize | voxelSize - 1),
		.voxelSize = voxelSize,
	};
	const result = cache.findOrCreate(compare, cacheInit, null);
	return result;
}
