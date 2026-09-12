const std = @import("std");

const root = @import("root");
const Source = root.server.command.Source;
const Vec3i = root.vec.Vec3i;

pub const description = "Select the player position as position 1.";
pub const usage = "/pos1";

pub const Args = union(enum) {
	@"/pos1": struct {},
};

pub fn execute(_: Args, source: Source) void {
	if (source != .user) {
		source.sendMessage("Command cannot be run without a user", .{});
		return;
	}
	const user = source.user;
	const pos: Vec3i = @floor(user.player().pos);

	user.worldEditData.selectionPosition1 = pos;
	root.network.protocols.genericUpdate.sendWorldEditPos(user.conn, .selectedPos1, pos);

	user.sendMessage("Position 1: {}", .{pos});
}
