const std = @import("std");
const builtin = @import("builtin");

const main = @import("main");
const mem = std.mem;

var lineBuffer: [1024]u8 = undefined;
var lineLen: usize = 0;

var running: bool = true;

pub fn update() void {
    if (!running) return;

    // Windows-specific implementation using blocking read
    if (builtin.os.tag == .windows) {
        const stdin_file = std.Io.File.stdin();
        
        var byte_buf: [1]u8 = undefined;
        while (true) {
            // Read one byte at a time
            const n = stdin_file.readStreaming(main.io, &.{byte_buf[0..]}) catch |err| {
                if (err == error.EndOfStream) {
                    running = false;
                    return;
                }
                // For other errors, just return and try again next frame
                return;
            };
            
            if (n == 0) {
                // No data available yet
                return;
            }
            
            const c = byte_buf[0];
            if (c == '\n' or c == '\r') {
                if (lineLen > 0) {
                    processLine(lineBuffer[0..lineLen]);
                    lineLen = 0;
                }
                break;
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
        return;
    }

    // Unix implementation (original)
    const result = readFromStdin();
    if (result == 0) return;
    if (result > lineBuffer.len) {
        std.log.warn("Input exceeded {} character limit", .{lineBuffer.len});
        return;
    }
    const msg = mem.trim(u8, lineBuffer[0..result], "\n\r");
    if (msg.len == 0) return;
    if (!std.unicode.utf8ValidateSlice(msg)) {
        std.log.err("Server message contains invalid UTF-8 characters.", .{});
        return;
    }
    processLine(msg);
}

fn processLine(msg: []const u8) void {
    if (msg.len == 0) return;
    
    if (msg[0] == '/') {
        main.server.command.execute(msg[1..], .server);
    } else if (mem.eql(u8, msg, "stop") or mem.eql(u8, msg, "exit") or mem.eql(u8, msg, "quit")) {
        main.server.command.execute("stop", .server);
    } else {
        main.server.sendMessage("<Server> {s}", .{msg});
    }
}

fn readFromStdin() usize {
    const stdin_file = std.Io.File.stdin();
    return stdin_file.readStreaming(main.io, &.{lineBuffer[0..]}) catch |err| {
        std.log.err("Error while reading from stdin: {t}", .{err});
        running = false;
        return 0;
    };
}
