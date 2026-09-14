const std = @import("std");
const builtin = @import("builtin");

const main = @import("main");
const mem = std.mem;
const os = std.os;

var lineBuffer: [1024]u8 = undefined;
var lineLen: usize = 0;

var running: bool = true;

pub fn update() void {
    if (!running) return;

    if (builtin.os.tag == .windows) {
        updateWindows();
    } else {
        updateUnix();
    }
}

fn updateWindows() void {
    const windows = os.windows;
    const stdin_handle = windows.GetStdHandle(windows.STD_INPUT_HANDLE);
    if (stdin_handle == windows.INVALID_HANDLE_VALUE) return;

    var events_available: u32 = 0;
    if (windows.GetNumberOfConsoleInputEvents(stdin_handle, &events_available) == 0) return;
    if (events_available == 0) return;

    var input_record: windows.INPUT_RECORD = undefined;
    var events_read: u32 = 0;

    if (windows.ReadConsoleInputA(stdin_handle, &input_record, 1, &events_read) == 0) return;
    if (events_read == 0) return;

    if (input_record.EventType != windows.KEY_EVENT) return;
    if (input_record.Event.KeyEvent.bKeyDown == 0) return;

    const key = input_record.Event.KeyEvent.uChar.AsciiChar;
    
    if (key == '\r' or key == '\n') {
        if (lineLen > 0) {
            processLine(lineBuffer[0..lineLen]);
            lineLen = 0;
        }
    } else if (key == 8 or key == 127) { // Backspace or Delete
        if (lineLen > 0) {
            lineLen -= 1;
        }
    } else if (key >= 32 or key == 9) { // Printable characters or tab
        if (lineLen < lineBuffer.len) {
            lineBuffer[lineLen] = key;
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
        main.server.command.execute("stop", .server);
    } else {
        main.server.sendMessage("<Server> {s}", .{msg});
    }
}
