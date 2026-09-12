const std = @import("std");

const main = @import("main");
const command = main.server.command;
const Source = command.Source;

pub const description = "View or modify server configuration.";
pub const usage =
    \\/config <key>              - Get a config value
    \\/config <key> <value>      - Set a config value
    \\/config list               - List all config keys
    \\/config save               - Save current config to file
    \\/config reload             - Reload config from file
;

pub const Args = union(enum) {
    get: struct { key: []const u8 },
    set: struct { key: []const u8, value: []const u8 },
    list: void,
    save: void,
    reload: void,
};

pub fn execute(args: Args, source: Source) void {
    const config = main.server.config.ServerConfig;
    
    switch (args) {
        .get => |g| {
            if (config.getValue(g.key)) |value| {
                source.sendMessage("#00ff00Config '{s}' = {s}", .{ g.key, value });
            } else {
                source.sendMessage("#ff0000Unknown config key: {s}", .{g.key});
            }
        },
        
        .set => |s| {
            if (config.setValue(s.key, s.value)) {
                source.sendMessage("#00ff00Config '{s}' set to '{s}'", .{ s.key, s.value });
            } else {
                source.sendMessage("#ff0000Failed to set config '{s}' (invalid value or type mismatch)", .{s.key});
            }
        },
        
        .list => {
            const keys = config.getKeys();
            source.sendMessage("#00ff00Available config keys ({d}):", .{keys.len});
            for (keys) |key| {
                source.sendMessage("  - {s}", .{key});
            }
        },
        
        .save => {
            config.save();
            source.sendMessage("#00ff00Configuration saved to serverConfig.zon", .{});
        },
        
        .reload => {
            config.deinit();
            config.init();
            source.sendMessage("#00ff00Configuration reloaded from serverConfig.zon", .{});
        },
    }
}
