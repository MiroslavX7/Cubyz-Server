const std = @import("std");

const root = @import("root");
const Vec2f = root.vec.Vec2f;

const c = @import("c");

const gui = @import("../gui.zig");
const GuiComponent = gui.GuiComponent;
const GuiWindow = gui.GuiWindow;
const Button = @import("../components/Button.zig");
const CheckBox = @import("../components/CheckBox.zig");
const HorizontalList = @import("../components/HorizontalList.zig");
const Label = @import("../components/Label.zig");
const VerticalList = @import("../components/VerticalList.zig");
const ContinuousSlider = @import("../components/ContinuousSlider.zig");

pub var window = GuiWindow{
	.contentSize = Vec2f{128, 192},
	.closeIfMouseIsGrabbed = true,
};

const padding: f32 = 8;
var selectedKey: ?*root.Window.Key = null;
var editingKeyboard: bool = true;
var needsUpdate: bool = false;
fn keyFunction(key: *root.Window.Key) void {
	root.Window.setNextKeypressListener(&keypressListener) catch return;
	selectedKey = key;
	needsUpdate = true;
}
fn keypressListener(key: c_int, mouseButton: c_int, scancode: c_int) void {
	selectedKey.?.key = key;
	selectedKey.?.mouseButton = mouseButton;
	selectedKey.?.scancode = scancode;
	selectedKey = null;
	needsUpdate = true;
	root.settings.save();
}

fn gamepadFunction(key: *root.Window.Key) void {
	root.Window.setNextGamepadListener(&gamepadListener) catch return;
	selectedKey = key;
	needsUpdate = true;
}
fn gamepadListener(axis: ?root.Window.GamepadAxis, btn: c_int) void {
	selectedKey.?.gamepadAxis = axis;
	selectedKey.?.gamepadButton = btn;
	selectedKey = null;
	needsUpdate = true;
	root.settings.save();
}
fn updateSensitivity(sensitivity: f32) void {
	if (editingKeyboard) {
		root.settings.mouseSensitivity = sensitivity;
	} else {
		root.settings.controllerSensitivity = sensitivity;
	}
	root.settings.save();
}

fn invertMouseYCallback(newValue: bool) void {
	root.settings.invertMouseY = newValue;
	root.settings.save();
}
fn sprintIsToggleCallback(newValue: bool) void {
	root.KeyBoard.setIsToggling("sprint", newValue);
	root.settings.save();
}

fn updateDeadzone(deadzone: f32) void {
	root.settings.controllerAxisDeadzone = deadzone;
}

fn deadzoneFormatter(allocator: root.heap.NeverFailingAllocator, value: f32) []const u8 {
	return allocator.print("Deadzone: {d:.0}%", .{value*100});
}

fn sensitivityFormatter(allocator: root.heap.NeverFailingAllocator, value: f32) []const u8 {
	return allocator.print("{s} Sensitivity: {d:.0}%", .{if (editingKeyboard) "Mouse" else "Controller", value*100});
}

fn abortBindingProcess() void {
	selectedKey = null;
	root.Window.resetNextInputListenters();
	needsUpdate = true;
}

fn toggleKeyboard() void {
	editingKeyboard = !editingKeyboard;
	abortBindingProcess();
}

fn unbindKey(keyPtr: usize) void {
	var key: ?*root.Window.Key = @ptrFromInt(keyPtr);
	if (editingKeyboard) {
		key.?.key = c.GLFW_KEY_UNKNOWN;
		key.?.mouseButton = -1;
		key.?.scancode = 0;
	} else {
		key.?.gamepadAxis = null;
		key.?.gamepadButton = -1;
	}
	needsUpdate = true;
}

fn initWindow() void {
	const controlsListWidth: u32 = 256;
	const keybindButtonWidth: u32 = 160;
	const unbindButtonWidth: u32 = 64;

	const list = VerticalList.init(.{padding, 16 + padding}, 364, 8);
	list.add(Button.initText(.{0, 0}, keybindButtonWidth, if (editingKeyboard) "Gamepad" else "Keyboard", .{.onAction = .init(toggleKeyboard)}));
	list.add(ContinuousSlider.init(.{0, 0}, controlsListWidth, 0, 5, if (editingKeyboard) root.settings.mouseSensitivity else root.settings.controllerSensitivity, &updateSensitivity, &sensitivityFormatter));
	list.add(CheckBox.init(.{0, 0}, controlsListWidth, "Invert mouse Y", root.settings.invertMouseY, &invertMouseYCallback));
	list.add(CheckBox.init(.{0, 0}, controlsListWidth, "Toggle sprint", root.KeyBoard.key("sprint").isToggling == .yes, &sprintIsToggleCallback));

	if (!editingKeyboard) {
		list.add(ContinuousSlider.init(.{0, 0}, controlsListWidth, 0, 1, root.settings.controllerAxisDeadzone, &updateDeadzone, &deadzoneFormatter));
	}
	for (&root.KeyBoard.keys) |*key| {
		const label = Label.init(.{0, 0}, keybindButtonWidth, key.name, .left);
		const button = blk: {
			if (key == selectedKey) {
				break :blk Button.initText(.{16, 0}, keybindButtonWidth, "...", .{});
			} else if (editingKeyboard) {
				break :blk Button.initText(.{16, 0}, keybindButtonWidth, key.getName(), .{.onAction = .initWithPtr(keyFunction, key)});
			} else {
				break :blk Button.initText(.{16, 0}, keybindButtonWidth, key.getGamepadName(), .{.onAction = .initWithPtr(gamepadFunction, key)});
			}
		};

		const unbindBtn = Button.initText(.{16, 0}, unbindButtonWidth, "Unbind", .{.onAction = .initWithPtr(unbindKey, key)});
		const row = HorizontalList.init();
		row.add(label);
		row.add(button);
		row.add(unbindBtn);
		row.finish(.{0, 0}, .center);
		list.add(row);
	}
	list.finish(.center);
	window.rootComponent = list.toComponent();
	window.contentSize = window.rootComponent.?.pos() + window.rootComponent.?.size() + @as(Vec2f, @splat(padding));
	gui.updateWindowPositions();
}

fn deinitWindow() void {
	if (window.rootComponent) |*comp| {
		comp.deinit();
	}
}

pub fn onOpen() void {
	abortBindingProcess();
	initWindow();
}

pub fn onClose() void {
	abortBindingProcess();
	deinitWindow();
}

pub fn render() void {
	if (needsUpdate) {
		needsUpdate = false;
		const oldScroll = window.rootComponent.?.verticalList.scrollBar.currentState;
		deinitWindow();
		initWindow();
		window.rootComponent.?.verticalList.scrollBar.currentState = oldScroll;
	}
}
