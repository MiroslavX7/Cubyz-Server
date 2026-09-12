const std = @import("std");

const root = @import("root");
const Vec2f = root.vec.Vec2f;

const gui = @import("../gui.zig");
const GuiComponent = gui.GuiComponent;
const GuiWindow = gui.GuiWindow;
const Button = @import("../components/Button.zig");
const Label = GuiComponent.Label;
const TextInput = GuiComponent.TextInput;
const VerticalList = @import("../components/VerticalList.zig");
const FixedSizeCircularBuffer = root.utils.FixedSizeCircularBuffer;

pub var window: GuiWindow = GuiWindow{
	.relativePosition = .{
		.{.attachedToFrame = .{.selfAttachmentPoint = .lower, .otherAttachmentPoint = .lower}},
		.{.attachedToFrame = .{.selfAttachmentPoint = .upper, .otherAttachmentPoint = .upper}},
	},
	.scale = 0.75,
	.contentSize = Vec2f{128, 256},
	.showTitleBar = false,
	.hasBackground = false,
	.isHud = true,
	.hideIfMouseIsGrabbed = false,
	.closeable = false,
};

const padding: f32 = 8;
const messageTimeout: i32 = 10000;
const messageFade = 1000;
const reusableHistoryMaxSize = 8192;

var history: root.ListManaged(*Label) = undefined;
var messageQueue: root.utils.ConcurrentQueue([]const u8) = undefined;
var expirationTime: root.ListManaged(i32) = undefined;
var historyStart: u32 = 0;
var fadeOutEnd: u32 = 0;
pub var input: *TextInput = undefined;
var hideInput: bool = true;
var messageHistory: History = undefined;

pub const History = struct {
	up: FixedSizeCircularBuffer([]const u8, reusableHistoryMaxSize),
	down: FixedSizeCircularBuffer([]const u8, reusableHistoryMaxSize),

	fn init() History {
		return .{
			.up = .init(root.globalAllocator),
			.down = .init(root.globalAllocator),
		};
	}
	fn deinit(self: *History) void {
		self.clear();
		self.up.deinit(root.globalAllocator);
		self.down.deinit(root.globalAllocator);
	}
	fn clear(self: *History) void {
		while (self.up.popFront()) |msg| {
			root.globalAllocator.free(msg);
		}
		while (self.down.popFront()) |msg| {
			root.globalAllocator.free(msg);
		}
	}
	fn flushUp(self: *History) void {
		while (self.down.popBack()) |msg| {
			if (msg.len == 0) {
				continue;
			}

			if (self.up.forcePushBack(msg)) |old| {
				root.globalAllocator.free(old);
			}
		}
	}
	pub fn isDuplicate(self: *History, new: []const u8) bool {
		if (new.len == 0) return true;
		if (self.down.peekBack()) |msg| {
			if (std.mem.eql(u8, msg, new)) return true;
		}
		if (self.up.peekBack()) |msg| {
			if (std.mem.eql(u8, msg, new)) return true;
		}
		return false;
	}
	pub fn pushDown(self: *History, new: []const u8) void {
		if (self.down.forcePushBack(new)) |old| {
			root.globalAllocator.free(old);
		}
	}
	pub fn pushUp(self: *History, new: []const u8) void {
		if (self.up.forcePushBack(new)) |old| {
			root.globalAllocator.free(old);
		}
	}
	pub fn cycleUp(self: *History) bool {
		if (self.down.popBack()) |msg| {
			self.pushUp(msg);
			return true;
		}
		return false;
	}
	pub fn cycleDown(self: *History) void {
		if (self.up.popBack()) |msg| {
			self.pushDown(msg);
		}
	}
};

pub fn clearChat() void {
	while (history.popOrNull()) |label| {
		label.deinit();
	}
	historyStart = 0;
	fadeOutEnd = 0;
	expirationTime.clearRetainingCapacity();
	refresh();
}

pub fn init() void {
	history = .init(root.globalAllocator);
	messageHistory = .init();
	expirationTime = .init(root.globalAllocator);
	messageQueue = .init(root.globalAllocator, 16);
}

pub fn deinit() void {
	for (history.items) |label| {
		label.deinit();
	}
	history.deinit();
	while (messageQueue.popFront()) |msg| {
		root.globalAllocator.free(msg);
	}
	messageHistory.deinit();
	messageQueue.deinit();
	expirationTime.deinit();
}

