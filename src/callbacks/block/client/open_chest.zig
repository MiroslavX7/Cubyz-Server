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
	if (params.block.blockEntity() == null or !std.mem.eql(u8, params.block.blockEntity().?.id, "cubyz:chest")) {
		std.log.err("Can only open chest if block entity of the block is a chest.", .{});
		return .ignored;
	}
	root.network.protocols.blockEntityUpdate.sendClientDataUpdateToServer(root.game.world.?.conn, params.blockPos);

	const inventory = root.items.Inventory.ClientInventory.init(root.globalAllocator, root.block_entity.BlockEntityTypes.@"cubyz:chest".inventorySize, .serverShared, .{.blockInventory = params.blockPos}, .{});

	root.gui.windowlist.chest.setInventory(inventory);
	root.gui.openWindow("chest");
	root.Window.setMouseGrabbed(false);

	return .handled;
}
