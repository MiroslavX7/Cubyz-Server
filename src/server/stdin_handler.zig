const std = @import("std");
const builtin = @import("builtin");
const io = std.io;

const main = @import("main");
const signal_handler = @import("signal_handler.zig");

var readBuffer: [100_000]u8 = undefined;
var running: bool = true;

pub fn init() void {
    // Start stdin handler in a separate thread on all platforms
    _ = std.Thread.spawn(.{}, runStdinLoop, .{}) catch |err| {
        std.log.err("Failed to spawn stdin thread: {s}", .{@errorName(err)});
        running = false;
    };
}

pub fn deinit() void {
    running = false;
    // Ждём завершения потока ввода (в будущем можно добавить таймаут)
}

pub fn update() void {
    // This function is now a no-op on non-Windows as stdin runs in its own thread
    // On Windows, it just returns immediately
    if (!running) return;
}

fn runStdinLoop() void {
    var buffer_pos: usize = 0;
    const stdin_reader = std.io.getStdIn().reader();
    
    while (running and !signal_handler.isShutdownRequested()) {
        var byte_buf: [1]u8 = undefined;
        const n = stdin_reader.read(&byte_buf) catch |err| {
            std.log.err("Error reading from stdin: {}", .{err});
            break;
        };
        
        if (n == 0) {
            // No data available, sleep briefly to avoid busy-waiting
            std.Thread.sleep(10 * std.time.ns_per_ms);
            continue;
        }
        
        const byte = byte_buf[0];
        
        // Проверка на переполнение буфера (лимит 100KB)
        if (buffer_pos >= readBuffer.len - 1) {
            std.log.warn("Input exceeded {} character limit, clearing buffer", .{readBuffer.len});
            buffer_pos = 0;
            // Очищаем stdin от оставшихся данных до конца строки
            var dummy: [1]u8 = undefined;
            while (stdin_reader.read(&dummy) catch break) |_| {
                if (dummy[0] == '\n') break;
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
    
    // Check for stop commands first (with or without slash)
    // Support both original /server stop and simple stop/quit/exit
    if (std.mem.eql(u8, msg, "stop") or std.mem.eql(u8, msg, "/stop") or
        std.mem.eql(u8, msg, "quit") or std.mem.eql(u8, msg, "/quit") or
        std.mem.eql(u8, msg, "exit") or std.mem.eql(u8, msg, "/exit")) {
        main.server.stop(.stop);
        running = false;
        return;
    }
    
    // Handle /server stop command (original format)
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
