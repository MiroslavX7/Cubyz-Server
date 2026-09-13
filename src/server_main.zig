const std = @import("std");
const builtin = @import("builtin");
const build_options = @import("build_options");

// Server-only imports - no graphics dependencies
pub const log = @import("log_server.zig");
pub const settings = @import("settings_server.zig");
pub const files = @import("files.zig");
pub const heap = @import("utils/heap.zig");
pub const utils = @import("utils.zig");
pub const vec = @import("vec.zig");
pub const meta = @import("meta.zig");
pub const network = @import("network.zig");
pub const server = @import("server/server.zig");
pub const chunk = @import("chunk.zig");
pub const entity = @import("entity.zig");
pub const entityModel = @import("entityModel.zig");
pub const items = @import("items.zig");
pub const systems = @import("systems.zig");
pub const sync = @import("sync.zig");
pub const block_entity = @import("block_entity.zig");
pub const models = @import("models.zig");
pub const rotation = @import("rotation.zig");
pub const assets = @import("assets.zig");
pub const blocks = @import("blocks.zig");
pub const itemdrop = @import("itemdrop.zig");
pub const particles = @import("particles.zig");
pub const blueprint = @import("blueprint.zig");
pub const ZonElement = @import("zon.zig").ZonElement;

threadlocal var stackAllocator: heap.NeverFailingAllocator = undefined;
threadlocal var seed: u64 = undefined;
threadlocal var stackAllocatorBase: heap.StackAllocator = undefined;
pub const globalAllocator: heap.NeverFailingAllocator = heap.allocators.handledGpa.allocator();
pub const globalArena = heap.allocators.globalArenaAllocator.allocator();
pub const worldArena = heap.allocators.worldArenaAllocator.allocator();
pub var threadPool: *utils.ThreadPool = undefined;
var threadedIo: std.Io.Threaded = undefined;
pub var io: std.Io = undefined;

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

// MARK: std_options
pub const std_options: std.Options = .{
    .log_level = .info,
    .logFn = log.logFn,
};

pub fn main() !void {
    defer heap.allocators.deinit();
    defer heap.GarbageCollection.assertAllThreadsStopped();
    initThreadLocals();
    defer deinitThreadLocals();
    threadedIo = .init(globalAllocator.allocator, .{});
    defer threadedIo.deinit();
    io = threadedIo.io();

    log.init();
    defer log.deinit();

    std.log.info("Starting Cubyz dedicated server version {s}", .{settings.version.version});

    // Initialize environment
    const args = std.process.argsAlloc(globalAllocator) catch |err| {
        std.log.err("Failed to allocate memory for command line arguments: {s}", .{@errorName(err)});
        return error.OutOfMemory;
    };
    defer std.process.argsFree(globalAllocator, args);
    
    var args_iter = args.iterator();
    _ = args_iter.skip(); // Skip program name
    settings.environment.init(&args_iter);

    // Initialize launch configuration (creates file if not exists)
    try settings.launchConfig.init();

    // Initialize paths
    {
        const homePath = settings.environment.env.getAlloc(stackAllocator.allocator, if (builtin.os.tag == .windows) "USERPROFILE" else "HOME") catch |err| {
            std.log.err("Failed to get environment variable for home path: {s}", .{@errorName(err)});
            return error.HomePathNotFound;
        };
        defer stackAllocator.free(homePath);
        files.init(homePath);
    }
    defer files.deinit();

    // Initialize server settings from config file
    settings.initServer();
    defer settings.deinitServer();

    // Initialize thread pool
    threadPool = utils.ThreadPool.init(globalAllocator, settings.cpuThreads orelse @max(1, (std.Thread.getCpuCount() catch 4) -| 1));
    defer threadPool.deinit();

    // Initialize utilities
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

    itemdrop.ItemDropRenderer.init();
    defer itemdrop.ItemDropRenderer.deinit();

    assets.init();

    // Initialize network
    try network.init();
    defer network.deinit();

    systems.server.init();
    defer systems.server.deinit();

    entity.server.init();
    defer entity.server.deinit();

    particles.ParticleManager.init();
    defer particles.ParticleManager.deinit();

    server.terrain.globalInit();

    // Start the server
    const worldName = settings.launchConfig.autoEnterWorld;
    if (worldName.len == 0) {
        std.log.err("No world specified. Please set 'autoEnterWorld' in launchConfig.zon or provide a world name.", .{});
        std.posix.exit(1);
    }

    server.startFromExistingThread(worldName, null, .multiplayer);
    heap.GarbageCollection.waitForFreeCompletion();
}

// Export all necessary modules so they can be accessed via @import("main").module_name
pub const random = std.crypto.random;
pub const List = utils.List;
pub const ListManaged = utils.ListManaged;
pub const MultiArray = utils.MultiArray;
pub const NeverFailingAllocator = heap.NeverFailingAllocator;
pub const ErrorHandlingAllocator = heap.ErrorHandlingAllocator;
pub const argparse = @import("argparse.zig");
pub const entity_component = @import("entityComponent/_template.zig");
pub const physics = @import("physics.zig");
pub const migrations = @import("migrations.zig");
pub const callbacks = @import("callbacks/callbacks.zig");
pub const tag = @import("tag.zig");
pub const fmt = @import("fmt.zig");
pub const audio = struct {};
pub const graphics = struct {};
pub const gui = struct {
    pub const Window = struct {};
};
pub const KeyBoard = struct {};
pub const Window = struct {};
pub const lastFrameTime: f64 = 0;
pub const lastDeltaTime: f64 = 0;
pub fn exitToMenu() void {}
