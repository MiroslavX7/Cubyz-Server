const std = @import("std");

const root = @import("root");
const ProceduralItem = root.items.ProceduralItem;

pub const Data = packed struct(u128) { strength: f32, tag: root.Tag, pad: u64 = undefined };

pub const priority = 1;

pub fn loadData(zon: root.ZonElement) Data {
	return .{.strength = @max(0, zon.get(f32, "strength") orelse 0), .tag = .find(zon.get([]const u8, "tag") orelse "incorrect")};
}

pub fn combineModifiers(data1: Data, data2: Data) ?Data {
	if (data1.tag != data2.tag) return null;
	return .{.strength = std.math.hypot(data1.strength, data2.strength), .tag = data1.tag};
}

pub fn changeBlockDamage(damage: f32, block: root.blocks.Block, data: Data) f32 {
	for (block.tags()) |tag| {
		if (tag == data.tag) return damage*(1 + data.strength);
	}
	return damage;
}

pub fn printTooltip(outString: *root.ListManaged(u8), data: Data) void {
	outString.print("#80ff40**Good at**#808080 *Increases damage by **{d:.0}%** on \n***#80ff40{s}#808080*** blocks", .{data.strength*100, data.tag.getName()});
}
