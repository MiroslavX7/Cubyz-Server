const builtin = @import("builtin");
const std = @import("std");

const root = @import("root");
const ZonElement = main.ZonElement;
const sync = main.sync;

const PlayerRecord = struct { playerIndex: usize, blocked: bool };

var playerDatabase: std.StringHashMapUnmanaged(PlayerRecord) = undefined;
var localPlayerIndex: usize = undefined;
var nextPlayerIndex: std.atomic.Value(usize) = undefined;
var worldPath: []const u8 = undefined;

var mutex: root.utils.Mutex = .{};

fn init(path: []const u8, loadedLocalPlayerIndex: usize) void {
	sync.threadContext.assertCorrectContext(.server);
	worldPath = root.worldArena.dupe(u8, path);
	localPlayerIndex = loadedLocalPlayerIndex;
	playerDatabase = .{};
	nextPlayerIndex = .init(0);
}

pub fn loadPlayerLoginInfo(dir: root.files.Dir, path: []const u8, loadedLocalPlayerIndex: usize) !void {
	init(path, loadedLocalPlayerIndex);

	var playerDir = try dir.openIterableDir("players");
	defer playerDir.close();
	var iterator = playerDir.iterate();
	while (try iterator.next(main.io)) |file| {
		if (file.kind == .file and std.mem.endsWith(u8, file.name, ".zon")) {
			const zon = try playerDir.readToZon(root.stackAllocator, file.name);
			defer zon.deinit(root.stackAllocator);
			const fileNameBase = file.name[0..std.mem.findScalar(u8, file.name, '.').?];
			if (fileNameBase[0] == '0' and fileNameBase.len != 1) {
				std.log.err("Player file {s} contains leading zeroes. Skipping.", .{file.name});
				continue;
			}
			const index = std.fmt.parseInt(usize, fileNameBase, 10) catch |err| {
				std.log.err("Couldn't parse player file {s}: {s} Skipping.", .{file.name, @errorName(err)});
				continue;
			};
			_ = nextPlayerIndex.fetchMax(index + 1, .monotonic);
			const blocked = zon.get(bool, "blocked") orelse false;
			if (zon.get([]const u8, "publicKey")) |key| {
				const keyType = key[0 .. std.mem.findScalar(u8, key, ':') orelse {
					std.log.err("Player file {s} has invalid key entry {s}: Type is missing. Skipping.", .{file.name, key});
					continue;
				}];
				_ = std.meta.stringToEnum(root.network.authentication.KeyTypeEnum, keyType) orelse {
					std.log.err("Player file {s} has invalid key type {s}. Skipping.", .{file.name, keyType});
					continue;
				};
				playerDatabase.put(root.worldArena.allocator, root.worldArena.dupe(u8, key), .{.playerIndex = index, .blocked = blocked}) catch unreachable;
			} else if (index != localPlayerIndex) {
				const name = zon.get([]const u8, "name") orelse {
					std.log.err("Couldn't read player file {s}. Skipping.", .{file.name});
					continue;
				};
				const fullEntry = root.worldArena.print("name:{s}", .{name});
				playerDatabase.put(root.worldArena.allocator, fullEntry, .{.playerIndex = index, .blocked = blocked}) catch unreachable;
			}
		}
	}
}

pub fn getLocalPlayerIndex() usize {
	return localPlayerIndex;
}

pub fn lookupIndex(key: []const u8) ?PlayerRecord {
	mutex.lock();
	defer mutex.unlock();
	return playerDatabase.get(key);
}

pub fn isEmpty() bool {
	mutex.lock();
	defer mutex.unlock();
	return playerDatabase.size == 0;
}

pub fn allocateNewIndex() usize {
	return nextPlayerIndex.fetchAdd(1, .monotonic);
}

pub fn rebindKey(oldPublicKeyFromFile: ?[]const u8, oldNameFromFile: ?[]const u8, newKey: []const u8, index: usize) void {
	sync.threadContext.assertCorrectContext(.server);
	mutex.lock();
	defer mutex.unlock();
	var blocked = false;
	if (oldPublicKeyFromFile) |publicKey| {
		blocked = playerDatabase.fetchRemove(publicKey).?.value.blocked;
	} else {
		removeOld: {
			const nameEntry = root.stackAllocator.print("name:{s}", .{oldNameFromFile orelse break :removeOld});
			defer root.stackAllocator.free(nameEntry);
			if (playerDatabase.fetchRemove(nameEntry)) |kv| blocked = kv.value.blocked;
		}
	}
	playerDatabase.put(root.worldArena.allocator, root.worldArena.dupe(u8, newKey), .{.playerIndex = index, .blocked = blocked}) catch unreachable;
}

fn saveNewPlayer(key: []const u8, index: usize) void {
	const playersDir = root.stackAllocator.print("saves/{s}/players", .{worldPath});
	defer root.stackAllocator.free(playersDir);
	root.files.cubyzDir().makePath(playersDir) catch |err| {
		std.log.err("Couldn't create players directory: {t}", .{err});
	};

	const path = root.stackAllocator.print("saves/{s}/players/{}.zon", .{worldPath, index});
	defer root.stackAllocator.free(path);

	const zon: ZonElement = .initObject(root.stackAllocator);
	defer zon.deinit(root.stackAllocator);
	zon.put("publicKey", key);

	root.files.cubyzDir().writeZon(path, zon) catch |err| {
		std.log.err("Couldn't create player file for pre-authorized key {s}: {t}", .{key, err});
	};
}

