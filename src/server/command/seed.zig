const std = @import("std");

const root = @import("root");
const command = root.server.command;
const Source = command.Source;

pub const description = "Get the world seed.";
pub const usage =
	\\/seed
;

pub const Args = union(enum) {
	@"/seed": struct {},
};

pub fn execute(_: Args, source: Source) void {
	source.sendMessage("#ffff00{}", .{root.server.world.?.settings.seed});
}
