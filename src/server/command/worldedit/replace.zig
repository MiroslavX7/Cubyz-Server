const std = @import("std");

const root = @import("root");
const command = root.server.command;
const Source = command.Source;
const Vec3i = root.vec.Vec3i;

const Block = root.blocks.Block;
const Blueprint = root.blueprint.Blueprint;
const Pattern = root.blueprint.Pattern;
const Mask = root.blueprint.Mask;

pub const description = "Replace blocks in the world edit selection.";
pub const usage = "/replace <old mask> <new pattern>";

pub const Args = union(enum) {
	@"/replace <old mask> <new pattern>": struct {
		oldMask: command.MaskExpression,
		newPattern: command.PatternExpression,
	},
};

pub fn execute(args: Args, source: Source) void {
	if (source != .user) {
		source.sendMessage("Command cannot be run without a user", .{});
		return;
	}
	const user = source.user;
	const selection = command.getCurrentSelection(user) catch return;
	const capture = Blueprint.capture(root.globalAllocator, selection);

	switch (capture) {
		.success => |blueprint| {
			user.worldEditData.undoHistory.push(.init(blueprint, selection.minPos, "replace"));
			user.worldEditData.redoHistory.clear();

			var modifiedBlueprint = blueprint.clone(root.stackAllocator);
			defer modifiedBlueprint.deinit(root.stackAllocator);

			modifiedBlueprint.replace(args.@"/replace <old mask> <new pattern>".oldMask.mask, null, args.@"/replace <old mask> <new pattern>".newPattern.pattern);
			modifiedBlueprint.paste(selection.minPos, .{.preserveVoid = true});
		},
		.failure => |err| {
			user.sendMessage("#ff0000Error: Could not capture selection. (at {}, {s})", .{err.pos, err.message});
		},
	}
}
