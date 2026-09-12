const std = @import("std");
const Atomic = std.atomic.Value;

const root = @import("root");
const chunk = main.chunk;
const network = main.network;
const Connection = network.Connection;
const ConnectionManager = network.ConnectionManager;
const InventoryId = main.items.Inventory.InventoryId;
const utils = main.utils;
const vec = main.vec;
const Vec3d = vec.Vec3d;
const Vec3f = vec.Vec3f;
const Vec3i = vec.Vec3i;
const BinaryReader = root.utils.BinaryReader;
const BinaryWriter = root.utils.BinaryWriter;
const Blueprint = main.blueprint.Blueprint;
const Mask = main.blueprint.Mask;
const NeverFailingAllocator = root.heap.NeverFailingAllocator;
const CircularBufferQueue = root.utils.CircularBufferQueue;
const sync = main.sync;

pub const BlockUpdateSystem = @import("BlockUpdateSystem.zig");
pub const world_zig = @import("world.zig");
pub const ServerWorld = world_zig.ServerWorld;
pub const terrain = @import("terrain/terrain.zig");
pub const Entity = @import("Entity.zig");
pub const SimulationChunk = @import("SimulationChunk.zig");
pub const stdin_handler = @import("stdin_handler.zig");
pub const storage = @import("storage.zig");
pub const permission = @import("permission.zig");
pub const players = @import("players.zig");
pub const BlockDrop = @import("BlockDrop.zig");

pub const command = @import("command.zig");

pub const WorldEditData = struct {
	const maxWorldEditHistoryCapacity: u32 = 1024;

	selectionPosition1: ?Vec3i = null,
	selectionPosition2: ?Vec3i = null,
	clipboard: ?Blueprint = null,
	undoHistory: History,
	redoHistory: History,
	mask: ?Mask = null,

	const History = struct {
		changes: CircularBufferQueue(Value),

		const Value = struct {
			blueprint: Blueprint,
			position: Vec3i,
			message: []const u8,

			pub fn init(blueprint: Blueprint, position: Vec3i, message: []const u8) Value {
				return .{.blueprint = blueprint, .position = position, .message = root.globalAllocator.dupe(u8, message)};
			}
			pub fn deinit(self: Value) void {
				root.globalAllocator.free(self.message);
				self.blueprint.deinit(root.globalAllocator);
			}
			pub fn selection(self: Value) Blueprint.Selection {
				return .initFromExtent(self.position, self.blueprint.extent());
			}
		};
		pub fn init() History {
			return .{.changes = .init(root.globalAllocator, maxWorldEditHistoryCapacity)};
		}
		pub fn deinit(self: *History) void {
			self.clear();
			self.changes.deinit();
		}
		pub fn clear(self: *History) void {
			while (self.changes.popFront()) |item| item.deinit();
		}
		pub fn push(self: *History, value: Value) void {
			if (self.changes.reachedCapacity()) {
				if (self.changes.popFront()) |oldValue| oldValue.deinit();
			}

			self.changes.pushBack(value);
		}
		pub fn pop(self: *History) ?Value {
			return self.changes.popBack();
		}
	};
	pub fn init() WorldEditData {
		return .{.undoHistory = History.init(), .redoHistory = History.init()};
	}
	pub fn deinit(self: *WorldEditData) void {
		if (self.clipboard != null) {
			self.clipboard.?.deinit(root.globalAllocator);
		}
		self.undoHistory.deinit();
		self.redoHistory.deinit();
		if (self.mask) |mask| {
			mask.deinit(root.globalAllocator);
		}
	}
};

pub const PlayerIndex = usize;

