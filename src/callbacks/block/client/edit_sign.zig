const std = @import("std");

const root = @import("root");
const Block = root.blocks.Block;
const vec = root.vec;
const Vec3i = vec.Vec3i;
const ZonElement = root.ZonElement;

pub fn init(_: ZonElement, _: root.callbacks.Creator) ?*anyopaque {
	return @as(*anyopaque, undefined);
}

pub fn run(_: *anyopaque, params: root.callbacks.ClientBlockCallback.Params) root.callbacks.Result {
	if (params.block.blockEntity() == null or !std.mem.eql(u8, params.block.blockEntity().?.id, "cubyz:sign")) {
		std.log.err("Can only edit sign if block entity of the block is a sign.", .{});
		return .ignored;
	}
	root.block_entity.BlockEntityTypes.@"cubyz:sign".StorageClient.mutex.lock();
	defer root.block_entity.BlockEntityTypes.@"cubyz:sign".StorageClient.mutex.unlock();
	const data = root.block_entity.BlockEntityTypes.@"cubyz:sign".StorageClient.get(params.blockPos, params.chunk);
	root.gui.windowlist.sign_editor.openFromSignData(params.blockPos, if (data) |_data| _data.text else "");

	return .handled;
}
