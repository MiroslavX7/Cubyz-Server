const std = @import("std");
const windows = std.os.windows;

const main = @import("main");
const ZonElement = main.ZonElement;

/// Server configuration structure - essential settings for dedicated server
pub const ServerConfig = struct {
    /// Server port (default: 47649)
    pub var port: u16 = 47649;
    
    /// Maximum number of players (default: 32)
    pub var maxPlayers: u16 = 32;
    
    /// Server name displayed in server list
    pub var serverName: []const u8 = "Cubyz Dedicated Server";
    
    /// Server description/MOTD
    pub var motd: []const u8 = "Welcome to Cubyz!";
    
    /// Enable whitelist (default: false)
    pub var whitelistEnabled: bool = false;
    
    /// Enable PvP (default: true)
    pub var pvpEnabled: bool = true;
    
    /// Game difficulty (0=peaceful, 1=easy, 2=normal, 3=hard)
    pub var difficulty: u8 = 2;
    
    /// World seed (null for random)
    pub var seed: ?i64 = null;
    
    /// Default gamemode (0=survival, 1=creative, 2=adventure, 3=spectator)
    pub var defaultGamemode: u8 = 0;
    
    /// Render distance for players (default: 8)
    pub var renderDistance: u16 = 8;
    
    /// Simulation distance (default: 4)
    pub var simulationDistance: u16 = 4;
    
    /// Tick rate (ticks per second, default: 20)
    pub var tickRate: u32 = 20;
    
    /// Auto-save interval in seconds (default: 45)
    pub var autoSaveInterval: u32 = 45;
    
    /// Spawn protection radius in blocks (default: 16)
    pub var spawnProtectionRadius: u16 = 16;
    
    /// IP address to bind to (empty = all interfaces)
    pub var bindAddress: []const u8 = "";
    
    /// Enable debug logging (default: false)
    pub var debugLogging: bool = false;
    
    /// RCON password (optional, for remote administration)
    pub var rconPassword: ?[]const u8 = null;
    
    /// RCON port (default: same as port + 1)
    pub var rconPort: ?u16 = null;
    
    /// World directory
    pub var worldDirectory: []const u8 = "world";
    
    /// Players data directory
    pub var playersDirectory: []const u8 = "players";
    
    /// Logs directory
    pub var logsDirectory: []const u8 = "logs";
};

var configInitialized: bool = false;
var configLoadError: ?[]const u8 = null;

/// Initialize configuration from file with error handling
pub fn init(allocator: std.mem.Allocator) !void {
    if (configInitialized) return;
    
    // Try to read and parse config file
    const result = loadConfigFile(allocator) catch |err| {
        const errorMsg = switch (err) {
            error.FileNotFound => "serverConfig.zon not found. Using default values.",
            error.InvalidZonSyntax => "Invalid ZON syntax in serverConfig.zon",
            error.OutOfMemory => "Out of memory while parsing config",
            else => "Failed to load serverConfig.zon",
        };
        
        configLoadError = errorMsg;
        std.log.err("{s}", .{errorMsg});
        std.log.err("Using default configuration values.", .{});
        
        // Show error and wait for user input before continuing
        waitForUserInput();
        
        return;
    };
    
    // Apply loaded values
    if (result) |loadedConfig| {
        applyLoadedConfig(loadedConfig, allocator);
        loadedConfig.deinit(allocator);
    }
    
    configInitialized = true;
}

/// Load configuration from file
fn loadConfigFile(allocator: std.mem.Allocator) !?struct {
    port: ?u16,
    maxPlayers: ?u16,
    serverName: ?[]const u8,
    motd: ?[]const u8,
    whitelistEnabled: ?bool,
    pvpEnabled: ?bool,
    difficulty: ?u8,
    seed: ?i64,
    defaultGamemode: ?u8,
    renderDistance: ?u16,
    simulationDistance: ?u16,
    tickRate: ?u32,
    autoSaveInterval: ?u32,
    spawnProtectionRadius: ?u16,
    bindAddress: ?[]const u8,
    debugLogging: ?bool,
    rconPassword: ?[]const u8,
    rconPort: ?u16,
    worldDirectory: ?[]const u8,
    playersDirectory: ?[]const u8,
    logsDirectory: ?[]const u8,
} {
    const file = main.files.cwd().openFile("serverConfig.zon", .{}) catch return error.FileNotFound;
    defer file.close();
    
    const content = file.readAllAlloc(allocator, 1024 * 1024) catch return error.OutOfMemory;
    defer allocator.free(content);
    
    // Parse ZON content
    var parser = ZonElement.Parser.init(allocator);
    defer parser.deinit();
    
    const zon = parser.parse(content) catch {
        std.log.err("Failed to parse serverConfig.zon - invalid syntax", .{});
        return error.InvalidZonSyntax;
    };
    defer zon.deinit(allocator);
    
    if (zon == .null) return null;
    
    return .{
        .port = zon.get(u16, "port"),
        .maxPlayers = zon.get(u16, "maxPlayers"),
        .serverName = zon.get([]const u8, "serverName"),
        .motd = zon.get([]const u8, "motd"),
        .whitelistEnabled = zon.get(bool, "whitelistEnabled"),
        .pvpEnabled = zon.get(bool, "pvpEnabled"),
        .difficulty = zon.get(u8, "difficulty"),
        .seed = zon.get(i64, "seed"),
        .defaultGamemode = zon.get(u8, "defaultGamemode"),
        .renderDistance = zon.get(u16, "renderDistance"),
        .simulationDistance = zon.get(u16, "simulationDistance"),
        .tickRate = zon.get(u32, "tickRate"),
        .autoSaveInterval = zon.get(u32, "autoSaveInterval"),
        .spawnProtectionRadius = zon.get(u16, "spawnProtectionRadius"),
        .bindAddress = zon.get([]const u8, "bindAddress"),
        .debugLogging = zon.get(bool, "debugLogging"),
        .rconPassword = zon.get([]const u8, "rconPassword"),
        .rconPort = zon.get(u16, "rconPort"),
        .worldDirectory = zon.get([]const u8, "worldDirectory"),
        .playersDirectory = zon.get([]const u8, "playersDirectory"),
        .logsDirectory = zon.get([]const u8, "logsDirectory"),
    };
}

