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
    
    /// Валидация конфигурации
    pub fn validate(self: *const Self) !void {
        // Проверка порта (1024-65535)
        if (self.port < 1024 or self.port > 65535) {
            std.log.err("Invalid port: {}. Must be between 1024 and 65535", .{self.port});
            return error.InvalidConfig;
        }
        
        // Проверка max_players (1-1000)
        if (self.max_players < 1 or self.max_players > 1000) {
            std.log.err("Invalid max_players: {}. Must be between 1 and 1000", .{self.max_players});
            return error.InvalidConfig;
        }
        
        // Проверка view_distance (2-32)
        if (self.view_distance < 2 or self.view_distance > 32) {
            std.log.err("Invalid view_distance: {}. Must be between 2 and 32", .{self.view_distance});
            return error.InvalidConfig;
        }
        
        // Проверка server_name (1-100 символов)
        if (self.server_name.len < 1 or self.server_name.len > 100) {
            std.log.err("Invalid server_name length: {}. Must be between 1 and 100 characters", .{self.server_name.len});
            return error.InvalidConfig;
        }
        
        std.log.info("Configuration validated successfully", .{});
    }

    pub fn load(args: [][]const u8) !Self {
        var config = Self{};
        
        // 1. Попытка загрузить из файла server.properties
        const cwd = files.cwd();
        if (cwd.openFile("server.properties")) |file| {
            defer file.close(main.io);
            var buf: [65536]u8 = undefined; // Увеличен буфер до 64KB
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
                    } else if (mem.eql(u8, key, "server_name")) {
                        config.server_name = value;
                    } else if (mem.eql(u8, key, "motd")) {
                        config.motd = value;
                    } else if (mem.eql(u8, key, "bind_address")) {
                        config.bind_address = value;
                    } else if (mem.eql(u8, key, "world_name")) {
                        config.world_name = value;
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
        
        // Валидация конфигурации
        try config.validate();

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
