const std = @import("std");

const root = @import("root");
const NeverFailingAllocator = root.heap.NeverFailingAllocator;
const ModifierRestriction = root.items.ModifierRestriction;
const ProceduralItem = root.items.ProceduralItem;
const ZonElement = root.ZonElement;

const Not = struct {
	child: ModifierRestriction,
};

pub fn satisfied(self: *const Not, proceduralItem: *const ProceduralItem, x: i32, y: i32) bool {
	return !self.child.satisfied(proceduralItem, x, y);
}

pub fn loadFromZon(allocator: NeverFailingAllocator, zon: ZonElement) *const Not {
	const result = allocator.create(Not);
	result.* = .{
		.child = ModifierRestriction.loadFromZon(allocator, zon.getChild("child")),
	};
	return result;
}

pub fn printTooltip(self: *const Not, outString: *root.ListManaged(u8)) void {
	outString.appendSlice("not ");
	self.child.printTooltip(outString);
}