pub const User = struct { // MARK: User
	const maxSimulationDistance = 8;
	const simulationSize = 2*maxSimulationDistance;
	const simulationMask = simulationSize - 1;
	conn: *Connection = undefined,
	innerPlayer: Entity = .{},
	timeDifference: utils.TimeDifference = .{},
	interpolation: utils.GenericInterpolation(3) = undefined,
	lastTime: i16 = undefined,
	lastSaveTime: std.Io.Timestamp = .fromNanoseconds(0),
	name: []const u8 = "",
	renderDistance: u16 = undefined,
	clientUpdatePos: Vec3i = .{0, 0, 0},
	receivedFirstEntityData: bool = false,
	isLocal: bool = false,
	id: root.entity.Entity = .noValue,
	// TODO: ipPort: []const u8,
	loadedChunks: [simulationSize][simulationSize][simulationSize]*SimulationChunk = undefined,
	lastRenderDistance: u16 = 0,
	lastPos: Vec3i = @splat(0),
	gamemode: std.atomic.Value(main.game.Gamemode) = .init(.creative),
	spawnPos: ?Vec3d = null,
	worldEditData: WorldEditData = undefined,

	playerIndex: PlayerIndex = undefined,

	jobQueue: root.utils.ConcurrentMaxHeap(root.utils.ThreadPool.Task) = undefined,
	jobQueueScheduled: bool = false,
	jobQueueLastUpdate: struct { position: Vec3i, time: std.Io.Timestamp, alreadyInUpdate: bool = false } = .{.position = @splat(0), .time = .{.nanoseconds = 0}},

	lastSentBiomeId: u32 = 0xffffffff,

	newKeyString: ?[]const u8 = null,
	key: network.authentication.PublicKey = undefined,
	legacyKey: ?network.authentication.PublicKey = null,

	inventoryClientToServerIdMap: std.AutoHashMap(InventoryId, InventoryId) = undefined,
	inventory: ?InventoryId = null,
	handInventory: ?InventoryId = null,

	connected: Atomic(bool) = .init(true),
	state: State = .awaitingKeyVerification,

	mutex: root.utils.Mutex = .{},

	inventoryCommands: main.List([]const u8) = .empty,

	pub const State = enum { awaitingKeyVerification, connectedVerified, awaitingReloadVerified };

	pub fn player(self: *User) *Entity {
		return &self.innerPlayer;
	}

	pub fn init(manager: *ConnectionManager, ipPort: []const u8) !*User {
		const self = root.globalAllocator.create(User);
		errdefer root.globalAllocator.destroy(self);
		self.* = .{};
		self.conn = try Connection.init(manager, ipPort, self);
		self.@"continue"();
		network.protocols.handShake.serverSide(self.conn);
		return self;
	}
	pub fn @"continue"(self: *User) void {
		// reset
		self.* = .{
			.conn = self.conn,
			.name = self.name,
			.newKeyString = self.newKeyString,
			.playerIndex = self.playerIndex,
			.state = self.state,

			.inventoryClientToServerIdMap = .init(root.globalAllocator.allocator),
			.worldEditData = .init(),
			.jobQueue = .init(root.globalAllocator),
		};
	}
	fn privateDeinit(self: *User) void {
		self.conn.deinit();
		root.globalAllocator.free(self.name);
		if (self.newKeyString) |str| root.globalAllocator.free(str);
		root.globalAllocator.destroy(self);
	}
	pub fn deferredPauseAndDeinit(self: *User) void {
		self.conn.disconnect();
		if (self.inventory != null) {
			world.?.savePlayer(self) catch |err| {
				std.log.err("Failed to save player: {s}", .{@errorName(err)});
				return;
			};
		}

		root.heap.GarbageCollection.deferredFree(.{.ptr = self, .freeFunction = root.meta.castFunctionSelfToAnyopaque(privateDeinit)});
		root.heap.GarbageCollection.deferredFree(.{.ptr = self, .freeFunction = root.meta.castFunctionSelfToAnyopaque(pause)});
	}
	pub fn pause(self: *User) void {
		self.state = switch (self.state) {
			.awaitingKeyVerification => .awaitingKeyVerification,
			.connectedVerified => .awaitingReloadVerified,
			.awaitingReloadVerified => .awaitingReloadVerified,
		};

		self.clearJobQueue();

		main.items.Inventory.server.disconnectUser(self);
		std.debug.assert(self.inventoryClientToServerIdMap.count() == 0); // leak
		self.inventoryClientToServerIdMap.deinit();

		if (self.inventory != null) {
			world.?.savePlayer(self) catch |err| {
				std.log.err("Failed to save player: {s}", .{@errorName(err)});
				return;
			};

			main.items.Inventory.server.destroyExternallyManagedInventory(self.inventory.?);
			main.items.Inventory.server.destroyExternallyManagedInventory(self.handInventory.?);
		}

		self.worldEditData.deinit();

		if (self.player().id != .noValue) {
			self.player().deinit(.server);
		}

		self.unloadOldChunk(.{0, 0, 0}, 0);
		for (self.inventoryCommands.items) |commandData| {
			root.globalAllocator.free(commandData);
		}
		self.inventoryCommands.deinit(root.globalAllocator);

		self.jobQueue.deinit();
	}

	pub fn identifyFromKeysAndName(self: *User, name: []const u8, keys: main.ZonElement, whitelistEnabled: bool) !void {
		std.debug.assert(self.name.len == 0);
		self.name = root.globalAllocator.dupe(u8, name);
		var allowedToJoin = !whitelistEnabled;
		{
			const keyBase64 = keys.get([]const u8, @tagName(main.settings.launchConfig.preferredAuthenticationAlgorithm)) orelse return error.PublicKeyNotPresent;
			self.key = try .initFromBase64(keyBase64, main.settings.launchConfig.preferredAuthenticationAlgorithm);
			self.newKeyString = root.globalAllocator.print("{s}:{s}", .{@tagName(main.settings.launchConfig.preferredAuthenticationAlgorithm), keyBase64});
		}
		var foundKey: bool = false;
		for (std.meta.fieldNames(root.network.authentication.KeyTypeEnum)) |keyTypeName| {
			const keyBase64 = keys.get([]const u8, keyTypeName) orelse continue;
			const keyWithType = root.stackAllocator.print("{s}:{s}", .{keyTypeName, keyBase64});
			defer root.stackAllocator.free(keyWithType);
			const lookup = root.server.players.lookupIndex(keyWithType) orelse continue;
			self.playerIndex = lookup.playerIndex;
			allowedToJoin = !lookup.blocked;
			foundKey = true;
			const keyType = std.meta.stringToEnum(root.network.authentication.KeyTypeEnum, keyTypeName).?;
			if (keyType == self.key) break;
			self.legacyKey = try .initFromBase64(keyBase64, keyType);
			break;
		}
		if (!foundKey) {
			if (root.server.players.isEmpty()) { // Claim the local player
				std.log.info("Here", .{});
				self.playerIndex = root.server.players.getLocalPlayerIndex();
				allowedToJoin = true;
			} else {
				const nameEntry = root.stackAllocator.print("name:{s}", .{name});
				defer root.stackAllocator.free(nameEntry);
				if (root.server.players.lookupIndex(nameEntry)) |lookup| {
					self.playerIndex = lookup.playerIndex;
					allowedToJoin = !lookup.blocked;
				} else {
					self.playerIndex = root.server.players.allocateNewIndex();
				}
			}
		}
		if (!allowedToJoin) {
			std.log.info("Rejected connection from '{s}' ({s})", .{name, self.newKeyString.?});
			return error.NotWhitelisted;
		}
	}

	pub fn identifyAsLocal(self: *User, name: []const u8) !void {
		std.debug.assert(self.name.len == 0);
		self.name = root.globalAllocator.dupe(u8, name);
		self.playerIndex = root.server.players.getLocalPlayerIndex();
	}

	pub fn verifySignatures(self: *User, reader: *BinaryReader) !void {
		try self.key.verifySignature(reader, self.conn.secureChannel.verificationDataForClientSignature.items);
		if (self.legacyKey) |key| {
			try key.verifySignature(reader, self.conn.secureChannel.verificationDataForClientSignature.items);
		}
	}

	var freeId: u32 = 0; // TODO: Use id provided by the ECS.
	pub fn initPlayer(self: *User) void {
		self.id = @enumFromInt(freeId);
		freeId += 1;

		world.?.loadPlayer(self) catch {
			std.log.err("Error while loading player data of {s}. Discarding data.", .{self.name});
		};
		if (root.entity.components.@"cubyz:model".server.get(self.id) == null) {
			if (main.entityModel.playerEntityModels.items.len != 0) {
				const defaultModel = main.entityModel.playerEntityModels.items[main.random.nextIntBounded(u32, &main.seed, @intCast(main.entityModel.playerEntityModels.items.len))];
				root.entity.components.@"cubyz:model".server.put(self.id, .{.entityModel = defaultModel});
			}
		}
		if (root.entity.components.@"cubyz:bag".server.get(self.id) == null) {
			root.entity.components.@"cubyz:bag".server.loadEmpty(self.id);
		}
		if (root.entity.components.@"cubyz:permissions".server.get(self.id) == null) {
			root.entity.components.@"cubyz:permissions".server.loadEmpty(self.id);
			root.entity.components.@"cubyz:permissions".server.addPermission(self.id, .white, "/command/avatar");
			root.entity.components.@"cubyz:permissions".server.addPermission(self.id, .white, "/command/help");
		}
		if (self.isLocal) {
			root.entity.components.@"cubyz:permissions".server.addPermission(self.id, .white, "/");
		}

		self.interpolation.init(@ptrCast(&self.player().pos), @ptrCast(&self.player().vel));
		self.loadUnloadChunks();

		root.entity.components.@"cubyz:player".server.load(self.id, @truncate(self.playerIndex));
	}

	fn simArrIndex(x: i32) usize {
		return @intCast(x >> chunk.chunkShift & simulationMask);
	}

	fn unloadOldChunk(self: *User, newPos: Vec3i, newRenderDistance: u16) void {
		const lastBoxStart = (self.lastPos -% @as(Vec3i, @splat(self.lastRenderDistance*chunk.chunkSize))) & ~@as(Vec3i, @splat(chunk.chunkMask));
		const lastBoxEnd = (self.lastPos +% @as(Vec3i, @splat(self.lastRenderDistance*chunk.chunkSize))) +% @as(Vec3i, @splat(chunk.chunkSize - 1)) & ~@as(Vec3i, @splat(chunk.chunkMask));
		const newBoxStart = (newPos -% @as(Vec3i, @splat(newRenderDistance*chunk.chunkSize))) & ~@as(Vec3i, @splat(chunk.chunkMask));
		const newBoxEnd = (newPos +% @as(Vec3i, @splat(newRenderDistance*chunk.chunkSize))) +% @as(Vec3i, @splat(chunk.chunkSize - 1)) & ~@as(Vec3i, @splat(chunk.chunkMask));
		// Clear all chunks not inside the new box:
		var x: i32 = lastBoxStart[0];
		while (x != lastBoxEnd[0]) : (x +%= chunk.chunkSize) {
			const inXDistance = x -% newBoxStart[0] >= 0 and x -% newBoxEnd[0] < 0;
			var y: i32 = lastBoxStart[1];
			while (y != lastBoxEnd[1]) : (y +%= chunk.chunkSize) {
				const inYDistance = y -% newBoxStart[1] >= 0 and y -% newBoxEnd[1] < 0;
				var z: i32 = lastBoxStart[2];
				while (z != lastBoxEnd[2]) : (z +%= chunk.chunkSize) {
					const inZDistance = z -% newBoxStart[2] >= 0 and z -% newBoxEnd[2] < 0;
					if (!inXDistance or !inYDistance or !inZDistance) {
						self.loadedChunks[simArrIndex(x)][simArrIndex(y)][simArrIndex(z)].decreaseRefCount();
						self.loadedChunks[simArrIndex(x)][simArrIndex(y)][simArrIndex(z)] = undefined;
					}
				}
			}
		}
	}

	fn loadNewChunk(self: *User, newPos: Vec3i, newRenderDistance: u16) void {
		const lastBoxStart = (self.lastPos -% @as(Vec3i, @splat(self.lastRenderDistance*chunk.chunkSize))) & ~@as(Vec3i, @splat(chunk.chunkMask));
		const lastBoxEnd = (self.lastPos +% @as(Vec3i, @splat(self.lastRenderDistance*chunk.chunkSize))) +% @as(Vec3i, @splat(chunk.chunkSize - 1)) & ~@as(Vec3i, @splat(chunk.chunkMask));
		const newBoxStart = (newPos -% @as(Vec3i, @splat(newRenderDistance*chunk.chunkSize))) & ~@as(Vec3i, @splat(chunk.chunkMask));
		const newBoxEnd = (newPos +% @as(Vec3i, @splat(newRenderDistance*chunk.chunkSize))) +% @as(Vec3i, @splat(chunk.chunkSize - 1)) & ~@as(Vec3i, @splat(chunk.chunkMask));
		// Clear all chunks not inside the new box:
		var x: i32 = newBoxStart[0];
		while (x != newBoxEnd[0]) : (x +%= chunk.chunkSize) {
			const inXDistance = x -% lastBoxStart[0] >= 0 and x -% lastBoxEnd[0] < 0;
			var y: i32 = newBoxStart[1];
			while (y != newBoxEnd[1]) : (y +%= chunk.chunkSize) {
				const inYDistance = y -% lastBoxStart[1] >= 0 and y -% lastBoxEnd[1] < 0;
				var z: i32 = newBoxStart[2];
				while (z != newBoxEnd[2]) : (z +%= chunk.chunkSize) {
					const inZDistance = z -% lastBoxStart[2] >= 0 and z -% lastBoxEnd[2] < 0;
					if (!inXDistance or !inYDistance or !inZDistance) {
						self.loadedChunks[simArrIndex(x)][simArrIndex(y)][simArrIndex(z)] = world_zig.ChunkManager.getOrGenerateSimulationChunkAndIncreaseRefCount(.{.wx = x, .wy = y, .wz = z, .voxelSize = 1});
					}
				}
			}
		}
	}

	fn loadUnloadChunks(self: *User) void {
		const newPos: Vec3i = @as(Vec3i, @trunc(self.player().pos)) +% @as(Vec3i, @splat(chunk.chunkSize/2)) & ~@as(Vec3i, @splat(chunk.chunkMask));
		const newRenderDistance = main.settings.simulationDistance;
		if (@reduce(.Or, newPos != self.lastPos) or newRenderDistance != self.lastRenderDistance) {
			self.unloadOldChunk(newPos, newRenderDistance);
			self.loadNewChunk(newPos, newRenderDistance);
			self.lastRenderDistance = newRenderDistance;
			self.lastPos = newPos;
		}
	}

	pub fn getTaskFromJobQueue(self: *User) ?struct { root.utils.ThreadPool.Task, enum { hasMoreTasks, empty } } {
		self.mutex.lock();
		defer self.mutex.unlock();
		if (vec.lengthSquare(@as(@Vector(3, i64), self.jobQueueLastUpdate.position -% self.lastPos)) > 32*32) {
			const startTime = main.timestamp();
			if (self.jobQueueLastUpdate.time.durationTo(startTime).toMilliseconds() > 100 and !self.jobQueueLastUpdate.alreadyInUpdate) {
				const ResortTaskTask = struct { // MARK: ResortTaskTask
					const vtable = utils.ThreadPool.VTable{
						.getPriority = &getPriority,
						.isStillNeeded = &isStillNeeded,
						.run = root.meta.castFunctionSelfToAnyopaque(run),
						.clean = root.meta.castFunctionSelfToAnyopaque(clean),
						.taskType = .taskPriorityUpdate,
					};

					pub fn getPriority(_: *anyopaque) f32 {
						unreachable;
					}

					pub fn isStillNeeded(_: *anyopaque) bool {
						return true;
					}

					pub fn run(user: *User) void {
						var newTasks: main.List(root.utils.ThreadPool.Task) = .initCapacity(root.stackAllocator, user.jobQueue.size);
						defer newTasks.deinit(root.stackAllocator);
						while (user.jobQueue.extractAny()) |_task| {
							var task = _task;
							if (!task.vtable.isStillNeeded(task.self)) {
								task.vtable.clean(task.self);
								continue;
							}
							task.cachedPriority = task.vtable.getPriority(task.self);
							newTasks.append(root.stackAllocator, task);
						}
						user.jobQueue.addMany(newTasks.items);
						user.mutex.lock();
						defer user.mutex.unlock();
						user.jobQueueLastUpdate = .{
							.position = user.lastPos,
							.time = main.timestamp(),
						};
					}

					pub fn clean(_: *anyopaque) void {
						unreachable;
					}
				};
				// Create a task to resort tasks:
				self.jobQueueLastUpdate.alreadyInUpdate = true;
				return .{
					.{
						.cachedPriority = undefined,
						.vtable = &ResortTaskTask.vtable,
						.self = self,
					},
					.hasMoreTasks,
				};
			}
		}
		if (self.isNetworkQueueFull()) {
			self.jobQueueScheduled = false;
			return null;
		}
		const task = self.jobQueue.extractMax() orelse {
			self.jobQueueScheduled = false;
			return null;
		};
		if (self.jobQueue.size == 0) {
			self.jobQueueScheduled = false;
			return .{task, .empty};
		} else {
			return .{task, .hasMoreTasks};
		}
	}

	pub fn addTask(self: *User, task: *anyopaque, vtable: *const root.utils.ThreadPool.VTable) void {
		self.mutex.lock();
		defer self.mutex.unlock();
		self.jobQueue.add(.{
			.cachedPriority = vtable.getPriority(task),
			.vtable = vtable,
			.self = task,
		});
	}

	pub fn clearJobQueue(self: *User) void {
		while (self.jobQueue.extractAny()) |task| {
			task.vtable.clean(task.self);
		}
	}

	fn isNetworkQueueFull(self: *User) bool {
		return self.conn.secureChannel.super.sendBuffer.buffer.len > 900000;
	}

	fn scheduleJobQueue(self: *User) void {
		self.mutex.assertLocked();
		if (self.jobQueueScheduled) return;
		if (self.jobQueue.size == 0) return;
		if (self.isNetworkQueueFull()) return;
		self.jobQueueScheduled = true;
		main.threadPool.addPlayer(self);
	}

	pub fn update(self: *User) void {
		self.mutex.lock();
		self.scheduleJobQueue();
		const commands = self.inventoryCommands;
		defer commands.deinit(root.globalAllocator);
		self.inventoryCommands = .empty;
		self.mutex.unlock();

		for (commands.items) |commandData| {
			defer root.globalAllocator.free(commandData);
			var reader: BinaryReader = .init(commandData);
			root.sync.server.executeUserCommand(self, &reader) catch |err| {
				if (err == error.InventoryNotFound) {
					root.network.protocols.inventory.sendFailure(self.conn);
				} else {
					std.log.err("Got error while executing user command: {s}. Disconnecting.", .{@errorName(err)});
					std.log.debug("Command data: {any}", .{commandData});
					self.conn.disconnect();
				}
			};
		}

		self.mutex.lock();
		defer self.mutex.unlock();
		var time = @as(i16, @truncate(main.timestamp().toMilliseconds())) -% main.settings.entityLookback;
		time -%= self.timeDifference.difference.load(.monotonic);
		self.interpolation.update(time, self.lastTime);
		self.lastTime = time;

		const saveTime = main.timestamp();
		if (self.lastSaveTime.durationTo(saveTime).toSeconds() > 5) {
			world.?.savePlayer(self) catch |err| {
				std.log.err("Failed to save player {s}: {s}", .{self.name, @errorName(err)});
			};
			self.lastSaveTime = saveTime;
		}

		self.loadUnloadChunks();
	}

	pub fn receiveCommand(self: *User, commandData: []const u8) void {
		self.mutex.lock();
		defer self.mutex.unlock();
		self.inventoryCommands.append(root.globalAllocator, root.globalAllocator.dupe(u8, commandData));
	}

	pub fn receiveData(self: *User, reader: *BinaryReader) !void {
		self.mutex.lock();
		defer self.mutex.unlock();
		const position: [3]f64 = try reader.readVec(Vec3d);
		const velocity: [3]f64 = try reader.readVec(Vec3d);
		const rotation: [3]f32 = try reader.readVec(Vec3f);
		self.player().rot = rotation;
		const time = try reader.readInt(i16);
		self.timeDifference.addDataPoint(time);
		self.interpolation.updatePosition(&position, &velocity, time);
	}

	pub fn sendMessage(self: *User, comptime fmt: []const u8, args: anytype) void {
		const msg = root.stackAllocator.print(fmt, args);
		defer root.stackAllocator.free(msg);
		self.sendRawMessage(msg);
	}
	pub fn sendRawMessage(self: *User, msg: []const u8) void {
		root.network.protocols.chat.send(self.conn, msg);
	}

	pub fn getSpawnPos(user: *User) Vec3d {
		return user.spawnPos orelse @floatFromInt(root.server.world.?.spawn);
	}

	pub fn format(user: User, writer: *std.Io.Writer) std.Io.Writer.Error!void {
		try writer.print("{s}@{d}", .{user.name, user.playerIndex});
	}
};

