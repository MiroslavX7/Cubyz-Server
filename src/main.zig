const std = @import("std");
const builtin = @import("builtin");

pub const gui = @import("gui/gui.zig");
pub const server = @import("server/server.zig");
pub const config = @import("config.zig");

pub const audio = @import("audio.zig");
pub const argparse = @import("argparse.zig");
pub const assets = @import("assets.zig");
pub const block_entity = @import("block_entity.zig");
pub const blocks = @import("blocks.zig");
pub const blueprint = @import("blueprint.zig");
const c = @import("c");
pub const callbacks = @import("callbacks/callbacks.zig");
pub const chunk = @import("chunk.zig");
pub const client = @import("client.zig");
pub const entity = @import("entity.zig");
pub const entityModel = @import("entityModel.zig");
pub const files = @import("files.zig");
pub const fmt = @import("fmt.zig");
pub const game = @import("game.zig");
pub const graphics = @import("graphics.zig");
pub const itemdrop = @import("itemdrop.zig");
pub const items = @import("items.zig");
pub const log = @import("log.zig");
pub const meta = @import("meta.zig");
pub const migrations = @import("migrations.zig");
pub const models = @import("models.zig");
pub const network = @import("network.zig");
pub const particles = @import("particles.zig");
pub const physics = @import("physics.zig");
pub const random = @import("random.zig");
pub const renderer = @import("renderer.zig");
pub const rotation = @import("rotation.zig");
pub const settings = @import("settings.zig");
pub const sync = @import("sync.zig");
pub const systems = @import("systems.zig");
const tag = @import("tag.zig");
pub const Tag = tag.Tag;
pub const utils = @import("utils.zig");
pub const vec = @import("vec.zig");
const zon = @import("zon.zig");
pub const ZonElement = zon.ZonElement;

const file_monitor = utils.file_monitor;

const Vec2f = vec.Vec2f;
const Vec3d = vec.Vec3d;

pub const Window = @import("graphics/Window.zig");

pub const heap = @import("utils/heap.zig");

pub const ListManaged = utils.list.ListManaged;
pub const List = utils.list.List;
pub const MultiArray = utils.list.MultiArray;

pub threadlocal var stackAllocator: heap.NeverFailingAllocator = if (builtin.is_test) heap.testingAllocator else undefined;
pub threadlocal var seed: u64 = undefined;
threadlocal var stackAllocatorBase: heap.StackAllocator = undefined;
pub const globalAllocator: heap.NeverFailingAllocator = if (builtin.is_test) heap.testingAllocator else heap.allocators.handledGpa.allocator();
pub const globalArena = heap.allocators.globalArenaAllocator.allocator();
pub const worldArena = heap.allocators.worldArenaAllocator.allocator();
pub var threadPool: *utils.ThreadPool = undefined;
var threadedIo: std.Io.Threaded = undefined;
pub var io: std.Io = threadedIo.io();

pub fn initThreadLocals() void {
	seed = @bitCast(@as(i64, @truncate(timestamp().nanoseconds)));
	stackAllocatorBase = heap.StackAllocator.init(globalAllocator, 1 << 23);
	stackAllocator = stackAllocatorBase.allocator();
	heap.GarbageCollection.addThread();
}

pub fn deinitThreadLocals() void {
	stackAllocatorBase.deinit();
	heap.GarbageCollection.removeThread();
}

pub fn timestamp() std.Io.Timestamp {
	return std.Io.Clock.Timestamp.now(io, .awake).raw;
}

// overwrite the log function:
pub const std_options: std.Options = .{ // MARK: std_options
	.log_level = .debug,
	.logFn = log.logFn,
};

