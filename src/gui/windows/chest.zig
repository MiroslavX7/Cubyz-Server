const std = @import("std");

const root = @import("root");
const Player = root.game.Player;
const ItemStack = root.items.ItemStack;
const Vec2f = root.vec.Vec2f;
const Texture = root.graphics.Texture;

const gui = @import("../gui.zig");
const GuiComponent = gui.GuiComponent;
const GuiWindow = gui.GuiWindow;
const Button = GuiComponent.Button;
const HorizontalList = GuiComponent.HorizontalList;
const VerticalList = GuiComponent.VerticalList;
const ItemSlot = GuiComponent.ItemSlot;

const inventory = @import("inventory.zig");

pub var window = GuiWindow{
	.relativePosition = .{
		.{.attachedToWindow = .{.reference = &inventory.window, .selfAttachmentPoint = .middle, .otherAttachmentPoint = .middle}},
		.{.attachedToWindow = .{.reference = &inventory.window, .selfAttachmentPoint = .upper, .otherAttachmentPoint = .lower}},
	},
	.contentSize = Vec2f{64*10, 64*3},
	.scale = 0.75,
	.closeIfMouseIsGrabbed = true,
};

const padding: f32 = 8;
var itemSlots: root.List(*ItemSlot) = .empty;

pub fn deinit() void {
	itemSlots.clearAndFree(root.globalAllocator);
}

pub var openInventory: root.items.Inventory.ClientInventory = undefined;

pub fn setInventory(selectedInventory: root.items.Inventory.ClientInventory) void {
	openInventory = selectedInventory;
}

pub fn onOpen() void {
	const list = VerticalList.init(.{padding, padding + 16}, 300, 0);

	for (0..2) |y| {
		const row = HorizontalList.init();
		for (0..10) |x| {
			const index: usize = y*10 + x;
			const slot = ItemSlot.init(.{0, 0}, openInventory, @intCast(index), .default, .normal);
			itemSlots.append(root.globalAllocator, slot);
			row.add(slot);
		}
		list.add(row);
	}
	list.finish(.center);
	window.shiftClickableInventory = openInventory;
	window.rootComponent = list.toComponent();
	window.contentSize = window.rootComponent.?.pos() + window.rootComponent.?.size() + @as(Vec2f, @splat(padding));
	gui.updateWindowPositions();
}

pub fn onClose() void {
	openInventory.deinit(root.globalAllocator);

	itemSlots.clearRetainingCapacity();
	if (window.rootComponent) |*comp| {
		comp.deinit();
		window.rootComponent = null;
	}
}
