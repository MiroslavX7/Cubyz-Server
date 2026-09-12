const std = @import("std");

const root = @import("root");
const NeverFailingAllocator = root.heap.NeverFailingAllocator;
const ModifierRestriction = root.items.ModifierRestriction;
const ProceduralItem = root.items.ProceduralItem;
const ZonElement = root.ZonElement;

const Or = struct {
	children: []ModifierRestriction,
};

pub fn satisfied(self: *const Or, proceduralItem: *const ProceduralItem, x: i32, y: i32) bool {
	for (self.children) |child| {
		if (child.satisfied(proceduralItem, x, y)) return true;
	}
	return false;
}

pub fn loadFromZon(allocator: NeverFailingAllocator, zon: ZonElement) *const Or {
	const result = allocator.create(Or);
	const childrenZon = zon.getChild("children").toSlice();
	result.children = allocator.alloc(ModifierRestriction, childrenZon.len);
	for (result.children, childrenZon) |*child, childZon| {
		child.* = ModifierRestriction.loadFromZon(allocator, childZon);
	}
	return result;
}

pub fn printTooltip(self: *const Or, outString: *root.ListManaged(u8)) void {
	outString.append('(');
	for (self.children, 0..) |child, i| {
		if (i != 0) outString.appendSlice(" or ");
		child.printTooltip(outString);
	}
	outString.append(')');
}