// MARK: Callbacks
fn escape(mods: Window.Key.Modifiers) void {
	if (gui.selectedTextInput != null) gui.setSelectedTextInput(null);
	inventory(mods);
}
fn inventory(_: Window.Key.Modifiers) void {
	if (game.world == null) return;
	gui.openWindow("inventory");
	gui.openWindow("hotbar");
	gui.toggleGameMenu();
}
fn ungrabMouse(_: Window.Key.Modifiers) void {
	if (Window.grabbed) {
		gui.toggleGameMenu();
	}
}
fn openCreativeInventory(mods: Window.Key.Modifiers) void {
	if (game.world == null) return;
	if (!game.Player.isCreative()) return;
	ungrabMouse(mods);
	gui.openWindow("creative_inventory");
}
fn openChat(mods: Window.Key.Modifiers) void {
	if (!gui.isWindowOpen("chat")) return;
	ungrabMouse(mods);
	gui.openWindow("chat");
	gui.windowlist.chat.input.select();
}
fn openCommand(mods: Window.Key.Modifiers) void {
	if (!gui.isWindowOpen("chat")) return;
	openChat(mods);
	gui.windowlist.chat.input.clear();
	gui.windowlist.chat.input.inputCharacter('/');
}
fn takeBackgroundImageFn(_: Window.Key.Modifiers) void {
	if (game.world == null) return;

	const oldHideGui = gui.hideGui;
	gui.hideGui = true;
	const oldShowItem = itemdrop.ItemDisplayManager.showItem;
	itemdrop.ItemDisplayManager.showItem = false;

	renderer.MenuBackGround.takeBackgroundImage();

	gui.hideGui = oldHideGui;
	itemdrop.ItemDisplayManager.showItem = oldShowItem;
}
fn toggleHideGui(_: Window.Key.Modifiers) void {
	gui.hideGui = !gui.hideGui;
}
fn toggleHideDisplayItem(_: Window.Key.Modifiers) void {
	itemdrop.ItemDisplayManager.showItem = !itemdrop.ItemDisplayManager.showItem;
}
fn toggleDebugOverlay(_: Window.Key.Modifiers) void {
	gui.toggleWindow("debug");
}
fn togglePerformanceOverlay(_: Window.Key.Modifiers) void {
	gui.toggleWindow("performance_graph");
}
fn toggleGPUPerformanceOverlay(_: Window.Key.Modifiers) void {
	gui.toggleWindow("gpu_performance_measuring");
}
fn toggleNetworkDebugOverlay(_: Window.Key.Modifiers) void {
	gui.toggleWindow("debug_network");
}
fn toggleAdvancedNetworkDebugOverlay(_: Window.Key.Modifiers) void {
	gui.toggleWindow("debug_network_advanced");
}
fn toggleVulkanDebugOverlay(_: Window.Key.Modifiers) void {
	gui.toggleWindow("debug_vulkan_info");
}
fn cycleHotbarSlot(i: comptime_int) *const fn (Window.Key.Modifiers) void {
	return &struct {
		fn set(_: Window.Key.Modifiers) void {
			game.Player.selectedSlot = @intCast(@mod(@as(i33, game.Player.selectedSlot) + i, 12));
		}
	}.set;
}
fn setHotbarSlot(i: comptime_int) *const fn (Window.Key.Modifiers) void {
	return &struct {
		fn set(_: Window.Key.Modifiers) void {
			if (gui.hoveredItemSlot) |hovered| {
				if (hovered.inventory.type == .crafting or hovered.inventory.type == .workbenchResult) return;
				hovered.inventory.swap(hovered.itemSlot, game.Player.inventory, i - 1);
				return;
			}
			game.Player.selectedSlot = i - 1;
		}
	}.set;
}