pub const updatesPerSec: u32 = 20;
const updateTime: std.Io.Duration = .fromNanoseconds(1000000000/20);

pub var world: ?*ServerWorld = null;
var userMutex: root.utils.Mutex = .{};
var users: main.ListManaged(*User) = undefined;
var userDeinitList: root.utils.ConcurrentQueue(*User) = undefined;
var userConnectList: root.utils.ConcurrentQueue(*User) = undefined;

pub var connectionManager: *ConnectionManager = undefined;

pub var running: std.atomic.Value(bool) = .init(false);
var restart: bool = true;

var lastTime: std.Io.Timestamp = undefined;

pub var thread: ?std.Thread = null;

fn init(name: []const u8, singlePlayerPort: ?u16, mode: ServerWorld.Mode) void { // MARK: init()
	root.heap.allocators.createWorldArena();
	std.debug.assert(world == null); // There can only be one world.
	command.init();
	users = .init(root.globalAllocator);
	lastTime = main.timestamp();

	main.systems.server.init();
	root.entity.server.init();
	main.items.Inventory.server.init();
	root.sync.server.init();

	world = ServerWorld.init(name, mode) catch |err| {
		std.log.err("Failed to create world: {s}", .{@errorName(err)});
		@panic("Can't create world.");
	};

	world.?.generate() catch |err| {
		std.log.err("Failed to generate world: {s}", .{@errorName(err)});
		@panic("Can't generate world.");
	};

	connectionManager.@"continue"() catch |err| {
		std.log.err("Couldn't create thread: {s}", .{@errorName(err)});
		@panic("Could not open Server.");
	};
	if (singlePlayerPort) |port| blk: {
		const ipString = root.stackAllocator.print("127.0.0.1:{}", .{port});
		defer root.stackAllocator.free(ipString);
		const user = User.init(connectionManager, ipString) catch |err| {
			std.log.err("Cannot create singleplayer user {s}", .{@errorName(err)});
			break :blk;
		};
		user.isLocal = true;
	}
}

