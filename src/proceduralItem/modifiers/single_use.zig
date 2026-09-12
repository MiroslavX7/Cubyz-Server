const std = @import("std");

const root = @import("root");
const ProceduralItem = root.items.ProceduralItem;

pub const Data = packed struct(u128) { strength: f32, pad: u96 = undefined };

pub const priority = 1000;

pub fn loadData(zon: root.ZonElement) Data {
	return .{.strength = @max(1, zon.get(f32, "strength") orelse 1)};
}

pub fn combineModifiers(data1: Data, data2: Data) ?Data {
	return .{.strength = @min(data1.strength, data2.strength)};
}

pub fn changeProceduralItemParameters(proceduralItem: *ProceduralItem, data: Data) void {
	proceduralItem.setProperty(.maxDurability, data.strength);
}

pub fn printTooltip(outString: *root.ListManaged(u8), data: Data) void {
	outString.print("#800000**Single-use**#808080 *Sets durability to **{d:.0}", .{data.strength});
}