pub const KeyBoard = struct { // MARK: KeyBoard
	pub var keys = [_]Window.Key{
		// Gameplay:
		.{.name = "forward", .key = c.GLFW_KEY_W, .gamepadAxis = .{.axis = c.GLFW_GAMEPAD_AXIS_LEFT_Y, .positive = false}},
		.{.name = "left", .key = c.GLFW_KEY_A, .gamepadAxis = .{.axis = c.GLFW_GAMEPAD_AXIS_LEFT_X, .positive = false}},
		.{.name = "backward", .key = c.GLFW_KEY_S, .gamepadAxis = .{.axis = c.GLFW_GAMEPAD_AXIS_LEFT_Y, .positive = true}},
		.{.name = "right", .key = c.GLFW_KEY_D, .gamepadAxis = .{.axis = c.GLFW_GAMEPAD_AXIS_LEFT_X, .positive = true}},
		.{.name = "sprint", .key = c.GLFW_KEY_LEFT_CONTROL, .gamepadButton = c.GLFW_GAMEPAD_BUTTON_LEFT_THUMB, .isToggling = .no},
		.{.name = "jump", .key = c.GLFW_KEY_SPACE, .gamepadButton = c.GLFW_GAMEPAD_BUTTON_A},
		.{.name = "crouch", .key = c.GLFW_KEY_LEFT_SHIFT, .gamepadButton = c.GLFW_GAMEPAD_BUTTON_RIGHT_THUMB},
		.{.name = "fly", .key = c.GLFW_KEY_F, .gamepadButton = c.GLFW_GAMEPAD_BUTTON_DPAD_DOWN, .pressAction = &game.flyToggle},
		.{.name = "ghost", .key = c.GLFW_KEY_G, .pressAction = &game.ghostToggle},
		.{.name = "hyperSpeed", .key = c.GLFW_KEY_H, .pressAction = &game.hyperSpeedToggle},
		.{.name = "fall", .key = c.GLFW_KEY_LEFT_SHIFT, .gamepadButton = c.GLFW_GAMEPAD_BUTTON_RIGHT_THUMB},
		.{.name = "placeBlock", .mouseButton = c.GLFW_MOUSE_BUTTON_RIGHT, .gamepadAxis = .{.axis = c.GLFW_GAMEPAD_AXIS_LEFT_TRIGGER}, .pressAction = &game.pressPlace, .releaseAction = &game.releasePlace, .notifyRequirement = .inGame},
		.{.name = "breakBlock", .mouseButton = c.GLFW_MOUSE_BUTTON_LEFT, .gamepadAxis = .{.axis = c.GLFW_GAMEPAD_AXIS_RIGHT_TRIGGER}, .pressAction = &game.pressBreak, .releaseAction = &game.releaseBreak, .notifyRequirement = .inGame},
		.{.name = "acquireSelectedBlock", .mouseButton = c.GLFW_MOUSE_BUTTON_MIDDLE, .gamepadButton = c.GLFW_GAMEPAD_BUTTON_DPAD_LEFT, .pressAction = &game.pressAcquireSelectedBlock, .notifyRequirement = .inGame},
		.{.name = "drop", .key = c.GLFW_KEY_Q, .repeatAction = &game.Player.dropFromHand, .notifyRequirement = .inGame},

		.{.name = "takeBackgroundImage", .key = c.GLFW_KEY_PRINT_SCREEN, .pressAction = &takeBackgroundImageFn},
		.{.name = "fullscreen", .key = c.GLFW_KEY_F11, .pressAction = &Window.toggleFullscreen},

		// Gui:
		.{.name = "escape", .key = c.GLFW_KEY_ESCAPE, .pressAction = &escape, .gamepadButton = c.GLFW_GAMEPAD_BUTTON_B},
		.{.name = "openInventory", .key = c.GLFW_KEY_E, .pressAction = &escape, .gamepadButton = c.GLFW_GAMEPAD_BUTTON_X},
		.{.name = "openCreativeInventory(aka cheat inventory)", .key = c.GLFW_KEY_C, .pressAction = &openCreativeInventory, .gamepadButton = c.GLFW_GAMEPAD_BUTTON_Y},
		.{.name = "openChat", .key = c.GLFW_KEY_T, .releaseAction = &openChat},
		.{.name = "openCommand", .key = c.GLFW_KEY_SLASH, .releaseAction = &openCommand},
		.{.name = "mainGuiButton", .mouseButton = c.GLFW_MOUSE_BUTTON_LEFT, .pressAction = &gui.mainButtonPressed, .releaseAction = &gui.mainButtonReleased, .gamepadButton = c.GLFW_GAMEPAD_BUTTON_A, .notifyRequirement = .inMenu},
		.{.name = "secondaryGuiButton", .mouseButton = c.GLFW_MOUSE_BUTTON_RIGHT, .pressAction = &gui.secondaryButtonPressed, .releaseAction = &gui.secondaryButtonReleased, .gamepadButton = c.GLFW_GAMEPAD_BUTTON_Y, .notifyRequirement = .inMenu},
		// gamepad gui.
		.{.name = "scrollUp", .gamepadAxis = .{.axis = c.GLFW_GAMEPAD_AXIS_RIGHT_Y, .positive = false}},
		.{.name = "scrollDown", .gamepadAxis = .{.axis = c.GLFW_GAMEPAD_AXIS_RIGHT_Y, .positive = true}},
		.{.name = "uiUp", .gamepadAxis = .{.axis = c.GLFW_GAMEPAD_AXIS_LEFT_Y, .positive = false}},
		.{.name = "uiLeft", .gamepadAxis = .{.axis = c.GLFW_GAMEPAD_AXIS_LEFT_X, .positive = false}},
		.{.name = "uiDown", .gamepadAxis = .{.axis = c.GLFW_GAMEPAD_AXIS_LEFT_Y, .positive = true}},
		.{.name = "uiRight", .gamepadAxis = .{.axis = c.GLFW_GAMEPAD_AXIS_LEFT_X, .positive = true}},
		// text:
		.{.name = "textCursorLeft", .key = c.GLFW_KEY_LEFT, .repeatAction = &gui.textCallbacks.left},
		.{.name = "textCursorRight", .key = c.GLFW_KEY_RIGHT, .repeatAction = &gui.textCallbacks.right},
		.{.name = "textCursorDown", .key = c.GLFW_KEY_DOWN, .repeatAction = &gui.textCallbacks.down},
		.{.name = "textCursorUp", .key = c.GLFW_KEY_UP, .repeatAction = &gui.textCallbacks.up},
		.{.name = "textGotoStart", .key = c.GLFW_KEY_HOME, .repeatAction = &gui.textCallbacks.gotoStart},
		.{.name = "textGotoEnd", .key = c.GLFW_KEY_END, .repeatAction = &gui.textCallbacks.gotoEnd},
		.{.name = "textDeleteLeft", .key = c.GLFW_KEY_BACKSPACE, .repeatAction = &gui.textCallbacks.deleteLeft},
		.{.name = "textDeleteRight", .key = c.GLFW_KEY_DELETE, .repeatAction = &gui.textCallbacks.deleteRight},
		.{.name = "textSelectAll", .key = c.GLFW_KEY_A, .repeatAction = &gui.textCallbacks.selectAll, .requiredModifiers = .{.control = true}},
		.{.name = "textCopy", .key = c.GLFW_KEY_C, .repeatAction = &gui.textCallbacks.copy, .requiredModifiers = .{.control = true}},
		.{.name = "textPaste", .key = c.GLFW_KEY_V, .repeatAction = &gui.textCallbacks.paste, .requiredModifiers = .{.control = true}},
		.{.name = "textCut", .key = c.GLFW_KEY_X, .repeatAction = &gui.textCallbacks.cut, .requiredModifiers = .{.control = true}},
		.{.name = "textNewline", .key = c.GLFW_KEY_ENTER, .repeatAction = &gui.textCallbacks.newline},

		// Hotbar shortcuts:
		.{.name = "Hotbar 1", .key = c.GLFW_KEY_1, .pressAction = setHotbarSlot(1)},
		.{.name = "Hotbar 2", .key = c.GLFW_KEY_2, .pressAction = setHotbarSlot(2)},
		.{.name = "Hotbar 3", .key = c.GLFW_KEY_3, .pressAction = setHotbarSlot(3)},
		.{.name = "Hotbar 4", .key = c.GLFW_KEY_4, .pressAction = setHotbarSlot(4)},
		.{.name = "Hotbar 5", .key = c.GLFW_KEY_5, .pressAction = setHotbarSlot(5)},
		.{.name = "Hotbar 6", .key = c.GLFW_KEY_6, .pressAction = setHotbarSlot(6)},
		.{.name = "Hotbar 7", .key = c.GLFW_KEY_7, .pressAction = setHotbarSlot(7)},
		.{.name = "Hotbar 8", .key = c.GLFW_KEY_8, .pressAction = setHotbarSlot(8)},
		.{.name = "Hotbar 9", .key = c.GLFW_KEY_9, .pressAction = setHotbarSlot(9)},
		.{.name = "Hotbar 10", .key = c.GLFW_KEY_0, .pressAction = setHotbarSlot(10)},
		.{.name = "Hotbar 11", .key = c.GLFW_KEY_MINUS, .pressAction = setHotbarSlot(11)},
		.{.name = "Hotbar 12", .key = c.GLFW_KEY_EQUAL, .pressAction = setHotbarSlot(12)},
		.{.name = "Hotbar left", .gamepadButton = c.GLFW_GAMEPAD_BUTTON_LEFT_BUMPER, .pressAction = cycleHotbarSlot(-1)},
		.{.name = "Hotbar right", .gamepadButton = c.GLFW_GAMEPAD_BUTTON_RIGHT_BUMPER, .pressAction = cycleHotbarSlot(1)},
		.{.name = "cameraLeft", .gamepadAxis = .{.axis = c.GLFW_GAMEPAD_AXIS_RIGHT_X, .positive = false}},
		.{.name = "cameraRight", .gamepadAxis = .{.axis = c.GLFW_GAMEPAD_AXIS_RIGHT_X, .positive = true}},
		.{.name = "cameraUp", .gamepadAxis = .{.axis = c.GLFW_GAMEPAD_AXIS_RIGHT_Y, .positive = false}},
		.{.name = "cameraDown", .gamepadAxis = .{.axis = c.GLFW_GAMEPAD_AXIS_RIGHT_Y, .positive = true}},
		// debug:
		.{.name = "hideMenu", .key = c.GLFW_KEY_F1, .pressAction = &toggleHideGui},
		.{.name = "hideDisplayItem", .key = c.GLFW_KEY_F2, .pressAction = &toggleHideDisplayItem},
		.{.name = "debugOverlay", .key = c.GLFW_KEY_F3, .pressAction = &toggleDebugOverlay},
		.{.name = "performanceOverlay", .key = c.GLFW_KEY_F4, .pressAction = &togglePerformanceOverlay},
		.{.name = "gpuPerformanceOverlay", .key = c.GLFW_KEY_F5, .pressAction = &toggleGPUPerformanceOverlay},
		.{.name = "networkDebugOverlay", .key = c.GLFW_KEY_F6, .pressAction = &toggleNetworkDebugOverlay},
		.{.name = "advancedNetworkDebugOverlay", .key = c.GLFW_KEY_F7, .pressAction = &toggleAdvancedNetworkDebugOverlay},
		.{.name = "vulkanDebugOverlay", .key = c.GLFW_KEY_F8, .pressAction = &toggleVulkanDebugOverlay},
	};

	fn findKey(name: []const u8) ?*Window.Key { // TODO: Maybe I should use a hashmap here?
		for (&keys) |*_key| {
			if (std.mem.eql(u8, name, _key.name)) {
				return _key;
			}
		}
		return null;
	}
	pub fn key(name: []const u8) *const Window.Key {
		return findKey(name) orelse {
			std.log.err("Couldn't find keyboard key with name {s}", .{name});
			return &.{.name = ""};
		};
	}
	pub fn setIsToggling(name: []const u8, value: bool) void {
		if (findKey(name)) |theKey| {
			if (theKey.isToggling == .never) {
				std.log.err("Tried setting toggling on non-toggling key with name {s}", .{name});
				return;
			}
			theKey.isToggling = if (value) .yes else .no;
			if (!value) {
				theKey.pressed = false;
			}
		} else {
			std.log.err("Couldn't find keyboard key to toggle with name {s}", .{name});
		}
	}
};

