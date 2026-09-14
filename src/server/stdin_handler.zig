const std = @import("std");
const builtin = @import("builtin");
const mem = std.mem;

const main = @import("main");

var readBuffer: [100_000]u8 = undefined;
var lineBuffer: [1024]u8 = undefined;

var running: bool = true;

pub fn update() void {
    if (!running) return;
    
    // Используем простой blocking read с таймаутом через отдельный подход
    // Читаем по одному байту, проверяя доступность
    const stdin = std.io.getStdIn();
    var reader = stdin.reader();
    
    // Проверяем, есть ли данные для чтения (неблокирующая проверка)
    // В Zig нет прямого API для этого, поэтому используем простой подход:
    // пытаемся прочитать с очень маленьким буфером
    
    var byte_buf: [1]u8 = undefined;
    
    // Пытаемся прочитать первый байт
    const first_byte = reader.read(&byte_buf) catch |err| {
        std.log.err("Error reading stdin: {}", .{err});
        return;
    };
    
    if (first_byte == 0) return; // Нет данных
    
    // Есть данные, читаем остальную строку
    var total_read: usize = 0;
    readBuffer[0] = byte_buf[0];
    total_read = 1;
    
    // Читаем остальные символы до новой строки
    while (total_read < readBuffer.len) {
        const n = reader.read(&byte_buf) catch break;
        if (n == 0) break;
        
        readBuffer[total_read] = byte_buf[0];
        total_read += 1;
        
        if (byte_buf[0] == '\n') break;
    }
    
    processInput(total_read);
}

fn processInput(result: usize) void {
    const msg = std.mem.trim(u8, readBuffer[0..result], "\n\r");
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
