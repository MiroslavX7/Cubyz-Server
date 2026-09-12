const std = @import("std");
const server = @import("server/server.zig");
const config_module = @import("server/config/config.zig");
const log = @import("log.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Initialize logging
    log.init(allocator);

    // Parse command line arguments
    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();
    
    _ = args.skip(); // Skip executable name
    
    var custom_port: ?u16 = null;
    var config_path: ?[]const u8 = null;
    
    while (args.next()) |arg| {
        if (std.mem.startsWith(u8, arg, "--port=")) {
            const port_str = arg[7..];
            custom_port = try std.fmt.parseInt(u16, port_str, 10);
        } else if (std.mem.startsWith(u8, arg, "--config=")) {
            config_path = arg[9..];
        } else if (std.mem.eql(u8, arg, "--help") or std.mem.eql(u8, arg, "-h")) {
            std.debug.print(
                \\Cubyz Dedicated Server
                \\Usage: cubyz-server [options]
                \\
                \\Options:
                \\  --port=<number>    Override server port from config
                \\  --config=<path>    Path to config file (default: serverConfig.zon)
                \\  --help, -h         Show this help message
                \\
            , .{});
            return;
        }
    }

    // Initialize configuration
    var server_config = try config_module.ServerConfig.init(allocator, config_path);
    defer server_config.deinit();

    // Override port if specified in command line
    if (custom_port) |port| {
        server_config.port = port;
    }

    std.debug.print("\n=== Cubyz Dedicated Server ===\n", .{});
    std.debug.print("Starting server on port {d}...\n", .{server_config.port});
    std.debug.print("Max players: {d}\n", .{server_config.maxPlayers});
    std.debug.print("Server name: {s}\n", .{server_config.serverName});
    std.debug.print("MOTD: {s}\n", .{server_config.motd});
    std.debug.print("World directory: {s}\n", .{server_config.worldDirectory});
    std.debug.print("\n", .{});

    // Start the server
    try server.startFromExistingThread(false, null, .multiplayer, server_config);

    // Server loop will run in the background thread
    // Keep main thread alive for stdin command handling
    std.debug.print("Server is running. Type '/help' for commands.\n", .{});
    
    // The server runs until stopped
    while (true) {
        std.time.sleep(std.time.ns_per_s);
    }
}
