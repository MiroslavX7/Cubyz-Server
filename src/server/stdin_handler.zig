const std = @import("std");
const builtin = @import("builtin");
const mem = std.mem;
const fs = std.fs;

const main = @import("main");

var lineBuffer: [1024]u8 = undefined;
var lineLen: usize = 0;

var running: bool = true;

pub fn update() void {
    if (!running) return;
    
    const stdin = fs.stdio.getStdIn();
    var reader = stdin.reader();
    
    // Читаем по одному байту неблокирующим образом (насколько это возможно)
    var byte_buf: [1]u8 = undefined;
    
    // Пытаемся прочитать один байт
    const n = reader.read(&byte_buf) catch return;
    if (n == 0) return; // Нет данных
    
    const byte = byte_buf[0];
    
    if (byte == '\n' or byte == '\r') {
        if (lineLen > 0) {
            processInput(lineLen);
            lineLen = 0;
        }
    } else if (lineLen < lineBuffer.len - 1) {
        lineBuffer[lineLen] = byte;
        lineLen += 1;
    }
}

fn processInput(len: usize) void {
    const msg = std.mem.trim(u8, lineBuffer[0..len], "\n\r");
    if (msg.len == 0) return;
    if (!std.unicode.utf8ValidateSlice(msg)) {
        std.log.err("Server message contains invalid UTF-8 characters.", .{});
        return;
    }
    if (msg[0] == '/') {
        main.server.command.execute(msg[1..], .server);
    } else if (mem.eql(u8, msg, "stop") or mem.eql(u8, msg, "exit") or mem.eql(u8, msg, "quit")) {
        main.server.command.execute("stop", .server);
    } else {
        main.server.sendMessage("<Server> {s}", .{msg});
    }
}
