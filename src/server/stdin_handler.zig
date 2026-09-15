const std = @import("std");
const builtin = @import("builtin");

const main = @import("main");
const signal_handler = @import("signal_handler.zig");

var readBuffer: [100_000]u8 = undefined;
var running: bool = true;

pub fn init() void {
    _ = std.Thread.spawn(.{}, runStdinLoop, .{});
}

pub fn deinit() void {
    running = false;
}

pub fn update() void {
    if (!running) return;
}

fn runStdinLoop() void {
    var buffer_pos: usize = 0;
    const stdin_file = std.Io.File.stdin();
    var reader = stdin_file.reader();
    
    while (running and !signal_handler.isShutdownRequested()) {
        const byte = reader.readByte() catch {
            std.Thread.sleep(10 * std.time.ns_per_ms);
            continue;
        };
        
        if (buffer_pos >= readBuffer.len - 1) {
            std.log.warn("Input exceeded {} character limit, clearing buffer", .{readBuffer.len});
            buffer_pos = 0;
            // Clear remaining input until newline
            while (reader.readByte() catch break) |b| {
                if (b == '\n') break;
            }
            continue;
        }
        
        if (byte == '\n' or byte == '\r') {
            if (buffer_pos > 0) {
                const msg = std.mem.trim(u8, readBuffer[0..buffer_pos], " \t\n\r");
                processLine(msg);
                buffer_pos = 0;
            }
        } else {
            readBuffer[buffer_pos] = byte;
            buffer_pos += 1;
        }
    }
}

fn processLine(msg: []const u8) void {
    if (msg.len == 0) return;
    
    if (!std.unicode.utf8ValidateSlice(msg)) {
        std.log.err("Server message contains invalid UTF-8 characters.", .{});
        return;
    }
    
    if (std.mem.eql(u8, msg, "stop") or std.mem.eql(u8, msg, "/stop") or
        std.mem.eql(u8, msg, "quit") or std.mem.eql(u8, msg, "/quit") or
        std.mem.eql(u8, msg, "exit") or std.mem.eql(u8, msg, "/exit")) {
        main.server.stop(.stop);
        running = false;
        return;
    }
    
    if (std.mem.startsWith(u8, msg, "/server ")) {
        const args = msg["/server ".len..];
        if (std.mem.eql(u8, std.mem.trim(u8, args, " \t\r\n"), "stop")) {
            main.server.stop(.stop);
            running = false;
            return;
        }
    }
    
    if (msg[0] == '/') {
        main.server.command.execute(msg[1..], .server);
    } else {
        main.server.sendMessage("<Server> {s}", .{msg});
    }
}