/// Records gpu time per frame.
pub var lastFrameTime = std.atomic.Value(f64).init(0);
/// Measures time between different frames' beginnings.
pub var lastDeltaTime = std.atomic.Value(f64).init(0);

var shouldExitToMenu = std.atomic.Value(bool).init(false);

pub fn exitToMenu() void {
	shouldExitToMenu.store(true, .monotonic);
}

/// Dedicated server entry point. Runs a headless server without GUI or local player.
/// The server accepts commands from stdin and manages multiplayer connections.
/// Automatically creates configuration files and world folders if they don't exist.
pub fn main(args: std.process.Init.Minimal) void { // MARK: main()
	defer heap.allocators.deinit();
	defer heap.GarbageCollection.assertAllThreadsStopped();
	initThreadLocals();
	defer deinitThreadLocals();
	threadedIo = .init(globalAllocator.allocator, .{});
	defer threadedIo.deinit();

	log.init();
	defer log.deinit();

	// Declare serverConfig at function scope to be accessible throughout main
	var serverConfig: config.ServerConfig = undefined;

	argCheck: {
		var argIterator = args.args.iterateAllocator(stackAllocator.allocator) catch |err| {
			std.log.err("Failed to read command line arguments: {s}", .{@errorName(err)});
			break :argCheck;
		};
		defer argIterator.deinit();
		_ = argIterator.skip();
		
		// Collect all arguments for config parsing (skip first arg which is program name)
		var argList = std.ArrayList([]const u8).initCapacity(stackAllocator.allocator, 16) catch unreachable;
		while (argIterator.next()) |arg| {
			argList.appendAssumeCapacity(arg);
		}
		const argSlice = argList.items;
		
		if (argSlice.len > 0) {
			std.log.info("Command line arguments detected, processing for server configuration...", .{});
		}
		
		// Load server configuration from server.properties or command line args
		serverConfig = config.ServerConfig.load(argSlice) catch |err| {
			std.log.err("Failed to load server configuration: {s}", .{@errorName(err)});
			@panic("Cannot load server configuration");
		};

		std.log.info("Server Configuration:", .{});
		std.log.info("  Max Players: {d}", .{serverConfig.max_players});
		std.log.info("  Port: {d}", .{serverConfig.port});
		std.log.info("  World Name: {s}", .{serverConfig.world_name});
		std.log.info("  View Distance: {d} chunks", .{serverConfig.view_distance});
		std.log.info("  Server Name: {s}", .{serverConfig.server_name});
		std.log.info("  Allow Unsupported Clients: {any}", .{serverConfig.allow_unsupported_clients});
		std.log.info("  PvP: {any}", .{serverConfig.pvp});
	}

	std.log.info("Starting Cubyz dedicated server version {s}", .{settings.version.version});

	if (builtin.os.tag == .windows) {
		std.log.warn("Cubyz server detected it's running on Windows. For optimal performance and reduced power usage please install Linux.", .{});
	}

	settings.environment.init(args.environ);

	// Initialize home path and files module first
	{
		const homePath = args.environ.getAlloc(stackAllocator.allocator, if (builtin.os.tag == .windows) "USERPROFILE" else "HOME") catch |err| {
			std.log.err("Failed to get environment variable for home path: {s}", .{@errorName(err)});
			@panic("Failed to get environment variable for home path");
		};
		defer stackAllocator.free(homePath);
		files.init(homePath);
	}
	defer files.deinit();

	// Ensure cubyzDir exists
	const cubyzDirPath = files.cubyzDirStr();
	std.log.info("Server working directory: {s}", .{cubyzDirPath});

	// Create saves directory if it doesn't exist
	const savesPath = "saves";
	if (!files.cubyzDir().hasDir(savesPath)) {
		std.log.info("Creating saves directory...", .{});
		files.cubyzDir().makePath(savesPath) catch |err| {
			std.log.err("Failed to create saves directory: {s}", .{@errorName(err)});
			@panic("Cannot create saves directory");
		};
	}

	// Check if launchConfig.zon exists, create default if missing
	const launchConfigPath = "launchConfig.zon";
	if (!files.cubyzDir().hasFile(launchConfigPath)) {
		std.log.info("launchConfig.zon not found. Creating default configuration...", .{});
		const defaultConfig = 
			\\.{
			\\    .cubyzDir = "",
			\\    .autoEnterWorld = "world",
			\\    .headlessServer = true,
			\\    // .preferredAuthenticationAlgorithm = .ed25519, // Uncomment and change this if you own a server in an outdated game version where the default algorithm got compromised.
			\\}
		;
		files.cubyzDir().write(launchConfigPath, defaultConfig) catch |err| {
			std.log.err("Failed to create launchConfig.zon: {s}", .{@errorName(err)});
			@panic("Cannot create launchConfig.zon");
		};
		std.log.info("Default launchConfig.zon created with autoEnterWorld=\"world\"", .{});
	}

	settings.launchConfig.init();

	settings.init();
	defer settings.deinit();

	threadPool = utils.ThreadPool.init(globalAllocator, settings.cpuThreads orelse @max(1, (std.Thread.getCpuCount() catch 4) -| 1));
	defer threadPool.deinit();

	file_monitor.init();
	defer file_monitor.deinit();

	// Skip all GUI, graphics, audio, and client-side initialization
	// Only initialize server-required components

	utils.initDynamicIntArrayStorage();
	defer utils.deinitDynamicIntArrayStorage();

	rotation.init();
	defer rotation.deinit();

	block_entity.init();
	defer block_entity.deinit();

	models.init();
	defer models.deinit();

	items.globalInit();
	defer items.globalDeinit();

	// Skip client sync
	// Skip item drop renderer (client-side only)

	assets.init();

	// Skip block meshes (client-side rendering)
	// Skip renderer (client-side rendering)

	network.init() catch @panic("Failed to initialize network");
	defer network.deinit();

	// Initialize server-side systems
	systems.server.init();
	defer systems.server.deinit();

	entity.server.init();
	defer entity.server.deinit();

	items.Inventory.server.init();
	defer items.Inventory.server.deinit();

	sync.server.init();
	defer sync.server.deinit();

	// Skip client GUI and particles

	server.terrain.globalInit();

	// Determine world name to load (config file takes precedence, then server.properties)
	const worldName = getOrCreateWorldNameWithConfig(serverConfig.world_name);
	defer globalAllocator.free(worldName);

	std.log.info("Starting server with world: {s}", .{worldName});

	// Start the dedicated server without a local player
	// Pass the port from config to use the configured port instead of random/default
	server.startFromExistingThread(worldName, serverConfig.port, .multiplayer);
	heap.GarbageCollection.waitForFreeCompletion();
}

