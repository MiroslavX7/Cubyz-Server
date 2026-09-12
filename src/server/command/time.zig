const std = @import("std");

const root = @import("root");
const Source = root.server.command.Source;

pub const description = "Get or set the server time.";
pub const usage =
	\\/time
	\\/time <time>
	\\/time <day/night>
	\\/time <start/stop>"
;

pub const Args = union(enum) {
	@"/time <phase>": struct { phase: enum { day, dusk, night, dawn } },
	@"/time <subcommand>": struct { subcommand: enum { start, stop } },
	@"/time <number>": struct { number: i64 },
	@"/time": struct {},
};

pub fn execute(args: Args, source: Source) void {
	const gameTime: i64 = switch (args) {
		.@"/time" => time: {
			source.sendMessage("#ffff00{}", .{root.server.world.?.gameTime});
			break :time root.server.world.?.gameTime;
		},
		.@"/time <number>" => |params| params.number,
		.@"/time <phase>" => |params| switch (params.phase) {
			.day => root.game.World.DayTime.dayStart,
			.dusk => root.game.World.DayTime.duskStart,
			.night => root.game.World.DayTime.nightStart,
			.dawn => root.game.World.DayTime.dawnStart,
		},
		.@"/time <subcommand>" => |params| {
			switch (params.subcommand) {
				.start => {
					root.server.world.?.doGameTimeCycle = true;
					source.sendMessage("#ffff00Time started.", .{});
					return;
				},
				.stop => {
					root.server.world.?.doGameTimeCycle = false;
					source.sendMessage("#ffff00Time stopped.", .{});
					return;
				},
			}
		},
	};
	root.server.world.?.gameTime = gameTime;
}
