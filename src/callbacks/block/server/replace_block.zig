const std = @import("std");

const root = @import("root");

block: root.blocks.Block,

pub fn init(zon: main.ZonElement, _: main.callbacks.Creator) ?*@This() {
	const result = root.worldArena.create(@This());
	result.* = .{
		.block = root.blocks.parseBlock(zon.get([]const u8, "block") orelse {
			std.log.err("Missing field \"block\" for replace_block event", .{});
			return null;
		}),
	};
	return result;
}

pub fn run(self: *@This(), params: main.callbacks.ServerBlockCallback.Params) main.callbacks.Result {
	const wx = params.chunk.super.pos.wx + params.blockPos.x;
	const wy = params.chunk.super.pos.wy + params.blockPos.y;
	const wz = params.chunk.super.pos.wz + params.blockPos.z;

	_ = root.server.world.?.cmpxchgBlock(wx, wy, wz, params.block, self.block);
	return .handled;
}
