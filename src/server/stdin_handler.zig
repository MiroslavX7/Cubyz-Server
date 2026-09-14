const std = @import("std");
const builtin = @import("builtin");

const main = @import("main");
const mem = std.mem;
const fs = std.fs;

var lineBuffer: [1024]u8 = undefined;
var lineLen: usize = 0;

var running: bool = true;

pub fn update() void {
    if (!running) return;

    // Windows-specific implementation using non-blocking read
    if (builtin.os.tag == .windows) {
        const stdin_file = fs.File.stdin();
        
        // Пытаемся установить неблокирующий режим, игнорируя ошибки если не поддерживается
        stdin_file.setBlockingMode(false) catch {};
        
        var byte_buf: [1]u8 = undefined;
        while (true) {
            // Читаем один байт
            const n = stdin_file.read(&byte_buf) catch |err| {
                if (err == error.WouldBlock) {
                    // Нет данных доступно, выходим без ошибки
                    return;
                }
                if (err == error.EndOfStream) {
                    running = false;
                    return;
                }
                // Для других ошибок просто выходим и пробуем снова в следующем кадре
                return;
            };
            
            if (n == 0) {
                // Нет данных доступно еще
                return;
            }
            
            const c = byte_buf[0];
            if (c == '\n' or c == '\r') {
                if (lineLen > 0) {
                    processLine(lineBuffer[0..lineLen]);
                    lineLen = 0;
                }
                break;
            } else if (c == 0x08 or c == 0x7F) { // Backspace или Delete
                if (lineLen > 0) {
                    lineLen -= 1;
                }
            } else if (c >= 32 or c == 9) { // Печатаемые символы или табуляция
                if (lineLen < lineBuffer.len) {
                    lineBuffer[lineLen] = c;
                    lineLen += 1;
                }
            }
        }
        
        // Возвращаем блокирующий режим для безопасности
        stdin_file.setBlockingMode(true) catch {};
        return;
    }

    // Unix реализация (оригинальная)
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
    const stdin_file = fs.File.stdin();
    // Устанавливаем неблокирующий режим для Unix тоже
    stdin_file.setBlockingMode(false) catch {};
    
    const result = stdin_file.read(&lineBuffer) catch |err| {
        if (err == error.WouldBlock) {
            return 0;
        }
        std.log.err("Error while reading from stdin: {t}", .{err});
        running = false;
        return 0;
    };
    
    // Возвращаем блокирующий режим
    stdin_file.setBlockingMode(true) catch {};
    
    return result;
}