fn deinit() void {
	main.threadPool.pause();
	defer main.threadPool.@"continue"();

	connectionManager.pause();

	main.threadPool.unschedulePlayers();

	users.clearAndFree();

	while (userDeinitList.popFront()) |user| {
		user.pause();
		user.privateDeinit();
	}

	if (world) |_world| {
		_world.deinit();
	}
	world = null;

	root.sync.server.deinit();
	main.items.Inventory.server.deinit();
	root.entity.server.deinit();
	main.systems.server.deinit();

	command.deinit();

	root.heap.allocators.destroyWorldArena();
}

pub fn getUserList(allocator: root.heap.NeverFailingAllocator) []*User {
	userMutex.lock();
	defer userMutex.unlock();
	return allocator.dupe(*User, users.items);
}

fn getInitialEntityList(allocator: root.heap.NeverFailingAllocator) []const u8 {
	// Send the entity updates:
	var initialList: []const u8 = undefined;
	const list = main.ZonElement.initArray(root.stackAllocator);
	defer list.deinit(root.stackAllocator);
	list.array.append(.null);
	const itemDropList = world.?.itemDropManager.getInitialList(root.stackAllocator);
	list.array.appendSlice(itemDropList.array.items);
	itemDropList.array.items.len = 0;
	itemDropList.deinit(root.stackAllocator);
	initialList = list.toStringEfficient(allocator, &.{});
	return initialList;
}