/// Apply loaded configuration values
fn applyLoadedConfig(loaded: @TypeOf(loadConfigFile(null)), allocator: std.mem.Allocator) void {
    if (loaded.port) |v| ServerConfig.port = v;
    if (loaded.maxPlayers) |v| ServerConfig.maxPlayers = v;
    if (loaded.serverName) |v| ServerConfig.serverName = allocator.dupe(u8, v) catch ServerConfig.serverName;
    if (loaded.motd) |v| ServerConfig.motd = allocator.dupe(u8, v) catch ServerConfig.motd;
    if (loaded.whitelistEnabled) |v| ServerConfig.whitelistEnabled = v;
    if (loaded.pvpEnabled) |v| ServerConfig.pvpEnabled = v;
    if (loaded.difficulty) |v| ServerConfig.difficulty = v;
    if (loaded.seed) |v| ServerConfig.seed = v;
    if (loaded.defaultGamemode) |v| ServerConfig.defaultGamemode = v;
    if (loaded.renderDistance) |v| ServerConfig.renderDistance = v;
    if (loaded.simulationDistance) |v| ServerConfig.simulationDistance = v;
    if (loaded.tickRate) |v| ServerConfig.tickRate = v;
    if (loaded.autoSaveInterval) |v| ServerConfig.autoSaveInterval = v;
    if (loaded.spawnProtectionRadius) |v| ServerConfig.spawnProtectionRadius = v;
    if (loaded.bindAddress) |v| ServerConfig.bindAddress = allocator.dupe(u8, v) catch ServerConfig.bindAddress;
    if (loaded.debugLogging) |v| ServerConfig.debugLogging = v;
    if (loaded.rconPassword) |v| ServerConfig.rconPassword = allocator.dupe(u8, v) catch ServerConfig.rconPassword;
    if (loaded.rconPort) |v| ServerConfig.rconPort = v;
    if (loaded.worldDirectory) |v| ServerConfig.worldDirectory = allocator.dupe(u8, v) catch ServerConfig.worldDirectory;
    if (loaded.playersDirectory) |v| ServerConfig.playersDirectory = allocator.dupe(u8, v) catch ServerConfig.playersDirectory;
    if (loaded.logsDirectory) |v| ServerConfig.logsDirectory = allocator.dupe(u8, v) catch ServerConfig.logsDirectory;
}

/// Wait for user to press a key before continuing
fn waitForUserInput() void {
    std.debug.print("\nPress any key to continue with default configuration...\n", .{});
    
    // Windows-specific: wait for key press
    const stdin = windows.GetStdHandle(windows.STD_INPUT_HANDLE);
    var event: windows.INPUT_RECORD = undefined;
    var events_read: u32 = 0;
    
    while (true) {
        windows.ReadConsoleInputA(stdin, &event, 1, &events_read) catch break;
        if (events_read > 0 and event.EventType == windows.KEY_EVENT and event.Event.KeyEvent.bKeyDown != 0) {
            break;
        }
    }
}

/// Deinitialize configuration (free allocated memory)
pub fn deinit() void {
    if (!configInitialized) return;
    
    // Free allocated strings
    if (ServerConfig.serverName.len > 0 and ServerConfig.serverName.ptr != "Cubyz Dedicated Server".ptr) {
        main.globalAllocator.free(ServerConfig.serverName);
    }
    if (ServerConfig.motd.len > 0 and ServerConfig.motd.ptr != "Welcome to Cubyz!".ptr) {
        main.globalAllocator.free(ServerConfig.motd);
    }
    if (ServerConfig.bindAddress.len > 0) {
        main.globalAllocator.free(ServerConfig.bindAddress);
    }
    if (ServerConfig.rconPassword) |v| {
        main.globalAllocator.free(v);
    }
    if (ServerConfig.worldDirectory.len > 0 and ServerConfig.worldDirectory.ptr != "world".ptr) {
        main.globalAllocator.free(ServerConfig.worldDirectory);
    }
    if (ServerConfig.playersDirectory.len > 0 and ServerConfig.playersDirectory.ptr != "players".ptr) {
        main.globalAllocator.free(ServerConfig.playersDirectory);
    }
    if (ServerConfig.logsDirectory.len > 0 and ServerConfig.logsDirectory.ptr != "logs".ptr) {
        main.globalAllocator.free(ServerConfig.logsDirectory);
    }
    
    configInitialized = false;
}
