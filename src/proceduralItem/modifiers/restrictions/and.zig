const std = @import("std");

const root = @import("root");
const NeverFailingAllocator = root.heap.NeverFailingAllocator;
const ModifierRestriction = root.items.ModifierRestriction;
const ProceduralItem = root.items.ProceduralItem;
const ZonElement = root.ZonElement;

const And = struct {
	children: []ModifierRestriction,
};

pub fn satisfied(self: *const And, proceduralItem: *const ProceduralItem, x: i32, y: i32) bool {
	for (self.children) |child| {
		if (!child.satisfied(proceduralItem, x, y)) return false;
	}
	return true;
}

pub fn loadFromZon(allocator: NeverFailingAllocator, zon: ZonElement) *const And {
	const result = allocator.create(And);
	const childrenZon = zon.getChild("children").toSlice();
	result.children = allocator.alloc(ModifierRestriction, childrenZon.len);
	for (result.children, childrenZon) |*child, childZon| {
		child.* = ModifierRestriction.loadFromZon(allocator, childZon);
	}
	return result;
}

pub fn printTooltip(self: *const And, outString: *root.ListManaged(u8)) void {
	outString.append('(');
	for (self.children, 0..) |child, i| {
		if (i != 0) outString.appendSlice(" and ");
		child.printTooltip(outString);
	}
	outString.append(')');
}
