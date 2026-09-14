const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const Allocator = mem.Allocator;
const files = @import("files.zig");
const main = @import("main.zig");

pub const ServerConfig = struct {
    max_players: u32 = 20,
    bind_address: []const u8 = "0.0.0.0",
    port: u16 = 47649,
    world_name: []const u8 = "world",
    view_distance: u8 = 16,
    server_name: []const u8 = "Cubyz Server",
    allow_unsupported_clients: bool = false,
    motd: []const u8 = "A Cubyz Server",
    pvp: bool = true,
    generate_spawn: bool = true,

    const Self = @This();

    pub fn load(args: [][]const u8) !Self {
        var config = Self{};
        
        // 1. Попытка загрузить из файла server.properties
        const cwd = files.cwd();
        if (cwd.openFile("server.properties")) |file| {
            defer file.close(main.io);
            var buf: [4096]u8 = undefined;
            const len = try std.Io.File.readPositionalAll(file, main.io, &buf, 0);
            const content = buf[0..len];
            
            var lines = mem.splitScalar(u8, content, '\n');
            while (lines.next()) |line| {
                const trimmed = mem.trim(u8, line, " \t\r");
                if (trimmed.len == 0 or trimmed[0] == '#') continue;
                
                if (mem.indexOfScalar(u8, trimmed, '=')) |sep| {
                    const key = mem.trim(u8, trimmed[0..sep], " \t");
                    const value = mem.trim(u8, trimmed[sep+1..], " \t\r");
                    
                    if (mem.eql(u8, key, "max_players")) {
                        config.max_players = try std.fmt.parseInt(u32, value, 10);
                    } else if (mem.eql(u8, key, "port")) {
                        config.port = try std.fmt.parseInt(u16, value, 10);
                    } else if (mem.eql(u8, key, "view_distance")) {
                        config.view_distance = try std.fmt.parseInt(u8, value, 10);
                    } else if (mem.eql(u8, key, "allow_unsupported_clients")) {
                        config.allow_unsupported_clients = mem.eql(u8, value, "true");
                    } else if (mem.eql(u8, key, "pvp")) {
                        config.pvp = mem.eql(u8, value, "true");
                    }
                }
            }
        } else |err| {
            if (err != error.FileNotFound) return err;
            // Файл не найден, создадим дефолтный
            try Self.saveDefault(cwd);
            std.debug.print("Created default server.properties\n", .{});
        }

        // 2. Переопределение аргументами командной строки
        var i: usize = 0;
        while (i < args.len) : (i += 1) {
            const arg = args[i];
            if (mem.startsWith(u8, arg, "--")) {
                const key = arg[2..];
                if (i + 1 < args.len) {
                    const value = args[i + 1];
                    i += 1;
                    
                    if (mem.eql(u8, key, "max-players")) {
                        config.max_players = try std.fmt.parseInt(u32, value, 10);
                    } else if (mem.eql(u8, key, "port")) {
                        config.port = try std.fmt.parseInt(u16, value, 10);
                    } else if (mem.eql(u8, key, "view-distance")) {
                        config.view_distance = try std.fmt.parseInt(u8, value, 10);
                    } else if (mem.eql(u8, key, "allow-unsupported")) {
                        config.allow_unsupported_clients = mem.eql(u8, value, "true");
                    } else if (mem.eql(u8, key, "pvp")) {
                        config.pvp = mem.eql(u8, value, "true");
                    }
                }
            }
        }

        return config;
    }

    fn saveDefault(dir: files.Dir) !void {
        const content = 
            \\# Cubyz Server Configuration
            \\# Maximum number of players allowed on the server
            \\max_players=20
            \\
            \\# IP address to bind to (0.0.0.0 for all)
            \\bind_address=0.0.0.0
            \\
            \\# Server port
            \\port=47649
            \\
            \\# Name of the world folder (inside saves/)
            \\world_name=world
            \\
            \\# View distance in chunks (recommended: 4-16)
            \\view_distance=16
            \\
            \\# Server name displayed in the client list
            \\server_name=Cubyz Server
            \\
            \\# Allow clients with mismatched protocol version to connect
            \\allow_unsupported_clients=false
            \\
            \\# Message of the Day
            \\motd=A Cubyz Server
            \\
            \\# Enable PvP combat
            \\pvp=true
            \\
            \\# Generate spawn point if world is empty
            \\generate_spawn=true
            \\
        ;
        try dir.write("server.properties", content);
    }
};
