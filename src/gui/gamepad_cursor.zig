const std = @import("std");

const root = @import("root");
const graphics = root.graphics;
const Texture = graphics.Texture;
const Vec2f = root.vec.Vec2f;

const gui = @import("gui.zig");

const size: f32 = 16;

var texture: Texture = undefined;

pub fn init() void {
	texture = Texture.initFromFile("assets/cubyz/ui/gamepad_cursor.png");
}

pub fn deinit() void {
	texture.deinit();
}

pub fn render() void {
	if (root.Window.lastUsedMouse or root.Window.grabbed) return;
	const mousePos = root.Window.getMousePosition();
	graphics.draw.image(texture, @as(Vec2f, @splat(-size/2.0)) + (mousePos/@as(Vec2f, @splat(gui.scale))), .{size, size});
}
