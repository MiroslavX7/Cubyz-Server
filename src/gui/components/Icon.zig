const std = @import("std");

const root = @import("root");
const graphics = root.graphics;
const draw = graphics.draw;
const Texture = graphics.Texture;
const vec = root.vec;
const Vec2f = vec.Vec2f;

const gui = @import("../gui.zig");
const GuiComponent = gui.GuiComponent;

const Icon = @This();

pos: Vec2f,
size: Vec2f,
texture: Texture,

pub fn init(pos: Vec2f, size: Vec2f, texture: Texture) *Icon {
	const self = root.globalAllocator.create(Icon);
	self.* = Icon{
		.texture = texture,
		.pos = pos,
		.size = size,
	};
	return self;
}

pub fn deinit(self: *const Icon) void {
	root.globalAllocator.destroy(self);
}

pub fn toComponent(self: *Icon) GuiComponent {
	return .{.icon = self};
}

pub fn updateTexture(self: *Icon, newTexture: Texture) !void {
	self.texture = newTexture;
}

pub fn render(self: *Icon, _: Vec2f) void {
	self.texture.render(self.pos, self.size);
}