fn update() void { // MARK: update()
	world.?.update();
	main.systems.server.update();
	stdin_handler.update();

	while (userConnectList.popFront()) |user| {
		connectInternal(user);
	}

	const userList = getUserList(root.stackAllocator);
	defer root.stackAllocator.free(userList);
	for (userList) |user| {
		user.update();
	}

	// Send the entity data:
	const itemData = world.?.itemDropManager.getPositionAndVelocityData(root.stackAllocator);
	defer root.stackAllocator.free(itemData);

	var entityData: main.ListManaged(root.entity.EntityNetworkData) = .init(root.stackAllocator);
	defer entityData.deinit();

	for (userList) |user| {
		const id = user.id; // TODO
		entityData.append(.{
			.id = id,
			.pos = user.player().pos,
			.vel = user.player().vel,
			.rot = user.player().rot,
		});
	}
	for (userList) |user| {
		root.network.protocols.entityPosition.send(user.conn, user.player().pos, entityData.items, itemData);
	}

	for (userList) |user| {
		const pos = @as(Vec3i, @trunc(user.player().pos));
		const biomeId = world.?.getBiome(pos[0], pos[1], pos[2]).paletteId;
		if (biomeId != user.lastSentBiomeId) {
			user.lastSentBiomeId = biomeId;
			root.network.protocols.genericUpdate.sendBiome(user.conn, biomeId);
		}
	}

	while (userDeinitList.popFront()) |user| {
		user.deferredPauseAndDeinit();
	}
}

