const std = @import("std");

const root = @import("root");
const Block = root.blocks.Block;

blockType: u16,

pub fn init(zon: main.ZonElement, creator: main.callbacks.Creator) ?*@This() {
	const replacedBlock = switch (creator) {
		.block => |b| b,
	};
	const result = root.worldArena.create(@This());
	const blockId = zon.get([]const u8, "block") orelse {
		std.log.err("Missing field \"block\" for replace_block_type event", .{});
		return null;
	};
	const blockType = root.blocks.getBlockById(blockId) catch {
		std.log.err("Block with id '{s}' not found for replace_block_type event", .{blockId});
		return null;
	};
	const block: Block = .{
		.typ = blockType,
		.data = 0,
	};
	if (replacedBlock.mode() != block.mode()) {
		std.log.err("The replaced and replacing blocks' rotation modes don't match in replace_block_type event", .{});
		return null;
	}
	result.* = .{
		.blockType = blockType,
	};
	return result;
}

pub fn run(self: *@This(), params: main.callbacks.ServerBlockCallback.Params) main.callbacks.Result {
	const wx = params.chunk.super.pos.wx + params.blockPos.x;
	const wy = params.chunk.super.pos.wy + params.blockPos.y;
	const wz = params.chunk.super.pos.wz + params.blockPos.z;

	const replacingBlock: Block = .{
		.typ = self.blockType,
		.data = params.block.data,
	};
	_ = root.server.world.?.cmpxchgBlock(wx, wy, wz, params.block, replacingBlock);
	return .handled;
}
