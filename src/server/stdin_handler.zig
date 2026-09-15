const std = @import("std");
const builtin = @import("builtin");

const main = @import("main");
const signal_handler = @import("signal_handler.zig");

var readBuffer: [100_000]u8 = undefined;
var running: bool = true;
var stdinThread: ?std.Thread = null;

pub fn init() void {
    // Start stdin handler in a separate thread on all platforms
    stdinThread = std.Thread.spawn(.{}, runStdinLoop, .{}) catch |err| {
        std.log.err("Failed to spawn stdin thread: {s}", .{@errorName(err)});
        running = false;
    };
}

pub fn deinit() void {
    running = false;
    if (stdinThread) |thread| {
        // Ждём завершения потока ввода
        // В будущем можно добавить таймаут
        _ = thread;
    }
}

pub fn update() void {
    // This function is now a no-op on non-Windows as stdin runs in its own thread
    // On Windows, it just returns immediately
    if (!running) return;
}

fn runStdinLoop() void {
    while (running and !signal_handler.isShutdownRequested()) {
        const result = readFromStdin();
        if (result == 0) {
            // No data available, sleep briefly to avoid busy-waiting
            std.time.sleep(10 * std.time.ns_per_ms);
            continue;
        }
        
        // Проверка на переполнение буфера (лимит 100KB)
        if (result >= readBuffer.len - 1) {
            std.log.warn("Input exceeded {} character limit, clearing buffer", .{readBuffer.len});
            // Очищаем stdin от оставшихся данных
            var dummy: [1024]u8 = undefined;
            while (std.io.getStdIn().reader().read(&dummy) catch break) |_| {}
            continue;
        }
        
        const msg = std.mem.trim(u8, readBuffer[0..result], "\n\r");
        processLine(msg);
    }
}

fn readFromStdin() usize {
    const result = main.io.operateTimeout(.{.file_read_streaming = .{
        .data = &.{&readBuffer},
        .file = std.Io.File.stdin(),
    }}, .{.duration = .{.raw = .zero, .clock = .awake}}) catch |err| {
        if (err == error.Timeout) return 0;
        std.log.err("Error while reading from stdin: {t}", .{err});
        running = false;
        return 0;
    };
    return result.file_read_streaming catch |err| {
        std.log.err("Error while reading from stdin: {t}", .{err});
        running = false;
        return 0;
    };
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
