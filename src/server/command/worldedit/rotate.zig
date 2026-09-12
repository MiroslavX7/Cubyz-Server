const std = @import("std");

const root = @import("root");
const Degrees = main.rotation.Degrees;
const Source = root.server.command.Source;

pub const description = "rotate clipboard content around Z axis counterclockwise.";
pub const usage =
	\\/rotate
	\\/rotate <0/90/180/270>
;

pub const Args = union(enum) {
	@"/rotate": struct {},
	@"/rotate <rotation>": struct { rotation: Degrees },
};

pub fn execute(args: Args, source: Source) void {
	if (source != .user) {
		source.sendMessage("Command cannot be run without a user", .{});
		return;
	}
	const user = source.user;
	if (user.worldEditData.clipboard == null) {
		source.sendMessage("#ff0000Error: No clipboard content to rotate.", .{});
		return;
	}
	const current = user.worldEditData.clipboard.?;
	defer current.deinit(root.globalAllocator);
	switch (args) {
		.@"/rotate" => user.worldEditData.clipboard = current.rotateZ(root.globalAllocator, .@"90"),
		.@"/rotate <rotation>" => |params| user.worldEditData.clipboard = current.rotateZ(root.globalAllocator, params.rotation),
	}
}
