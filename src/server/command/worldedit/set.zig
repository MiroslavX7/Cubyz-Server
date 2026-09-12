const std = @import("std");

const root = @import("root");
const command = root.server.command;
const Source = command.Source;
const Vec3i = root.vec.Vec3i;

const Block = root.blocks.Block;
const Blueprint = root.blueprint.Blueprint;
const Pattern = root.blueprint.Pattern;

pub const description = "Set all blocks within selection to a block.";
pub const usage = "/set <pattern>";

pub const Args = union(enum) {
	@"/set": struct { pattern: command.PatternExpression },
};

pub fn execute(args: Args, source: Source) void {
	if (source != .user) {
		source.sendMessage("Command cannot be run without a user", .{});
		return;
	}
	const user = source.user;
	const selection = command.getCurrentSelection(user) catch return;

	const result = Blueprint.capture(root.globalAllocator, selection);

	switch (result) {
		.success => |blueprint| {
			user.worldEditData.undoHistory.push(.init(blueprint, selection.minPos, "set"));
			user.worldEditData.redoHistory.clear();

			var modifiedBlueprint = blueprint.clone(root.stackAllocator);
			defer modifiedBlueprint.deinit(root.stackAllocator);

			modifiedBlueprint.replace(null, user.worldEditData.mask, args.@"/set".pattern.pattern);
			modifiedBlueprint.paste(selection.minPos, .{.preserveVoid = true});
		},
		.failure => |err| {
			user.sendMessage("#ff0000Error: Could not capture selection. (at {}, {s})", .{err.pos, err.message});
		},
	}
}
