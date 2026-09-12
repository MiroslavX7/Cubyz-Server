const std = @import("std");

const root = @import("root");
const command = root.server.command;
const Source = command.Source;

pub const description = "Get or set a player's gamemode.";
pub const usage =
	\\/gamemode <survival/creative>
	\\/gamemode @playerIndex <survival/creative>
	\\/gamemode
	\\/gamemode @playerIndex
;

pub const Args = union(enum) {
	@"/gamemode <playerIndex> <mode>": struct { playerIndex: ?command.PlayerIndex, mode: ?root.game.Gamemode },
};

pub fn execute(args: Args, source: Source) void {
	switch (args) {
		.@"/gamemode <playerIndex> <mode>" => |params| {
			const target = command.Target.fromPlayerIndex(params.playerIndex, source) catch return;

			if (params.mode) |mode| {
				root.sync.setGamemode(target.user, mode);
			} else {
				source.sendMessage("#ffff00{s}", .{@tagName(target.user.gamemode.load(.monotonic))});
			}
		},
	}
}
