const std = @import("std");

const root = @import("root");
const ConnectionManager = root.network.ConnectionManager;
const settings = main.settings;
const Vec2f = main.vec.Vec2f;
const NeverFailingAllocator = root.heap.NeverFailingAllocator;
const Texture = main.graphics.Texture;

const gui = @import("../gui.zig");
const GuiComponent = gui.GuiComponent;
const GuiWindow = gui.GuiWindow;
const Button = @import("../components/Button.zig");
const HorizontalList = @import("../components/HorizontalList.zig");
const Label = @import("../components/Label.zig");
const TextInput = @import("../components/TextInput.zig");
const VerticalList = @import("../components/VerticalList.zig");

pub var window = GuiWindow{
	.contentSize = Vec2f{128, 256},
};

const padding: f32 = 8;
const width: f32 = 160;
var buttonNameArena: root.heap.NeverFailingArenaAllocator = undefined;

pub var needsUpdate: bool = false;

pub var mode: root.server.ServerWorld.Mode = undefined;

var deleteIcon: Texture = undefined;
var fileExplorerIcon: Texture = undefined;

const WorldInfo = struct {
	lastUsedTime: i64,
	name: []const u8,
	fileName: []const u8,
};
var worldList: main.List(WorldInfo) = .empty;

pub fn init() void {
	deleteIcon = Texture.initFromFile("assets/cubyz/ui/delete_icon.png");
	fileExplorerIcon = Texture.initFromFile("assets/cubyz/ui/file_explorer_icon.png");
}

pub fn deinit() void {
	deleteIcon.deinit();
	fileExplorerIcon.deinit();
}

pub fn openWorld(name: []const u8) void {
	const clientConnection = ConnectionManager.init(0, .{}) catch |err| {
		std.log.err("Encountered error while opening connection: {s}", .{@errorName(err)});
		return;
	};

	std.log.info("Opening world {s}", .{name});
	root.server.thread = std.Thread.spawn(.{}, root.server.startFromNewThread, .{name, clientConnection.localPort, mode}) catch |err| {
		std.log.err("Encountered error while starting server thread: {s}", .{@errorName(err)});
		return;
	};
	root.server.thread.?.setName(main.io, "Server") catch |err| {
		std.log.err("Failed to rename Server thread: {s}", .{@errorName(err)});
	};

	while (!root.server.running.load(.acquire)) {
		main.io.sleep(.fromMilliseconds(1), .awake) catch {};
		root.heap.GarbageCollection.syncPoint();
	}
	const ipPort = root.stackAllocator.print("127.0.0.1:{}", .{root.server.connectionManager.localPort});
	defer root.stackAllocator.free(ipPort);
	const zon = main.game.testWorld.init(ipPort, clientConnection) catch |err| {
		std.log.err("Encountered error while opening world: {s}", .{@errorName(err)});
		return;
	};
	main.game.testWorld.finishHandshake(zon) catch |err| {
		std.log.err("Encountered error while opening world: {s}", .{@errorName(err)});
		return;
	};
	for (gui.openWindows.items) |openWindow| {
		gui.closeWindowFromRef(openWindow);
	}
	gui.openHud();
}

fn openWorldWrap(index: usize) void { // TODO: Improve this situation. Maybe it makes sense to always use 2 arguments in the Callback.
	openWorld(worldList.items[index].fileName);
}

fn deleteWorld(index: usize) void {
	main.gui.closeWindow("delete_world_confirmation");
	main.gui.windowlist.delete_world_confirmation.setDeleteWorldName(worldList.items[index].fileName);
	main.gui.openWindow("delete_world_confirmation");
}

fn openFolder(index: usize) void {
	const path = root.stackAllocator.print("{s}/saves/{s}", .{root.files.cubyzDirStr(), worldList.items[index].fileName});
	defer root.stackAllocator.free(path);

	root.files.openDirInWindow(path);
}

pub fn update() void {
	if (needsUpdate) {
		needsUpdate = false;
		onClose();
		onOpen();
	}
}

pub fn onOpen() void {
	buttonNameArena = root.heap.NeverFailingArenaAllocator.init(root.globalAllocator);
	const list = VerticalList.init(.{padding, 16 + padding}, 300, 8);
	list.add(Label.init(.{0, 0}, width, if (mode == .singleplayer) "**Select World**" else "**Select World to Host**", .center));
	list.add(Button.initText(.{0, 0}, 128, "Create New World", .{.onAction = gui.openWindowCallback("save_creation")}));
	readingSaves: {
		var dir = root.files.cubyzDir().openIterableDir("saves") catch |err| {
			list.add(Label.init(.{0, 0}, 128, "Encountered error while trying to open saves folder:", .center));
			list.add(Label.init(.{0, 0}, 128, @errorName(err), .center));
			break :readingSaves;
		};
		defer dir.close();

		var iterator = dir.iterate();
		while (iterator.next(main.io) catch |err| {
			list.add(Label.init(.{0, 0}, 128, "Encountered error while iterating over saves folder:", .center));
			list.add(Label.init(.{0, 0}, 128, @errorName(err), .center));
			break :readingSaves;
		}) |entry| {
			if (entry.kind == .directory) {
				const worldInfoPath = root.stackAllocator.print("saves/{s}/world.zig.zon", .{entry.name});
				defer root.stackAllocator.free(worldInfoPath);
				const worldInfo = root.files.cubyzDir().readToZon(root.stackAllocator, worldInfoPath) catch |err| {
					std.log.err("Couldn't open save {s}: {s}", .{worldInfoPath, @errorName(err)});
					continue;
				};
				defer worldInfo.deinit(root.stackAllocator);

				worldList.append(root.globalAllocator, .{
					.fileName = root.globalAllocator.dupe(u8, entry.name),
					.lastUsedTime = worldInfo.get(i64, "lastUsedTime") orelse 0,
					.name = root.globalAllocator.dupe(u8, worldInfo.get([]const u8, "name") orelse entry.name),
				});
			}
		}
	}

	std.sort.insertion(WorldInfo, worldList.items, {}, struct {
		fn lessThan(_: void, lhs: WorldInfo, rhs: WorldInfo) bool {
			return rhs.lastUsedTime -% lhs.lastUsedTime < 0;
		}
	}.lessThan);

	for (worldList.items, 0..) |worldInfo, i| {
		const row = HorizontalList.init();
		row.add(Button.initText(.{0, 0}, 128, worldInfo.name, .{.onAction = .initWithInt(openWorldWrap, i)}));
		row.add(Button.initIcon(.{8, 0}, .{16, 16}, fileExplorerIcon, .{.onAction = .initWithInt(openFolder, i)}));
		row.add(Button.initIcon(.{8, 0}, .{16, 16}, deleteIcon, .{.onAction = .initWithInt(deleteWorld, i)}));
		row.finish(.{0, 0}, .center);
		list.add(row);
	}

	list.finish(.center);
	window.rootComponent = list.toComponent();
	window.contentSize = window.rootComponent.?.pos() + window.rootComponent.?.size() + @as(Vec2f, @splat(padding));
	gui.updateWindowPositions();
}

pub fn onClose() void {
	for (worldList.items) |worldInfo| {
		root.globalAllocator.free(worldInfo.fileName);
		root.globalAllocator.free(worldInfo.name);
	}
	worldList.clearAndFree(root.globalAllocator);
	buttonNameArena.deinit();
	if (window.rootComponent) |*comp| {
		comp.deinit();
	}
}