pub fn startFromNewThread(name: []const u8, port: ?u16, mode: ServerWorld.Mode) void {
	main.initThreadLocals();
	defer main.deinitThreadLocals();
	startFromExistingThread(name, port, mode);
}

pub fn startFromExistingThread(name: []const u8, port: ?u16, mode: ServerWorld.Mode) void {
	std.debug.assert(!running.load(.monotonic)); // There can only be one server.

	const worldName: []const u8 = root.globalAllocator.dupe(u8, name);
	defer root.globalAllocator.free(worldName);

	connectionManager = ConnectionManager.init(main.settings.defaultPort, .{.allowNewConnections = mode == .multiplayer}) catch |err| {
		std.log.err("Couldn't create socket: {s}", .{@errorName(err)});
		@panic("Could not open Server.");
	}; // TODO Configure the second argument in the server settings.
	userDeinitList = .init(root.globalAllocator, 16);
	userConnectList = .init(root.globalAllocator, 16);

	defer {
		connectionManager.deinit();
		connectionManager = undefined;

		while (userDeinitList.popFront()) |user| {
			user.privateDeinit();
		}

		userDeinitList.deinit();
		userConnectList.deinit();
	}

	restart = true;
	while (restart) {
		restart = false;

		init(worldName, port, mode);
		defer deinit();

		running.store(true, .release);
		while (running.load(.monotonic)) {
			root.heap.GarbageCollection.syncPoint();
			const newTime = main.timestamp();
			if (lastTime.durationTo(newTime).nanoseconds < updateTime.nanoseconds) {
				main.io.sleep(newTime.durationTo(lastTime.addDuration(updateTime)), .awake) catch {};
				lastTime = lastTime.addDuration(updateTime);
			} else {
				std.log.warn("The server is lagging behind by {d:.1} ms", .{@as(f32, @floatFromInt(newTime.nanoseconds -% lastTime.nanoseconds -% updateTime.nanoseconds))/1000000.0});
				lastTime = newTime;
			}
			update();
		}
	}
}

