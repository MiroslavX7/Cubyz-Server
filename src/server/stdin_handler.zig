const std = @import("std");
const builtin = @import("builtin");

const main = @import("main");

var readBuffer: [100_000]u8 = undefined;
var running: bool = true;
var stdinThread: ?std.Thread = null;

pub fn init() void {
    // В Zig 0.16.0 spawn - это функция, возвращающая !std.Thread
    stdinThread = std.Thread.spawn(.{}, runStdinLoop, .{}) catch |err| {
        std.log.err("Failed to spawn stdin thread: {s}", .{@errorName(err)});
        running = false;
        return;
    };
}

pub fn deinit() void {
    running = false;
    if (stdinThread) |thread| {
        thread.join();
    }
}

pub fn update() void {
    // No-op - stdin runs in its own thread
}

fn runStdinLoop() void {
    while (running) {
        const result = readFromStdin();
        if (result == 0) {
            // В Zig 0.16.0 используем main.io.sleep() вместо std.time.sleep()
            main.io.sleep(.fromMilliseconds(10), .awake) catch {};
            continue;
        }
        if (result == readBuffer.len) {
            std.log.warn("Input exceeded {} character limit", .{readBuffer.len});
            // Очистка буфера stdin при переполнении
            while (readFromStdin() != 0) {}
            continue;
        }
        const msg = std.mem.trim(u8, readBuffer[0..result], "\n\r");
        processLine(msg);
    }
}

fn readFromStdin() usize {
    // Используем существующий API main.io из проекта
    const result = main.io.operateTimeout(.{
        .file_read_streaming = .{
            .data = &.{&readBuffer},
            .file = std.Io.File.stdin(),
        }
    }, .{.duration = .{.raw = .zero, .clock = .awake}}) catch |err| {
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