fn refresh() void {
	if (window.rootComponent) |old| {
		old.verticalList.children.clearRetainingCapacity();
		old.deinit();
	}
	const list = VerticalList.init(.{padding, 16 + padding}, 300, 0);
	for (history.items[if (hideInput) historyStart else 0..]) |msg| {
		msg.pos = .{0, 0};
		list.add(msg);
	}
	if (!hideInput) {
		input.pos = .{0, 0};
		list.add(input);
	}
	list.finish(.center);
	list.scrollBar.currentState = 1;
	window.rootComponent = list.toComponent();
	window.contentSize = window.rootComponent.?.pos() + window.rootComponent.?.size() + @as(Vec2f, @splat(padding));
	window.contentSize[0] = @max(window.contentSize[0], window.getMinWindowWidth());
	gui.updateWindowPositions();
	if (!hideInput) {
		for (history.items) |label| {
			label.alpha = 1;
		}
	} else {
		list.scrollBar.currentState = 1;
		list.scrollBar.size = .{0, 0};
	}
}

pub fn onOpen() void {
	input = TextInput.init(.{0, 0}, 256, 32, "", .{.onNewline = .init(sendMessage), .onUp = .init(loadNextHistoryEntry), .onDown = .init(loadPreviousHistoryEntry)});
	refresh();
}

pub fn loadNextHistoryEntry() void {
	const isSuccess = messageHistory.cycleUp();
	if (messageHistory.isDuplicate(input.currentString.items)) {
		if (isSuccess) messageHistory.cycleDown();
		messageHistory.cycleDown();
	} else {
		messageHistory.pushDown(root.globalAllocator.dupe(u8, input.currentString.items));
		messageHistory.cycleDown();
	}
	const msg = messageHistory.down.peekBack() orelse "";
	input.setString(msg);
}

pub fn loadPreviousHistoryEntry() void {
	_ = messageHistory.cycleUp();
	if (messageHistory.isDuplicate(input.currentString.items)) {} else {
		messageHistory.pushUp(root.globalAllocator.dupe(u8, input.currentString.items));
	}
	const msg = messageHistory.down.peekBack() orelse "";
	input.setString(msg);
}

pub fn onClose() void {
	clearChat();
	while (messageQueue.popFront()) |msg| {
		root.globalAllocator.free(msg);
	}
	messageHistory.clear();
	input.deinit();
	window.rootComponent.?.verticalList.children.clearRetainingCapacity();
	window.rootComponent.?.deinit();
	window.rootComponent = null;
}

pub fn update() void {
	if (!messageQueue.isEmpty()) {
		const currentTime: i32 = @truncate(root.timestamp().toMilliseconds());
		while (messageQueue.popFront()) |msg| {
			history.append(Label.init(.{0, 0}, 256, msg, .left));
			root.globalAllocator.free(msg);
			expirationTime.append(currentTime +% messageTimeout);
		}
		refresh();
	}

	const currentTime: i32 = @truncate(root.timestamp().toMilliseconds());
	while (fadeOutEnd < history.items.len and currentTime -% expirationTime.items[fadeOutEnd] >= 0) {
		fadeOutEnd += 1;
	}
	if (hideInput != root.Window.grabbed) {
		hideInput = root.Window.grabbed;
		refresh();
	}
	if (hideInput) {
		for (expirationTime.items[historyStart..fadeOutEnd], history.items[historyStart..fadeOutEnd]) |time, label| {
			if (currentTime -% time >= messageFade) {
				historyStart += 1;
				refresh();
			} else {
				const timeDifference: f32 = @floatFromInt(currentTime -% time);
				label.alpha = 1.0 - timeDifference/messageFade;
			}
		}
	}
}

pub fn render() void {
	if (!hideInput) {
		const oldColor = root.graphics.draw.setColor(0x80000000);
		defer root.graphics.draw.restoreColor(oldColor);
		root.graphics.draw.rect(.{0, 0}, window.contentSize);
	}
}

pub fn addMessage(msg: []const u8) void {
	messageQueue.pushBack(root.globalAllocator.dupe(u8, msg));
}

pub fn sendMessage() void {
	if (input.currentString.items.len != 0) {
		const data = input.currentString.items;
		if (data.len > 10000 or root.graphics.TextBuffer.Parser.countVisibleCharacters(data) > 1000) {
			std.log.err("Chat message is too long with {}/{} characters. Limits are 1000/10000", .{root.graphics.TextBuffer.Parser.countVisibleCharacters(data), data.len});
		} else {
			messageHistory.flushUp();
			if (!messageHistory.isDuplicate(data)) {
				messageHistory.pushUp(root.globalAllocator.dupe(u8, data));
			}

			if (input.currentString.items[0] == '/') {
				root.sync.client.executeCommand(.{.chatCommand = .{.message = root.globalAllocator.dupe(u8, input.currentString.items[1..])}});
			} else {
				root.network.protocols.chat.send(root.game.world.?.conn, data);
			}
			input.clear();
		}
	}
}
