const std = @import("std");

const root = @import("root");
const ProceduralItem = root.items.ProceduralItem;

pub const Data = packed struct(u128) { strength: f32, pad: u96 = undefined };

pub const priority = 1;

pub fn loadData(zon: root.ZonElement) Data {
	return .{.strength = @max(0, zon.get(f32, "strength") orelse 0)};
}

pub fn combineModifiers(data1: Data, data2: Data) ?Data {
	return .{.strength = std.math.hypot(data1.strength, data2.strength)};
}

pub fn changeProceduralItemParameters(proceduralItem: *ProceduralItem, data: Data) void {
	proceduralItem.setProperty(.maxDurability, proceduralItem.getProperty(.maxDurability)*(1 + data.strength));
}

pub fn printTooltip(outString: *root.ListManaged(u8), data: Data) void {
	outString.print("#500090**Durable**#808080 *Increases durability by **{d:.0}%", .{data.strength*100});
}