/// Determines which world to load. Creates a new world folder if none exists.
/// Uses the world name from server.properties/config if provided.
fn getOrCreateWorldNameWithConfig(configWorldName: []const u8) []const u8 {
	// 1. If config specifies a world, use it
	if (configWorldName.len > 0) {
		std.log.info("Using world from configuration: {s}", .{configWorldName});
		return ensureWorldExists(configWorldName);
	}

	// 2. Fall back to launchConfig.zon setting
	const configuredWorld = settings.launchConfig.autoEnterWorld;
	if (configuredWorld.len > 0) {
		std.log.info("Using world from launchConfig.zon: {s}", .{configuredWorld});
		return ensureWorldExists(configuredWorld);
	}

	// 3. No world specified - check for existing worlds
	var savesDir = files.cubyzDir().openIterableDir("saves") catch |err| {
		std.log.err("Cannot open saves directory: {s}", .{@errorName(err)});
		@panic("Cannot access saves directory");
	};
	defer savesDir.close();

	// First pass: check if any worlds exist and collect them
	var worldList = List([]const u8).initCapacity(globalAllocator, 16);
	defer {
		for (worldList.items) |world| {
			globalAllocator.free(world);
		}
		worldList.deinit(globalAllocator);
	}

	var iterator = savesDir.iterate();
	while (true) {
		const maybeEntry = iterator.next(io) catch break;
		const entry = maybeEntry orelse break;
		if (entry.kind == .directory) {
			worldList.addOne(globalAllocator).* = globalAllocator.dupe(u8, entry.name);
		}
	}

	if (worldList.items.len > 0) {
		// List available worlds
		std.log.info("Available worlds in saves/:", .{});
		for (worldList.items, 0..) |worldName, index| {
			std.log.info("  [{d}] {s}", .{ index, worldName });
		}

		// Use first world by default
		const firstWorld = worldList.items[0];
		std.log.info("No world specified in configuration. Using first available world: {s}", .{firstWorld});
		std.log.info("To change this, edit server.properties or launchConfig.zon", .{});
		return globalAllocator.dupe(u8, firstWorld);
	}

	// No worlds exist - create a default world with warning
	std.log.warn("No worlds found in saves/ directory!", .{});
	std.log.warn("Do you want to generate a new default world?", .{});
	std.log.warn("Press Ctrl+C to stop server or wait 5 seconds to continue with world generation...", .{});
	
	// Simple delay to allow user to cancel (in future could be interactive)
	io.sleep(.fromSeconds(5), .awake) catch {};
	
	const defaultWorldName = "world";
	std.log.info("Creating default world '{s}'...", .{defaultWorldName});
	return ensureWorldExists(defaultWorldName);
}

