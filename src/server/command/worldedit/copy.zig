const std = @import("std");

const root = @import("root");
const command = root.server.command;
const Source = command.Source;

const Block = root.blocks.Block;
const Blueprint = root.blueprint.Blueprint;

pub const description = "Copy selection to clipboard.";
pub const usage = "/copy";

pub const Args = union(enum) {
	@"/copy": struct {},
};

pub fn execute(_: Args, source: Source) void {
	if (source != .user) {
		source.sendMessage("Command cannot be run without a user", .{});
		return;
	}
	const user = source.user;
	const selection = command.getCurrentSelection(user) catch return;
	user.sendMessage("Copying: {f}", .{selection});

	const result = Blueprint.capture(root.globalAllocator, selection);
	switch (result) {
		.success => {
			if (user.worldEditData.clipboard != null) {
				user.worldEditData.clipboard.?.deinit(root.globalAllocator);
			}
			user.worldEditData.clipboard = result.success;

			user.sendMessage("Copied selection to clipboard.", .{});
		},
		.failure => |e| {
			user.sendMessage("#ff0000Error while copying block {}: {s}", .{e.pos, e.message});
			std.log.warn("Error while copying block {}: {s}", .{e.pos, e.message});
		},
	}
}
