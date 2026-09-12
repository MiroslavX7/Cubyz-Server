const std = @import("std");

const root = @import("root");
const Block = root.blocks.Block;
const vec = main.vec;
const Vec3i = vec.Vec3i;
const ZonElement = main.ZonElement;

windowName: []const u8,

pub fn init(zon: ZonElement, _: main.callbacks.Creator) ?*@This() {
	const result = root.worldArena.create(@This());
	result.* = .{
		.windowName = root.worldArena.dupe(u8, zon.get([]const u8, "name") orelse {
			std.log.err("Missing field \"name\" for open_window event.", .{});
			return null;
		}),
	};
	return result;
}

pub fn run(self: *@This(), _: main.callbacks.ClientBlockCallback.Params) main.callbacks.Result {
	main.gui.openWindow(self.windowName);
	main.Window.setMouseGrabbed(false);
	return .handled;
}
