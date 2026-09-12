const std = @import("std");

const root = @import("root");

dps: f32,
damageType: root.game.DamageType,

pub fn init(zon: root.ZonElement, _: root.callbacks.Creator) ?*@This() {
	const result = root.worldArena.create(@This());
	result.* = .{
		.dps = zon.get(f32, "dps") orelse {
			std.log.err("Missing field \"dps\" for hurt event", .{});
			return null;
		},
		.damageType = std.meta.stringToEnum(root.game.DamageType, zon.get([]const u8, "damageType") orelse {
			std.log.err("Missing field \"damageType\" for hurt event", .{});
			return null;
		}) orelse {
			std.log.err("Unknown damage type for hurt event", .{});
			return null;
		},
	};
	return result;
}

pub fn run(self: *@This(), params: root.callbacks.BlockTouchCallback.Params) root.callbacks.Result {
	std.debug.assert(params.entity == &root.game.Player.super); // TODO: Implement on the server side
	const damage = self.dps*@as(f32, @floatCast(params.deltaTime));
	root.sync.addHealth(-damage, self.damageType, .client, root.game.Player.id);
	return .handled;
}
