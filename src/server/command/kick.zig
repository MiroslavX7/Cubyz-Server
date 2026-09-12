const std = @import("std");

const root = @import("root");
const command = root.server.command;
const Source = command.Source;
const User = root.server.User;

pub const description = "Kicks a player";
pub const usage = "/kick @<playerIndex>";

pub const Args = union(enum) {
	@"/kick <playerIndex>": struct { playerIndex: command.PlayerIndex },
};

pub fn execute(args: Args, source: Source) void {
	const target = command.Target.fromPlayerIndex(args.@"/kick <playerIndex>".playerIndex, source) catch return;

	target.user.conn.disconnect();
	root.server.sendMessage("{s}§#ffff00 has been kicked from the server", .{target.user.name});
}
