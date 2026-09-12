const std = @import("std");

const root = @import("root");
const ConnectionManager = root.network.ConnectionManager;
const settings = main.settings;
const Vec2f = main.vec.Vec2f;

const gui = @import("../gui.zig");
const GuiComponent = gui.GuiComponent;
const GuiWindow = gui.GuiWindow;
const Button = @import("../components/Button.zig");
const Label = @import("../components/Label.zig");
const TextInput = @import("../components/TextInput.zig");
const VerticalList = @import("../components/VerticalList.zig");
const HorizontalList = @import("../components/HorizontalList.zig");

pub var window = GuiWindow{
	.contentSize = Vec2f{128, 256},
	.closeIfMouseIsGrabbed = true,
};

const padding: f32 = 8;
var lastLen: usize = 0;
var entityCount: usize = 0;

fn kickbyConnection(conn: *root.network.Connection) void {
	conn.disconnect();
}

fn kickByPlayerIndex(playerIndex: usize) void {
	const command = root.globalAllocator.print("kick @{d}", .{playerIndex});
	root.sync.client.executeCommand(.{.chatCommand = .{.message = command}});
}

pub fn onOpen() void {
	const list = VerticalList.init(.{padding, 16 + padding}, 300, 16);
	if (root.server.world == null) blk: {
		entityCount = root.client.entity_manager.entities.len;
		if (entityCount == 0) {
			list.add(Label.init(.{0, 0}, 200, "No other players", .left));
			break :blk;
		}

		for (root.client.entity_manager.entities.items()) |ent| {
			const playerComponent = root.entity.components.@"cubyz:player".client.get(ent.id) orelse continue;
			const row = HorizontalList.init();

			const string = root.stackAllocator.print("{f}", .{std.fmt.alt(ent, .formatWithPlayerIndex)});
			defer root.stackAllocator.free(string);
			row.add(Label.init(.{0, 0}, 200, string, .left));
			row.add(Button.initText(.{0, 0}, 100, "Kick", .{.onAction = .initWithInt(kickByPlayerIndex, playerComponent.playerIndex)}));
			list.add(row);
		}
	} else {
		root.server.connectionManager.mutex.lock();
		defer root.server.connectionManager.mutex.unlock();
		std.debug.assert(lastLen == 0);
		lastLen = root.server.connectionManager.connections.items.len;
		for (root.server.connectionManager.connections.items) |connection| {
			const user = connection.user.?;
			if (user.id == main.game.Player.id and connection.isConnected()) continue;
			const row = HorizontalList.init();
			if (connection.handShakeState.load(.monotonic) == .complete) {
				const string = root.stackAllocator.print("{f}", .{connection.user.?});
				defer root.stackAllocator.free(string);
				row.add(Label.init(.{0, 0}, 200, string, .left));
				row.add(Button.initText(.{0, 0}, 100, "Kick", .{.onAction = .initWithPtr(kickbyConnection, connection)}));
			} else {
				const ip = root.stackAllocator.print("{f}", .{connection.remoteAddress});
				defer root.stackAllocator.free(ip);
				row.add(Label.init(.{0, 0}, 200, ip, .left));
				row.add(Button.initText(.{0, 0}, 100, "Cancel", .{.onAction = .initWithPtr(kickbyConnection, connection)}));
			}
			list.add(row);
		}
		if (lastLen == 1) {
			list.add(Label.init(.{0, 0}, 200, "No other players", .left));
		}
	}
	list.finish(.center);
	window.rootComponent = list.toComponent();
	window.contentSize = window.rootComponent.?.pos() + window.rootComponent.?.size() + @as(Vec2f, @splat(padding));
	gui.updateWindowPositions();
}

pub fn onClose() void {
	if (root.server.world != null) {
		lastLen = 0;
	}
	if (window.rootComponent) |*comp| {
		comp.deinit();
	}
}

pub fn update() void {
	if (root.server.world == null) {
		if (root.client.entity_manager.entities.len != entityCount) {
			onClose();
			onOpen();
		}
	} else {
		root.server.connectionManager.mutex.lock();
		const serverListLen = root.server.connectionManager.connections.items.len;
		root.server.connectionManager.mutex.unlock();
		if (lastLen != serverListLen) {
			onClose();
			onOpen();
		}
	}
}
