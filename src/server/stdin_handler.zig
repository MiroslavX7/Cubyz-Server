const std = @import("std");
const builtin = @import("builtin");

const main = @import("main");
const mem = std.mem;
const os = std.os;

var lineBuffer: [1024]u8 = undefined;
var lineLen: usize = 0;

var running: bool = true;

// No init needed - readStreaming already handles non-blocking with WouldBlock error
pub fn init() void {
    // stdin is already handled in non-blocking mode via readStreaming error handling
}

pub fn update() void {
    if (!running) return;

    if (builtin.os.tag == .windows) {
        updateWindows();
    } else {
        updateUnix();
    }
}

fn updateWindows() void {
    const stdin_file = std.Io.File.stdin();
    var byte_buf: [1]u8 = undefined;
    
    const n = stdin_file.readStreaming(main.io, &.{byte_buf[0..1]}) catch |err| {
        if (err == error.WouldBlock) {
            return;
        }
        if (err == error.EndOfStream) {
            running = false;
            return;
        }
        return;
    };

    if (n == 0) return;

    const c = byte_buf[0];
    if (c == '\n' or c == '\r') {
        if (lineLen > 0) {
            processLine(lineBuffer[0..lineLen]);
            lineLen = 0;
        }
    } else if (c == 0x08 or c == 0x7F) { // Backspace or Delete
        if (lineLen > 0) {
            lineLen -= 1;
        }
    } else if (c >= 32 or c == 9) { // Printable characters or tab
        if (lineLen < lineBuffer.len) {
            lineBuffer[lineLen] = c;
            lineLen += 1;
        }
    }
}

fn updateUnix() void {
    const stdin = std.Io.File.stdin();
    var byte_buf: [1]u8 = undefined;
    
    const n = stdin.readStreaming(main.io, &.{byte_buf[0..1]}) catch |err| {
        if (err == error.WouldBlock) {
            return;
        }
        if (err == error.EndOfStream) {
            running = false;
            return;
        }
        return;
    };

    if (n == 0) return;

    const c = byte_buf[0];
    if (c == '\n' or c == '\r') {
        if (lineLen > 0) {
            processLine(lineBuffer[0..lineLen]);
            lineLen = 0;
        }
    } else if (c == 0x08 or c == 0x7F) { // Backspace or Delete
        if (lineLen > 0) {
            lineLen -= 1;
        }
    } else if (c >= 32 or c == 9) { // Printable characters or tab
        if (lineLen < lineBuffer.len) {
            lineBuffer[lineLen] = c;
            lineLen += 1;
        }
    }
}

fn processLine(msg: []const u8) void {
    if (msg.len == 0) return;

    if (msg[0] == '/') {
        main.server.command.execute(msg[1..], .server);
    } else if (mem.eql(u8, msg, "stop") or mem.eql(u8, msg, "exit") or mem.eql(u8, msg, "quit")) {
        main.server.command.execute("server stop", .server);
    } else {
        main.server.sendMessage("<Server> {s}", .{msg});
    }
}
