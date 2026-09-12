const std = @import("std");

const main = @import("main");
const ZonElement = main.ZonElement;

/// Server configuration structure - essential settings for dedicated server
pub const ServerConfig = struct {
    /// Server port (default: 47649)
    pub var port: u16 = 47649,
    
    /// Maximum number of players (default: 32)
    pub var maxPlayers: u16 = 32,
    
    /// Server name displayed in server list
    pub var serverName: []const u8 = "Cubyz Dedicated Server",
    
    /// Server description/MOTD
    pub var motd: []const u8 = "Welcome to Cubyz!",
    
    /// Enable whitelist (default: false)
    pub var whitelistEnabled: bool = false,
    
    /// Enable PvP (default: true)
    pub var pvpEnabled: bool = true,
    
    /// Game difficulty (0=peaceful, 1=easy, 2=normal, 3=hard)
    pub var difficulty: u8 = 2,
    
    /// World seed (null for random)
    pub var seed: ?i64 = null,
    
    /// Default gamemode (0=survival, 1=creative, 2=adventure, 3=spectator)
    pub var defaultGamemode: u8 = 0,
    
    /// Render distance for players (default: 8)
    pub var renderDistance: u16 = 8,
    
    /// Simulation distance (default: 4)
    pub var simulationDistance: u16 = 4,
    
    /// Tick rate (ticks per second, default: 20)
    pub var tickRate: u32 = 20,
    
    /// Auto-save interval in seconds (default: 45)
    pub var autoSaveInterval: u32 = 45,
    
    /// Spawn protection radius in blocks (default: 16)
    pub var spawnProtectionRadius: u16 = 16,
    
    /// IP address to bind to (empty = all interfaces)
    pub var bindAddress: []const u8 = "",
    
    /// Enable debug logging (default: false)
    pub var debugLogging: bool = false,
    
    /// RCON password (optional, for remote administration)
    pub var rconPassword: ?[]const u8 = null,
    
    /// RCON port (default: same as port + 1)
    pub var rconPort: ?u16 = null,
    
    /// World directory
    pub var worldDirectory: []const u8 = "world",
    
    /// Players data directory
    pub var playersDirectory: []const u8 = "players",
    
    /// Logs directory
    pub var logsDirectory: []const u8 = "logs",
};

var configInitialized: bool = false;

/// Initialize configuration from file
pub fn init(allocator: std.mem.Allocator, custom_path: ?[]const u8) !ServerConfig {
    var config = ServerConfig{};
    
    const config_file_path = custom_path orelse "serverConfig.zon";
    const zon: ZonElement = main.files.cwd().readToZon(main.stackAllocator, config_file_path) catch |err| blk: {
        if (err != error.FileNotFound) {
            std.log.err("Could not read serverConfig.zon: {s}", .{@errorName(err)});
        }
        break :blk .null;
    };
    defer zon.deinit(main.stackAllocator);
    
    // Load all config values from ZON file
    inline for (@typeInfo(ServerConfig).@"struct".decls) |decl| {
        const is_const = @typeInfo(@TypeOf(&@field(ServerConfig, decl.name))).pointer.is_const;
        if (!is_const) {
            const DeclType = @TypeOf(@field(ServerConfig, decl.name));
            
            if (@typeInfo(DeclType) == .optional) {
                const ChildType = @typeInfo(DeclType).optional.child;
                if (ChildType == []const u8) {
                    if (zon.get([]const u8, decl.name)) |value| {
                        @field(config, decl.name) = allocator.dupe(u8, value) catch return error.OutOfMemory;
                    }
                } else {
                    @field(config, decl.name) = zon.get(ChildType, decl.name);
                }
            } else if (DeclType == []const u8) {
                @field(config, decl.name) = allocator.dupe(u8, zon.get([]const u8, decl.name) orelse @field(ServerConfig, decl.name)) catch return error.OutOfMemory;
            } else {
                @field(config, decl.name) = zon.get(DeclType, decl.name) orelse @field(ServerConfig, decl.name);
            }
        }
    }
    
    return config;
}