/// Ensures a world folder exists, creating it if necessary
fn ensureWorldExists(worldName: []const u8) []const u8 {
	const worldPath = globalAllocator.print("saves/{s}", .{worldName});
	defer globalAllocator.free(worldPath);
	
	// Check if world already exists
	if (files.cubyzDir().hasDir(worldPath)) {
		std.log.info("World '{s}' already exists.", .{worldName});
		return globalAllocator.dupe(u8, worldName);
	}

	// Create world folder structure
	files.cubyzDir().makePath(worldPath) catch |err| {
		std.log.err("Failed to create world directory: {s}", .{@errorName(err)});
		@panic("Cannot create world directory");
	};

	// Create basic world configuration
	const arena = stackAllocator.createArena();
	defer stackAllocator.destroyArena(arena);
	
	const worldInfo = ZonElement.initObject(arena);
	worldInfo.put("version", @as(u32, 3));
	worldInfo.put("name", worldName);
	worldInfo.put("lastUsedTime", std.Io.Clock.Timestamp.now(io, .real).raw.toMilliseconds());
	
	// Generate a random seed
	var worldSeed: i128 = undefined;
	worldSeed = @intCast(random.nextInt(u64, &seed));
	std.log.info("Generated world seed: {d}", .{worldSeed});
	
	const generatorSettings = ZonElement.initObject(arena);
	generatorSettings.put("seed", worldSeed);
	generatorSettings.put("generatorType", "default");
	worldInfo.put("generatorSettings", generatorSettings);
	
	const worldSettings = ZonElement.initObject(arena);
	worldSettings.put("defaultGamemode", "creative");
	worldSettings.put("allowCheats", true);
	worldSettings.put("testingMode", false);
	worldSettings.put("whitelistEnabled", false);
	worldSettings.put("seed", worldSeed);
	worldInfo.put("settings", worldSettings);
	worldInfo.put("spawn", [_]i32{ 0, 0, 0 });
	worldInfo.put("biomeChecksum", @as(i64, 0));
	
	const worldInfoPath = globalAllocator.print("saves/{s}/world.zig.zon", .{worldName});
	defer globalAllocator.free(worldInfoPath);
	
	files.cubyzDir().writeZon(worldInfoPath, worldInfo) catch |err| {
		std.log.err("Failed to create world config: {s}", .{@errorName(err)});
		@panic("Cannot create world configuration");
	};

	// Create assets folder
	const assetsPath = globalAllocator.print("saves/{s}/assets", .{worldName});
	defer globalAllocator.free(assetsPath);
	files.cubyzDir().makePath(assetsPath) catch {};

	std.log.info("World '{s}' created successfully!", .{worldName});
	return globalAllocator.dupe(u8, worldName);
}

