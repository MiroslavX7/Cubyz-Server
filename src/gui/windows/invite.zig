const std = @import("std");

const root = @import("root");
const ConnectionManager = root.network.ConnectionManager;
const settings = root.settings;
const Vec2f = root.vec.Vec2f;

const gui = @import("../gui.zig");
const GuiComponent = gui.GuiComponent;
const GuiWindow = gui.GuiWindow;
const Button = @import("../components/Button.zig");
const CheckBox = @import("../components/CheckBox.zig");
const Label = @import("../components/Label.zig");
const TextInput = @import("../components/TextInput.zig");
const VerticalList = @import("../components/VerticalList.zig");

pub var window = GuiWindow{
	.contentSize = Vec2f{128, 256},
};

var ipAddressLabel: *Label = undefined;
var ipAddressEntry: *TextInput = undefined;

const padding: f32 = 8;

var ipAddress: []const u8 = "";
var gotIpAddress: std.atomic.Value(bool) = .init(false);
var thread: ?std.Thread = null;
const width: f32 = 420;

fn discoverIpAddress() void {
	root.server.connectionManager.makeOnline();
	ipAddress = root.globalAllocator.print("{f}", .{root.server.connectionManager.externalAddress});
	gotIpAddress.store(true, .release);
}

fn discoverIpAddressFromNewThread() void {
	root.initThreadLocals();
	defer root.deinitThreadLocals();

	discoverIpAddress();
}

fn invite() void {
	if (thread) |_thread| {
		_thread.join();
		thread = null;
	}
	_ = root.server.User.init(root.server.connectionManager, ipAddressEntry.currentString.items) catch |err| {
		if (err != error.AlreadyConnected) {
			std.log.err("Cannot connect user: {s}", .{@errorName(err)});
		}
		return;
	};
}

fn copyIp() void {
	root.Window.setClipboardString(ipAddress);
}

pub fn onOpen() void {
	const list = VerticalList.init(.{padding, 16 + padding}, 260, 16);
	list.add(Label.init(.{0, 0}, width, "Please send your IP to the player who wants to join and enter their IP below.", .center));
	//                                           255.255.255.255:?65536 (longest possible ip address)
	ipAddressLabel = Label.init(.{0, 0}, width, "                      ", .center);
	list.add(ipAddressLabel);
	list.add(Button.initText(.{0, 0}, 100, "Copy IP", .{.onAction = .init(copyIp)}));
	ipAddressEntry = TextInput.init(.{0, 0}, width, 32, settings.lastUsedIPAddress, .{.onNewline = .init(invite)});
	ipAddressEntry.obfuscated = root.settings.streamerMode;
	list.add(ipAddressEntry);
	list.add(Button.initText(.{0, 0}, 100, "Invite", .{.onAction = .init(invite)}));
	list.finish(.center);
	window.rootComponent = list.toComponent();
	window.contentSize = window.rootComponent.?.pos() + window.rootComponent.?.size() + @as(Vec2f, @splat(padding));
	gui.updateWindowPositions();

	thread = std.Thread.spawn(.{}, discoverIpAddressFromNewThread, .{}) catch |err| blk: {
		std.log.err("Error spawning thread: {s}. Doing it in the current thread instead.", .{@errorName(err)});
		discoverIpAddress();
		break :blk null;
	};
}

pub fn onClose() void {
	if (thread) |_thread| {
		_thread.join();
		thread = null;
	}
	if (ipAddress.len != 0) {
		root.globalAllocator.free(ipAddress);
		ipAddress = "";
	}

	if (window.rootComponent) |*comp| {
		comp.deinit();
	}
}

pub fn update() void {
	if (gotIpAddress.load(.acquire)) {
		gotIpAddress.store(false, .monotonic);

		if (root.settings.streamerMode) {
			const obfuscatedIp = root.utils.obfuscateString(root.stackAllocator, ipAddress);
			defer root.stackAllocator.free(obfuscatedIp);
			ipAddressLabel.updateText(obfuscatedIp);
		} else {
			ipAddressLabel.updateText(ipAddress);
		}
	}
}
