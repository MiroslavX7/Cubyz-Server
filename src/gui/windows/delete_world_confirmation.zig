const std = @import("std");

const root = @import("root");
const Vec2f = main.vec.Vec2f;

const gui = @import("../gui.zig");
const GuiComponent = gui.GuiComponent;
const GuiWindow = gui.GuiWindow;
const Button = @import("../components/Button.zig");
const Label = @import("../components/Label.zig");
const VerticalList = @import("../components/VerticalList.zig");

pub var window = GuiWindow{
	.contentSize = Vec2f{128, 256},
};

const padding: f32 = 8;

var deleteWorldName: []const u8 = "";

pub fn init() void {
	deleteWorldName = "";
}

pub fn deinit() void {
	root.globalAllocator.free(deleteWorldName);
}

pub fn setDeleteWorldName(name: []const u8) void {
	root.globalAllocator.free(deleteWorldName);
	deleteWorldName = root.globalAllocator.dupe(u8, name);
}

fn flawedDeleteWorld(name: []const u8) !void {
	const path = std.mem.concat(root.stackAllocator.allocator, u8, &.{"saves/", name}) catch unreachable;
	defer root.stackAllocator.free(path);
	try root.files.cubyzDir().deleteTree(path);
	gui.windowlist.save_selection.needsUpdate = true;
}

fn deleteWorld() void {
	flawedDeleteWorld(deleteWorldName) catch |err| {
		std.log.err("Encountered error while deleting world \"{s}\": {s}", .{deleteWorldName, @errorName(err)});
	};
	gui.closeWindowFromRef(&window);
}

pub fn onOpen() void {
	const list = VerticalList.init(.{padding, 16 + padding}, 300, 16);
	const text = root.stackAllocator.print("Are you sure you want to delete the world **{s}**?", .{deleteWorldName});
	defer root.stackAllocator.free(text);
	list.add(Label.init(.{0, 0}, 128, text, .center));
	list.add(Button.initText(.{0, 0}, 128, "Yes", .{.onAction = .init(deleteWorld)}));
	list.finish(.center);
	window.rootComponent = list.toComponent();
	window.contentSize = window.rootComponent.?.pos() + window.rootComponent.?.size() + @as(Vec2f, @splat(padding));
	gui.updateWindowPositions();
}

pub fn onClose() void {
	if (window.rootComponent) |*comp| {
		comp.deinit();
	}
}
