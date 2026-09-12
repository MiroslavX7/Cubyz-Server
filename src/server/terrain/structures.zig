const std = @import("std");

const root = @import("root");
const ZonElement = root.ZonElement;
const NeverFailingAllocator = root.heap.NeverFailingAllocator;
const ServerChunk = root.chunk.ServerChunk;
const terrain = root.server.terrain;
const Assets = root.assets.Assets;
const biomes = root.server.terrain.biomes;
const Tag = root.Tag;

pub const simple_structures = @import("simple_structures/_list.zig");

pub const SimpleStructureModel = struct { // MARK: SimpleStructureModel
	pub const GenerationMode = enum {
		floor,
		ceiling,
		floor_and_ceiling,
		air,
		underground,
		water_surface,
	};
	const VTable = struct {
		loadModel: *const fn (parameters: ZonElement) ?*anyopaque,
		generate: *const fn (self: *anyopaque, generationMode: GenerationMode, x: i32, y: i32, z: i32, chunk: *ServerChunk, caveMap: terrain.CaveMap.CaveMapView, biomeMap: terrain.CaveBiomeMap.CaveBiomeMapView, seed: *u64, isCeiling: bool) void,
		hashFunction: *const fn (self: *anyopaque) u64,
		generationMode: GenerationMode,
	};

	vtable: VTable,
	data: *anyopaque,
	chance: f32,
	priority: f32,
	generationMode: GenerationMode,

	pub fn initModel(parameters: ZonElement) ?SimpleStructureModel {
		const id = parameters.get([]const u8, "id") orelse "";
		const vtable = modelRegistry.get(id) orelse {
			std.log.err("Couldn't find structure model with id {s}", .{id});
			return null;
		};
		const vtableModel = vtable.loadModel(parameters) orelse {
			std.log.err("Error occurred while loading structure with id '{s}'. Dropping model from biome.", .{id});
			return null;
		};
		return SimpleStructureModel{
			.vtable = vtable,
			.data = vtableModel,
			.chance = parameters.get(f32, "chance") orelse 0.1,
			.priority = parameters.get(f32, "priority") orelse 1,
			.generationMode = std.meta.stringToEnum(GenerationMode, parameters.get([]const u8, "generationMode") orelse "") orelse vtable.generationMode,
		};
	}

	pub fn generate(self: SimpleStructureModel, x: i32, y: i32, z: i32, chunk: *ServerChunk, caveMap: terrain.CaveMap.CaveMapView, biomeMap: terrain.CaveBiomeMap.CaveBiomeMapView, seed: *u64, isCeiling: bool) void {
		self.vtable.generate(self.data, self.generationMode, x, y, z, chunk, caveMap, biomeMap, seed, isCeiling);
	}

	const modelRegistry: std.StaticStringMap(VTable) = .initComptime(blk: {
		const decls = @typeInfo(simple_structures).@"struct".decls;
		var generators: [decls.len]struct { []const u8, VTable } = undefined;
		for (0..decls.len) |i| {
			const Generator = @field(simple_structures, decls[i].name);
			generators[i] = .{Generator.id, .{
				.loadModel = root.meta.castFunctionReturnToOptionalAnyopaque(Generator.loadModel),
				.generate = root.meta.castFunctionSelfToAnyopaque(Generator.generate),
				.hashFunction = root.meta.castFunctionSelfToAnyopaque(struct {
					fn hash(ptr: *Generator) u64 {
						return biomes.hashGeneric(ptr.*);
					}
				}.hash),
				.generationMode = Generator.generationMode,
			}};
		}
		break :blk generators;
	});
};

pub const StructureTable = struct {
	id: []const u8,
	tags: []const Tag,
	structures: []const SimpleStructureModel = &.{},
	pub fn init(id: []const u8, zon: ZonElement) StructureTable {
		var structureTable: StructureTable = .{
			.id = root.worldArena.dupe(u8, id),
			.tags = Tag.loadTagsFromZon(root.worldArena, zon.getChild("tags")),
		};
		const tableChance: ?f32 = zon.get(f32, "chance");
		var structureList: root.List(SimpleStructureModel) = .empty;
		defer structureList.deinit(root.stackAllocator);

		const structures = zon.getChild("structures");

		var totalChance: f32 = 0.0;
		for (structures.toSlice()) |elem| {
			if (SimpleStructureModel.initModel(elem)) |model| {
				structureList.append(root.stackAllocator, model);
				totalChance += model.chance;
			}
		}
		if (totalChance == 0) {
			std.log.err("Invalid structure chance in table {s}. Adding table without its structures.", .{structureTable.id});
			return structureTable;
		}

		if (tableChance) |chance| {
			for (structureList.items) |*structure| {
				structure.chance /= totalChance;
				structure.chance *= chance;
			}
		}

		structureTable.structures = root.worldArena.dupe(SimpleStructureModel, structureList.items);
		return structureTable;
	}
};

var finishedLoading: bool = false;
var structureTables: root.List(StructureTable) = .empty;
var structureTablesById: std.StringHashMapUnmanaged(*StructureTable) = .{};

fn register(id: []const u8, zon: ZonElement) void {
	const structureTable = StructureTable.init(id, zon);
	structureTables.append(root.worldArena, structureTable);
	std.log.debug("Registered structure table: '{s}'", .{id});
}

pub fn registerStructureTables(structures: *Assets.ZonHashMap) !void {
	var iterator = structures.iterator();
	while (iterator.next()) |entry| {
		register(entry.key_ptr.*, entry.value_ptr.*);
	}
	finishLoading();
}
fn compareStructureTables(_: void, lhs: StructureTable, rhs: StructureTable) bool {
	return std.ascii.orderIgnoreCase(lhs.id, rhs.id) == .gt;
}

pub fn finishLoading() void {
	std.debug.assert(!finishedLoading);
	finishedLoading = true;

	std.mem.sort(StructureTable, structureTables.items, {}, compareStructureTables);
	structureTablesById.ensureTotalCapacity(root.worldArena.allocator, @intCast(structureTables.items.len)) catch unreachable;
	for (structureTables.items) |*structureTable| {
		structureTablesById.putAssumeCapacity(structureTable.id, structureTable);
	}
}

pub fn getById(id: []const u8) ?*StructureTable {
	std.debug.assert(finishedLoading);
	return structureTablesById.get(id);
}

pub fn getSlice() []StructureTable {
	return structureTables.items;
}

pub fn reset() void {
	finishedLoading = false;
	structureTables = .empty;
	structureTablesById = .{};
}
