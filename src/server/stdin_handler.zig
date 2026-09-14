const std = @import("std");
const builtin = @import("builtin");

const main = @import("main");
const mem = std.mem;

var lineBuffer: [1024]u8 = undefined;
var lineLen: usize = 0;

var running: bool = true;

pub fn update() void {
    if (!running) return;

    // Use the project's existing IO system for cross-platform compatibility
    const stdin_file = main.io.getStdIn();
    const reader = stdin_file.reader();
    
    var byte_buf: [1]u8 = undefined;
    while (true) {
        const n = reader.read(&byte_buf) catch |err| {
            if (err == error.WouldBlock) {
                return;
            }
            if (err == error.EndOfStream) {
                running = false;
                return;
            }
            // On Windows, console input might not be supported in non-interactive mode
            // Just return and try again next frame
            return;
        };
        
        if (n == 0) {
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