/// Deinitialize configuration (free allocated memory)
pub fn deinit(self: *ServerConfig, allocator: std.mem.Allocator) void {
    inline for (@typeInfo(ServerConfig).@"struct".decls) |decl| {
        const is_const = @typeInfo(@TypeOf(&@field(ServerConfig, decl.name))).pointer.is_const;
        if (!is_const) {
            const DeclType = @TypeOf(@field(ServerConfig, decl.name));
            if (DeclType == []const u8) {
                if (@field(self, decl.name).len > 0) {
                    allocator.free(@field(self, decl.name));
                }
            } else if (@typeInfo(DeclType) == .optional) {
                const ChildType = @typeInfo(DeclType).optional.child;
                if (ChildType == []const u8) {
                    if (@field(self, decl.name)) |value| {
                        allocator.free(value);
                    }
                }
            }
        }
    }
}

/// Save current configuration to file
pub fn save() void {
    var zonObject = ZonElement.initObject(main.stackAllocator);
    defer zonObject.deinit(main.stackAllocator);
    
    inline for (@typeInfo(ServerConfig).@"struct".decls) |decl| {
        const is_const = @typeInfo(@TypeOf(&@field(ServerConfig, decl.name))).pointer.is_const;
        if (!is_const) {
            const DeclType = @TypeOf(@field(ServerConfig, decl.name));
            if (DeclType == []const u8) {
                zonObject.putOwnedString(decl.name, @field(ServerConfig, decl.name));
            } else if (@typeInfo(DeclType) == .optional) {
                const ChildType = @typeInfo(DeclType).optional.child;
                if (ChildType == []const u8) {
                    if (@field(ServerConfig, decl.name)) |value| {
                        zonObject.putOwnedString(decl.name, value);
                    }
                } else {
                    zonObject.put(decl.name, @field(ServerConfig, decl.name));
                }
            } else {
                zonObject.put(decl.name, @field(ServerConfig, decl.name));
            }
        }
    }
    
    main.files.cwd().writeZon("serverConfig.zon", zonObject) catch |err| {
        std.log.err("Couldn't write server config to file: {s}", .{@errorName(err)});
    };
}

/// Get a config value by name (for commands)
pub fn getValue(name: []const u8) ?[]const u8 {
    inline for (@typeInfo(ServerConfig).@"struct".decls) |decl| {
        if (std.mem.eql(u8, decl.name, name)) {
            const value = @field(ServerConfig, decl.name);
            const DeclType = @TypeOf(value);
            
            if (DeclType == []const u8) {
                return value;
            } else if (@typeInfo(DeclType) == .optional) {
                const ChildType = @typeInfo(DeclType).optional.child;
                if (ChildType == []const u8) {
                    return value;
                }
            }
            
            // Convert other types to string
            return main.stackAllocator.print("{any}", .{value});
        }
    }
    return null;
}

/// Set a config value by name (for commands)
pub fn setValue(name: []const u8, value: []const u8) bool {
    inline for (@typeInfo(ServerConfig).@"struct".decls) |decl| {
        if (std.mem.eql(u8, decl.name, name)) {
            const DeclType = @TypeOf(@field(ServerConfig, decl.name));
            
            if (DeclType == []const u8) {
                @field(ServerConfig, decl.name) = main.globalArena.dupe(u8, value);
                return true;
            } else if (@typeInfo(DeclType) == .bool) {
                if (std.mem.eql(u8, value, "true")) {
                    @field(ServerConfig, decl.name) = true;
                    return true;
                } else if (std.mem.eql(u8, value, "false")) {
                    @field(ServerConfig, decl.name) = false;
                    return true;
                }
            } else if (@typeInfo(DeclType) == .int) {
                if (std.fmt.parseInt(i64, value, 10)) |intValue| {
                    @field(ServerConfig, decl.name) = @truncate(intValue);
                    return true;
                }
            } else if (@typeInfo(DeclType) == .float) {
                if (std.fmt.parseFloat(f64, value)) |floatValue| {
                    @field(ServerConfig, decl.name) = @truncate(floatValue);
                    return true;
                }
            }
            return false;
        }
    }
    return false;
}

/// List all config keys
pub fn getKeys() [][]const u8 {
    const keys = main.stackAllocator.alloc([]const u8, @typeInfo(ServerConfig).@"struct".decls.len);
    for (@typeInfo(ServerConfig).@"struct".decls, 0..) |decl, i| {
        keys[i] = decl.name;
    }
    return keys;
}
