const std = @import("std");
const builtin = @import("builtin");

const main = @import("main");

var readBuffer: [100_000]u8 = undefined;
var running: bool = true;

pub fn init() void {
    // Nothing special needed
}

pub fn update() void {
    if (!running) return;
    
    // Windows console input is not supported in Zig's std.Io
    // Show warning and disable stdin handling on Windows
    if (builtin.os.tag == .windows) {
        std.log.warn("Console stdin is currently not supported on Windows", .{});
        running = false;
        return;
    }
    
    const result = readFromStdin();
    if (result == readBuffer.len) {
        std.log.warn("Input exceeded {} character limit", .{readBuffer.len});
        while (readFromStdin() != 0) {}
        return;
    }
    const msg = std.mem.trim(u8, readBuffer[0..result], "\n\r");
    processLine(msg);
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
