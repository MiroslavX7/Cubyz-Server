const std = @import("std");

const root = @import("root");
const Block = root.blocks.Block;
const blocks = root.blocks;
const Neighbor = root.chunk.Neighbor;
const vec = root.vec;
const Vec3i = vec.Vec3i;
const Vec3d = vec.Vec3d;
const Vec3f = vec.Vec3f;
const ZonElement = root.ZonElement;
const server = root.server;

pub fn init(_: ZonElement, _: root.callbacks.Creator) ?*@This() {
	return @as(*@This(), undefined);
}

pub fn run(_: *@This(), params: root.callbacks.ServerBlockCallback.Params) root.callbacks.Result {
	const wx = params.chunk.super.pos.wx + params.blockPos.x;
	const wy = params.chunk.super.pos.wy + params.blockPos.y;
	const wz = params.chunk.super.pos.wz + params.blockPos.z;

	var neighborSupportive: [6]bool = undefined;

	for (Neighbor.iterable) |neighbor| {
		const neighborBlock: Block = root.server.world.?.getBlock(wx +% neighbor.relX(), wy +% neighbor.relY(), wz +% neighbor.relZ()) orelse .{.typ = 0, .data = 0};
		const neighborModel = root.blocks.meshes.model(neighborBlock).model();
		neighborSupportive[neighbor.toInt()] = !neighborBlock.replaceable() and neighborModel.neighborFacingQuads[neighbor.reverse().toInt()].len != 0;
	}

	var newBlock: Block = params.block;

	inline for (comptime std.meta.declarations(root.rotation.rotations)) |rotationMode| {
		if (params.block.mode() == root.rotation.getByID(rotationMode.name)) {
			if (@hasDecl(@field(root.rotation.rotations, rotationMode.name), "updateBlockFromNeighborConnectivity")) {
				@field(root.rotation.rotations, rotationMode.name).updateBlockFromNeighborConnectivity(&newBlock, neighborSupportive);
			} else {
				std.log.err("Rotation mode {s} has no updateBlockFromNeighborConnectivity function and cannot be used for {s} callback", .{rotationMode.name, @typeName(@This())});
			}
		}
	}

	if (newBlock == params.block) return .ignored;

	if (root.server.world.?.cmpxchgBlock(wx, wy, wz, params.block, newBlock) == null) {
		const dropAmount = params.block.mode().itemDropsOnChange(params.block, newBlock);
		const drops = params.block.blockDrops();
		for (0..dropAmount) |_| {
			for (drops) |drop| {
				if (!drop.isDroppedWhenBrokenWithItem(.null)) continue;
				if (drop.chance == 1 or root.random.nextFloat(&root.seed) < drop.chance) {
					for (drop.itemStacks) |stack| {
						var dir = root.vec.normalize(root.random.nextFloatVectorSigned(3, &root.seed));
						// Bias upwards
						dir[2] += root.random.nextFloat(&root.seed)*4.0;
						const model = params.block.mode().model(params.block).model();
						const pos = Vec3f{
							@as(f32, @floatFromInt(wx)) + model.min[0] + root.random.nextFloat(&root.seed)*(model.max[0] - model.min[0]),
							@as(f32, @floatFromInt(wy)) + model.min[1] + root.random.nextFloat(&root.seed)*(model.max[1] - model.min[1]),
							@as(f32, @floatFromInt(wz)) + model.min[2] + root.random.nextFloat(&root.seed)*(model.max[2] - model.min[2]),
						};
						root.server.world.?.drop(stack.clone(), pos, dir, 1);
					}
				}
			}
		}
		return .handled;
	}
	return .ignored;
}
