const std = @import("std");

const root = @import("root");
const command = root.server.command;
const Source = command.Source;
const Vec3i = root.vec.Vec3i;
const User = root.server.User;

const Block = root.blocks.Block;
const Blueprint = root.blueprint.Blueprint;
const Pattern = root.blueprint.Pattern;

pub const description = "Enable/disable decay on decayable blocks.";
pub const usage =
	\\/toggledecay <selection/clipboard> <on/off>
;

const Target = enum { selection, clipboard };

const State = enum {
	on,
	off,
};

pub const Args = union(enum) {
	@"/toggledecay <target> <state>": struct {
		target: Target,
		state: State,
	},
};

pub fn execute(args: Args, source: Source) void {
	if (source != .user) {
		source.sendMessage("Command cannot be run without a user", .{});
		return;
	}
	const user = source.user;
	var blueprint: Blueprint = switch (args.@"/toggledecay <target> <state>".target) {
		.selection => blk: {
			const selection = command.getCurrentSelection(user) catch return;
			const blueprint = switch (Blueprint.capture(root.globalAllocator, selection)) {
				.success => |bp| bp,
				.failure => |e| {
					user.sendMessage("#ff0000Error while capturing block {}: {s}. Nothing was modified.", .{e.pos, e.message});
					std.log.warn("Error while capturing block {}: {s}. Nothing was modified.", .{e.pos, e.message});
					return;
				},
			};

			user.worldEditData.undoHistory.push(.init(blueprint, selection.minPos, "toggledecay"));
			user.worldEditData.redoHistory.clear();

			break :blk blueprint.clone(root.stackAllocator);
		},
		.clipboard => user.worldEditData.clipboard orelse {
			return user.sendMessage("#ff0000Clipboard is empty.", .{});
		},
	};

	blueprint.apply(args.@"/toggledecay <target> <state>".state, toggledecay);

	switch (args.@"/toggledecay <target> <state>".target) {
		.selection => {
			const pos1 = user.worldEditData.selectionPosition1.?;
			const pos2 = user.worldEditData.selectionPosition2.?;

			const posStart: Vec3i = @min(pos1, pos2);

			blueprint.paste(posStart, .{.preserveVoid = true});
			blueprint.deinit(root.stackAllocator);

			return user.sendMessage("#00ff00Selection modified. History entry created.", .{});
		},
		.clipboard => {
			return user.sendMessage("#00ff00Clipboard modified.", .{});
		},
	}
}

pub fn toggledecay(decayState: State, current: Block) Block {
	if (current.mode() == root.rotation.getByID("cubyz:branch")) {
		var branchData = root.rotation.rotations.@"cubyz:branch".BranchData.init(current.data);
		branchData.placedByHuman = decayState == .off;
		return .{.typ = current.typ, .data = @as(u7, @bitCast(branchData))};
	}
	if (current.mode() == root.rotation.getByID("cubyz:decayable")) {
		return .{.typ = current.typ, .data = @intFromBool(decayState == .off)};
	}
	return current;
}