/// Legacy function kept for compatibility
fn getOrCreateWorldName() []const u8 {
	return getOrCreateWorldNameWithConfig("");
}

pub fn clientMain() void { // MARK: clientMain()
	if (settings.playerName.len == 0) {
		gui.openWindow("change_name");
	} else if (settings.launchConfig.autoEnterWorld.len == 0) {
		gui.openWindow("main");
	} else {
		// Speed up the dev process by entering the world directly.
		gui.windowlist.save_selection.mode = .singleplayer;
		gui.windowlist.save_selection.openWorld(settings.launchConfig.autoEnterWorld);
	}

	Window.GLFWCallbacks.framebufferSize(undefined, Window.width, Window.height);
	var lastBeginRendering = timestamp();

	audio.setMusic("cubyz:totaldemented/cubyz_remastered");

	while (c.glfwWindowShouldClose(Window.window) == 0) {
		heap.GarbageCollection.syncPoint();
		const isHidden = c.glfwGetWindowAttrib(Window.window, c.GLFW_ICONIFIED) == c.GLFW_TRUE;
		if (!isHidden) {
			c.glfwSwapBuffers(Window.window);
			// Clear may also wait on vsync, so it's done before handling events:
			gui.windowlist.gpu_performance_measuring.startQuery(.screenbuffer_clear);
			c.glDepthFunc(c.GL_LESS);
			c.glDepthMask(c.GL_TRUE);
			c.glDisable(c.GL_SCISSOR_TEST);
			c.glClearColor(0.5, 1, 1, 1);
			c.glClear(c.GL_DEPTH_BUFFER_BIT | c.GL_STENCIL_BUFFER_BIT | c.GL_COLOR_BUFFER_BIT);
			gui.windowlist.gpu_performance_measuring.stopQuery();

			if (settings.launchConfig.vulkanTestingMode) {
				graphics.vulkan.beginRender();
			}
		} else {
			io.sleep(.fromMilliseconds(16), .awake) catch {};
		}

		const endRendering = timestamp();
		const frameTime = @as(f64, @floatFromInt(endRendering.nanoseconds -% lastBeginRendering.nanoseconds))/1.0e9;
		lastFrameTime.store(frameTime, .monotonic);

		if (settings.fpsCap) |fpsCap| {
			const minFrameTime = @divFloor(1000*1000*1000, fpsCap);
			const sleep = @min(minFrameTime, @max(0, minFrameTime - (endRendering.nanoseconds -% lastBeginRendering.nanoseconds)));
			if (builtin.os.tag == .windows and minFrameTime < 20_000_000) { // Windows can oversleep a lot, so we waste power instead
				const targetTime = timestamp().addDuration(.fromNanoseconds(sleep));
				while (timestamp().durationTo(targetTime).nanoseconds > 0) {}
			} else {
				io.sleep(.fromNanoseconds(sleep), .awake) catch {};
			}
		}
		const begin = timestamp();
		const deltaTime = @as(f64, @floatFromInt(begin.nanoseconds -% lastBeginRendering.nanoseconds))/1.0e9;
		lastDeltaTime.store(deltaTime, .monotonic);
		lastBeginRendering = begin;

		Window.handleEvents(deltaTime);

		file_monitor.handleEvents();

		if (game.world != null) { // Update the game
			game.update(deltaTime);
		}

		if (!isHidden) {
			if (game.world != null) {
				renderer.updateFov(settings.fov);
				renderer.render(game.Player.getEyePosBlocking(), deltaTime);
			} else {
				renderer.updateFov(70.0);
				renderer.MenuBackGround.render(deltaTime);
			}
			// Render the GUI
			gui.windowlist.gpu_performance_measuring.startQuery(.gui);
			gui.updateAndRenderGui();
			gui.windowlist.gpu_performance_measuring.stopQuery();

			if (settings.launchConfig.vulkanTestingMode) {
				graphics.vulkan.endRender();
			}
		}

		if (shouldExitToMenu.load(.monotonic)) {
			shouldExitToMenu.store(false, .monotonic);
			Window.setMouseGrabbed(false);
			if (game.world) |world| {
				world.deinit();
				game.world = null;
			}
			gui.openWindow("main");
			audio.setMusic("cubyz:totaldemented/cubyz_remastered");
		}
	}

	if (game.world) |world| {
		world.deinit();
		game.world = null;
	}
}

