const std = @import("std");

const root = @import("root");
const NeverFailingAllocator = root.heap.NeverFailingAllocator;
const ModifierRestriction = root.items.ModifierRestriction;
const ProceduralItem = root.items.ProceduralItem;
const ZonElement = root.ZonElement;

const Encased = struct {
	tag: root.Tag,
	amount: usize,
};

pub fn satisfied(self: *const Encased, proceduralItem: *const ProceduralItem, x: i32, y: i32) bool {
	var count: usize = 0;
	for ([_]i32{-1, 0, 1}) |dx| {
		for ([_]i32{-1, 0, 1}) |dy| {
			if ((proceduralItem.getItemAt(x + dx, y + dy) orelse continue).hasTag(self.tag)) count += 1;
		}
	}
	return count >= self.amount;
}

pub fn loadFromZon(allocator: NeverFailingAllocator, zon: ZonElement) *const Encased {
	const result = allocator.create(Encased);
	result.* = .{
		.tag = root.Tag.find(zon.get([]const u8, "tag") orelse blk: {
			std.log.err("Missing tag field for encased restriction.", .{});
			break :blk "not specified";
		}),
		.amount = zon.get(usize, "amount") orelse 8,
	};
	return result;
}

pub fn printTooltip(self: *const Encased, outString: *root.ListManaged(u8)) void {
	outString.print("encased in {} .{s}", .{self.amount, self.tag.getName()});
}
