const std = @import("std");

const root = @import("root");
const Item = root.items.Item;
const ClientInventory = root.items.Inventory.ClientInventory;
const Player = root.game.Player;
const Vec2f = root.vec.Vec2f;

const gui = @import("../gui.zig");
const GuiComponent = gui.GuiComponent;
const GuiWindow = gui.GuiWindow;
const TextInput = GuiComponent.TextInput;
const Label = GuiComponent.Label;
const HorizontalList = GuiComponent.HorizontalList;
const VerticalList = GuiComponent.VerticalList;
const ItemSlot = GuiComponent.ItemSlot;

pub var window = GuiWindow{
	.relativePosition = .{
		.{.attachedToFrame = .{.selfAttachmentPoint = .lower, .otherAttachmentPoint = .lower}},
		.{.attachedToFrame = .{.selfAttachmentPoint = .middle, .otherAttachmentPoint = .middle}},
	},
	.contentSize = Vec2f{64*8, 64*6},
	.scale = 0.75,
};

const padding: f32 = 8;
const slotsPerRow: u32 = 10;
var items: root.ListManaged(Item) = undefined;
var inventory: ClientInventory = undefined;
var searchInput: *TextInput = undefined;
var searchString: []const u8 = undefined;

fn lessThan(_: void, lhs: Item, rhs: Item) bool {
	if (lhs == .baseItem and rhs == .baseItem) {
		const lhsFolders = std.mem.count(u8, lhs.baseItem.id(), "/");
		const rhsFolders = std.mem.count(u8, rhs.baseItem.id(), "/");
		if (lhsFolders < rhsFolders) return true;
		if (lhsFolders > rhsFolders) return false;
		return std.ascii.lessThanIgnoreCase(lhs.baseItem.id(), rhs.baseItem.id());
	} else {
		if (lhs == .baseItem) return true;
		return false;
	}
}

pub fn onOpen() void {
	searchString = "";
	initContent();
}

pub fn onClose() void {
	deinitContent();
	root.globalAllocator.free(searchString);
}

fn hasMatchingTag(tags: []const root.Tag, target: []const u8) bool {
	for (tags) |tag| {
		if (std.mem.containsAtLeast(u8, tag.getName(), 1, target)) {
			return true;
		}
	}
	return false;
}

fn initContent() void {
	const root_component = VerticalList.init(.{padding, padding}, 300, 0);
	{
		const list = VerticalList.init(.{0, padding + padding}, 48, 0);
		const row = HorizontalList.init();
		const label = Label.init(.{0, 3}, 56, "Search:", .right);

		searchInput = TextInput.init(.{0, 0}, 288, 22, searchString, .{.onNewline = .init(filter)});

		row.add(label);
		row.add(searchInput);
		list.add(row);
		list.finish(.center);
		root_component.add(list);
	}
	{
		const list = VerticalList.init(.{0, padding}, 144, 0);
		items = .init(root.globalAllocator);
		var itemIterator = root.items.iterator();
		if (searchString.len > 1 and searchString[0] == '.') {
			const tag = searchString[1..];
			while (itemIterator.next()) |item| {
				if (hasMatchingTag(item.tags(), tag) or (item.block() != null and hasMatchingTag((root.blocks.Block{.typ = item.block().?, .data = undefined}).tags(), tag))) {
					items.append(Item{.baseItem = item.*});
				}
			}
		} else {
			while (itemIterator.next()) |item| {
				if (searchString.len != 0 and !std.mem.containsAtLeast(u8, item.id(), 1, searchString)) continue;
				items.append(Item{.baseItem = item.*});
			}
		}

		std.mem.sort(Item, items.items, {}, lessThan);
		const slotCount = items.items.len + (slotsPerRow - items.items.len%slotsPerRow);
		inventory = ClientInventory.init(root.globalAllocator, slotCount, .creative, .other, .{});
		for (0..items.items.len) |i| {
			inventory.super._items[i] = .{.item = items.items[i], .amount = 1};
		}
		var i: u32 = 0;
		while (i < items.items.len) {
			const row = HorizontalList.init();
			for (0..slotsPerRow) |_| {
				if (i >= items.items.len) {
					row.add(ItemSlot.init(.{0, 0}, inventory, i, .immutable, .immutable));
				} else {
					row.add(ItemSlot.init(.{0, 0}, inventory, i, .default, .takeOnly));
				}
				i += 1;
			}
			list.add(row);
		}
		list.finish(.center);
		root_component.add(list);
	}
	root_component.finish(.center);
	window.rootComponent = root_component.toComponent();
	window.contentSize = window.rootComponent.?.pos() + window.rootComponent.?.size() + @as(Vec2f, @splat(padding));
	gui.updateWindowPositions();
}

fn deinitContent() void {
	if (window.rootComponent) |*comp| {
		comp.deinit();
	}
	items.deinit();
	inventory.deinit(root.globalAllocator);
}

pub fn update() void {
	if (std.mem.eql(u8, searchInput.currentString.items, searchString)) return;
	filter();
}

fn filter() void {
	const selectionStart = searchInput.selectionStart;
	const cursor = searchInput.cursor;

	root.globalAllocator.free(searchString);
	searchString = root.globalAllocator.dupe(u8, searchInput.currentString.items);
	deinitContent();
	initContent();

	searchInput.selectionStart = selectionStart;
	searchInput.cursor = cursor;

	searchInput.select();
}