pub const StopType = enum { stop, restart };
pub fn stop(_restart: StopType) void {
	if (_restart == .restart) {
		restart = true;
	}
	running.store(false, .release);
}

pub fn disconnect(user: *User) void { // MARK: disconnect()
	if (!user.connected.load(.monotonic)) return;
	removePlayer(user);
	userDeinitList.pushBack(user);
	user.connected.store(false, .monotonic);
}

pub fn removePlayer(user: *User) void { // MARK: removePlayer()
	if (!user.connected.load(.monotonic)) return;

	const foundUser = blk: {
		userMutex.lock();
		defer userMutex.unlock();
		for (users.items, 0..) |other, i| {
			if (other == user) {
				_ = users.swapRemove(i);
				break :blk true;
			}
		}
		break :blk false;
	};
	if (!foundUser) return;

	sendMessage("{s}§#ffff00 left", .{user.name});
	// Let the other clients know about that this new one left.
	const zonArray = main.ZonElement.initArray(root.stackAllocator);
	defer zonArray.deinit(root.stackAllocator);
	zonArray.array.append(.{.int = @intFromEnum(user.id)});
	const data = zonArray.toStringEfficient(root.stackAllocator, &.{});
	defer root.stackAllocator.free(data);
	const userList = getUserList(root.stackAllocator);
	defer root.stackAllocator.free(userList);
	for (userList) |other| {
		root.network.protocols.entity.send(other.conn, data);
	}
}

