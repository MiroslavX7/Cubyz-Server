const std = @import("std");
const builtin = @import("builtin");
const mem = std.mem;

const main = @import("main");

var readBuffer: [100_000]u8 = undefined;

var running: bool = true;

pub fn update() void {
	if (!running) return;
	if (builtin.os.tag == .windows) {
		// На Windows используем простой опрос stdin без таймаутов
		const result = simpleReadFromStdin();
		if (result == 0) return;
		processInput(result);
		return;
	}
	const result = readFromStdin();
	if (result == readBuffer.len) {
		std.log.warn("Input exceeded {} character limit", .{readBuffer.len});
		while (readFromStdin() != 0) {}
		return;
	}
	processInput(result);
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

fn simpleReadFromStdin() usize {
	// Простое чтение stdin для Windows без использования таймаутов
	const stdin_file = std.Io.File.stdin();
	var line_buffer: [1024]u8 = undefined;
	
	// Читаем данные из stdin напрямую в буфер
	const bytes_read = stdin_file.read(main.io, &line_buffer) catch |err| {
		if (err == error.EndOfStream) return 0;
		std.log.err("Error reading stdin on Windows: {t}", .{err});
		return 0;
	};
	
	if (bytes_read == 0) return 0;
	
	// Копируем прочитанные данные в основной буфер ввода
	if (bytes_read > readBuffer.len) bytes_read = readBuffer.len;
	@memcpy(readBuffer[0..bytes_read], line_buffer[0..bytes_read]);
	
	return bytes_read;
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