const EnsureResult = struct { entry: *PlayerRecord, wasNew: bool };

fn ensurePlayerRecord(key: []const u8) EnsureResult {
	sync.threadContext.assertCorrectContext(.server);
	mutex.assertLocked();

	const result = playerDatabase.getOrPut(root.worldArena.allocator, key) catch unreachable;
	if (result.found_existing) return .{.entry = result.value_ptr, .wasNew = false};

	result.key_ptr.* = root.worldArena.dupe(u8, key);
	result.value_ptr.* = .{.playerIndex = nextPlayerIndex.fetchAdd(1, .monotonic), .blocked = false};

	if (!builtin.is_test) {
		saveNewPlayer(key, result.value_ptr.playerIndex);
	}

	return .{.entry = result.value_ptr, .wasNew = true};
}

fn saveBlocked(index: usize, value: bool) void {
	if (builtin.is_test) return;
	sync.threadContext.assertCorrectContext(.server);

	const path = root.stackAllocator.print("saves/{s}/players/{}.zon", .{worldPath, index});
	defer root.stackAllocator.free(path);

	var zon: ZonElement = root.files.cubyzDir().readToZon(root.stackAllocator, path) catch .null;
	defer zon.deinit(root.stackAllocator);
	if (zon != .object) {
		zon.deinit(root.stackAllocator);
		zon = .initObject(root.stackAllocator);
	}
	zon.put("blocked", value);

	root.files.cubyzDir().writeZon(path, zon) catch |err| {
		std.log.err("Couldn't update blocked state for player {}: {t}", .{index, err});
	};
}

const AddResult = enum { added, alreadyAllowed };

pub fn add(key: []const u8) AddResult {
	sync.threadContext.assertCorrectContext(.server);
	mutex.lock();
	defer mutex.unlock();
	const result = ensurePlayerRecord(key);
	const wasBlocked = result.entry.blocked;
	result.entry.blocked = false;
	if (wasBlocked) saveBlocked(result.entry.playerIndex, false);
	return if (result.wasNew or wasBlocked) .added else .alreadyAllowed;
}

const BlockResult = enum { blocked, alreadyBlocked };

pub fn block(key: []const u8) BlockResult {
	sync.threadContext.assertCorrectContext(.server);
	mutex.lock();
	defer mutex.unlock();
	const result = ensurePlayerRecord(key);
	const wasBlocked = result.entry.blocked;
	result.entry.blocked = true;
	if (!wasBlocked) saveBlocked(result.entry.playerIndex, true);
	return if (result.wasNew or !wasBlocked) .blocked else .alreadyBlocked;
}

test "addContainsRemove" {
	root.heap.allocators.createWorldArena();
	defer root.heap.allocators.destroyWorldArena();

	init("test", 0);

	try std.testing.expectEqual(null, lookupIndex("ed25519:abc"));
	try std.testing.expectEqual(.added, add("ed25519:abc"));
	try std.testing.expectEqual(.alreadyAllowed, add("ed25519:abc"));
	try std.testing.expectEqual(false, lookupIndex("ed25519:abc").?.blocked);
	try std.testing.expectEqual(.blocked, block("ed25519:abc"));
	try std.testing.expectEqual(.alreadyBlocked, block("ed25519:abc"));
	try std.testing.expectEqual(true, lookupIndex("ed25519:abc").?.blocked);
}

test "addUnblocks" {
	root.heap.allocators.createWorldArena();
	defer root.heap.allocators.destroyWorldArena();

	init("test", 0);

	try std.testing.expectEqual(.blocked, block("ed25519:xyz"));
	try std.testing.expectEqual(true, lookupIndex("ed25519:xyz").?.blocked);
	try std.testing.expectEqual(.added, add("ed25519:xyz"));
	try std.testing.expectEqual(false, lookupIndex("ed25519:xyz").?.blocked);
}

test "lookupIndexDistinguishesKnownAndUnknownKeys" {
	root.heap.allocators.createWorldArena();
	defer root.heap.allocators.destroyWorldArena();

	init("test", 0);

	playerDatabase.put(root.worldArena.allocator, root.worldArena.dupe(u8, "ed25519:known"), .{.playerIndex = 0, .blocked = false}) catch unreachable;

	try std.testing.expectEqual(false, lookupIndex("ed25519:known").?.blocked);
	try std.testing.expectEqual(null, lookupIndex("ed25519:unknown"));

	try std.testing.expectEqual(.blocked, block("ed25519:known"));
	try std.testing.expectEqual(true, lookupIndex("ed25519:known").?.blocked);

	try std.testing.expectEqual(.added, add("ed25519:known"));
	try std.testing.expectEqual(false, lookupIndex("ed25519:known").?.blocked);
}
