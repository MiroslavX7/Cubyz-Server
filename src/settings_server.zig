const std = @import("std");
const builtin = @import("builtin");

// Server-specific settings - no graphics dependencies
pub const version = @import("utils/version.zig");

pub const defaultPort: u16 = 47649;
pub const connectionTimeout = 60_000_000;

pub const entityLookback: i16 = 100;

pub var simulationDistance: u16 = 4;

pub var cpuThreads: ?u64 = null;

pub var playerName: []const u8 = "";

pub var showPlayerIndexWithName: bool = false;

pub var lastUsedIPAddress: []const u8 = "";

pub var storageTime: std.Io.Duration = .fromSeconds(5);

pub var updateRepeatSpeed: std.Io.Duration = .fromMilliseconds(200);

pub var updateRepeatDelay: std.Io.Duration = .fromMilliseconds(500);

const settingsFile = if (builtin.mode == .Debug) "debug_settings.zig.zon" else "settings.zig.zon";

pub fn initServer() void {
    // Server initialization code here
}

pub fn deinitServer() void {
    // Server cleanup code here
}

pub const launchConfig = struct {
    pub var cubyzDir: []const u8 = "";
    pub var autoEnterWorld: []const u8 = "";
    pub var headlessServer: bool = true;
    pub var preferredAuthenticationAlgorithm: KeyTypeEnum = .ed25519;

    const KeyTypeEnum = enum {
        ed25519,
        rsa,
    };

    pub fn init() !void {
        const zon = std.files.cwd().readToZon(std.heap.general_purpose_allocator, "launchConfig.zon") catch |err| blk: {
            // File doesn't exist, create it with defaults
            std.log.info("launchConfig.zon not found, creating with defaults", .{});
            const defaultConfig = 
                \\.{
                \\    .cubyzDir = "",
                \\    .autoEnterWorld = "",
                \\    .headlessServer = true,
                \\}
            ;
            try std.files.cwd().writeFile(.{
                .data = defaultConfig,
                .sub_path = "launchConfig.zon",
            });
            break :blk .null;
        };
        defer zon.deinit(std.heap.general_purpose_allocator);

        // Parse with error handling - use defaults for invalid values
        cubyzDir = globalArena.dupe(u8, zon.get([]const u8, "cubyzDir") orelse cubyzDir);
        autoEnterWorld = globalArena.dupe(u8, zon.get([]const u8, "autoEnterWorld") orelse autoEnterWorld);
        headlessServer = zon.get(bool, "headlessServer") orelse true;
        preferredAuthenticationAlgorithm = zon.get(KeyTypeEnum, "preferredAuthenticationAlgorithm") orelse .ed25519;
    }
};

pub const environment = struct {
    pub var env: std.process.Environ = undefined;

    pub fn init(_env: std.process.Environ) void {
        env = _env;
    }
};