pub fn connect(user: *User) void {
	userConnectList.pushBack(user);
}

pub fn connectInternal(user: *User) void {
	user.initPlayer();
	root.network.protocols.handShake.sendServerPlayerData(user.conn);
	user.conn.handShakeState.store(.complete, .monotonic);

	// TODO: addEntity(player);
	const userList = getUserList(root.stackAllocator);
	defer root.stackAllocator.free(userList);
	// Check if a user with that account is already present
	if (!world.?.settings.testingMode) {
		for (userList) |other| {
			if (other.playerIndex == user.playerIndex) {
				user.conn.disconnect();
				return;
			}
		}
	}
	// Let the other clients know about this new one.
	{
		const zonArray = main.ZonElement.initArray(root.stackAllocator);
		defer zonArray.deinit(root.stackAllocator);

		const entityZon = user.player().save(root.stackAllocator, .playerNearby);
		zonArray.array.append(entityZon);
		const data = zonArray.toStringEfficient(root.stackAllocator, &.{});
		defer root.stackAllocator.free(data);
		for (userList) |other| {
			root.network.protocols.entity.send(other.conn, data);
		}
	}
	{ // Let this client know about the others:
		const zonArray = main.ZonElement.initArray(root.stackAllocator);
		defer zonArray.deinit(root.stackAllocator);
		for (userList) |other| {
			const entityZon = other.player().save(root.stackAllocator, .playerNearby);
			zonArray.array.append(entityZon);
		}
		const data = zonArray.toStringEfficient(root.stackAllocator, &.{});
		defer root.stackAllocator.free(data);
		if (user.connected.load(.monotonic)) root.network.protocols.entity.send(user.conn, data);
	}
	const initialList = getInitialEntityList(root.stackAllocator);
	root.network.protocols.entity.send(user.conn, initialList);
	root.stackAllocator.free(initialList);
	sendMessage("{s}§#ffff00 joined", .{user.name});

	userMutex.lock();
	users.append(user);
	userMutex.unlock();
}

pub fn messageFrom(msg: []const u8, source: *User) void { // MARK: message
	sendMessage("[{s}§#ffffff] {s}", .{source.name, msg});
}

fn sendRawMessage(msg: []const u8) void {
	chatMutex.lock();
	defer chatMutex.unlock();
	main.log.chat("{s}", .{msg});
	const userList = getUserList(root.stackAllocator);
	defer root.stackAllocator.free(userList);
	for (userList) |user| {
		user.sendRawMessage(msg);
	}
}

var chatMutex: root.utils.Mutex = .{};
pub fn sendMessage(comptime fmt: []const u8, args: anytype) void {
	const msg = root.stackAllocator.print(fmt, args);
	defer root.stackAllocator.free(msg);
	sendRawMessage(msg);
}

pub fn getUserByIndex(index: PlayerIndex) ?*User {
	const userList = getUserList(root.stackAllocator);
	defer root.stackAllocator.free(userList);
	for (userList) |user| {
		if (user.playerIndex == index) {
			return user;
		}
	}
	return null;
}