/// std.testing.refAllDeclsRecursive, but ignores C imports (by name)
pub fn refAllDeclsRecursiveExceptCImports(comptime T: type) void {
	if (!@import("builtin").is_test) return;
	inline for (comptime std.meta.declarations(T)) |decl| blk: {
		if (comptime std.mem.eql(u8, decl.name, "c")) continue;
		if (comptime std.mem.eql(u8, decl.name, "hbft")) break :blk;
		if (comptime std.mem.eql(u8, decl.name, "stb_image")) break :blk;
		// TODO: Remove this after Zig removes Managed hashmap PixelGuys/Cubyz#308
		if (comptime std.mem.eql(u8, decl.name, "Managed")) continue;
		if (@TypeOf(@field(T, decl.name)) == type) {
			switch (@typeInfo(@field(T, decl.name))) {
				.@"struct", .@"enum", .@"union", .@"opaque" => refAllDeclsRecursiveExceptCImports(@field(T, decl.name)),
				else => {},
			}
		}
		_ = &@field(T, decl.name);
	}
}

test "abc" {
	@setEvalBranchQuota(1000000);
	refAllDeclsRecursiveExceptCImports(@This());
	_ = @import("zon.zig");
}

test "allocators are usable in tests" {
	const allocation1 = stackAllocator.create(u64);
	stackAllocator.destroy(allocation1);

	const allocation2 = globalAllocator.create(u64);
	globalAllocator.destroy(allocation2);
}
