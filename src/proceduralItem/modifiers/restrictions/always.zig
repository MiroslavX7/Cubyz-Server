const std = @import("std");

const root = @import("root");
const NeverFailingAllocator = root.heap.NeverFailingAllocator;
const ProceduralItem = root.items.ProceduralItem;
const ZonElement = root.ZonElement;

pub fn satisfied(_: *const anyopaque, _: *const ProceduralItem, _: i32, _: i32) bool {
	return true;
}

pub fn loadFromZon(_: NeverFailingAllocator, _: ZonElement) *const anyopaque {
	return undefined;
}

pub fn printTooltip(_: *const anyopaque, outString: *root.ListManaged(u8)) void {
	outString.appendSlice("always");
}
