const std = @import("std");
const root = @import("root");
const files = root.files;
const fmt = root.fmt;
const List = root.List;
const settings = root.settings;

pub const Level = enum {
	/// Error: something has gone wrong. This might be recoverable or might
	/// be followed by the program exiting.
	err,
	/// Warning: it is uncertain if something has gone wrong or not, but the
	/// circumstances would be worth investigating.
	warn,
	/// Info: general messages about the state of the program.
	info,
	/// Debug: messages only useful for debugging.
	debug,
	/// server messages
	server,
	/// chat messages
	chat,

	fn isColorCoded(self: Level) bool {
		return self == .chat or self == .server;
	}

	fn fromStdLevel(level: std.log.Level) Level {
		return switch (level) {
			.err => .err,
			.warn => .warn,
			.info => .info,
			.debug => .debug,
		};
	}
};

var logFile: ?std.Io.File = undefined;
var logFileTs: ?std.Io.File = undefined;
var supportsANSIColors: bool = undefined;
var openingErrorWindow: bool = false;

pub fn logFn(
	comptime level: std.log.Level,
	comptime _: @EnumLiteral(),
	comptime format: []const u8,
	args: anytype,
) void {
	var runtimeArgs: [args.len]fmt.FormatArg = undefined;
	inline for (0..args.len) |i| {
		runtimeArgs[i] = .fromAnytype(@TypeOf(args[i]), &args[i]);
	}

	runtimeLogFn(.fromStdLevel(level), format, &runtimeArgs);
}

noinline fn runtimeLogFn(level: Level, format: []const u8, args: []const fmt.FormatArg) void {
	var buf: [65536]u8 = undefined;
	var writer: std.Io.Writer = .fixed(&buf);
	fmt.format(&writer, format, args) catch {
		std.log.err("Truncated long log message.", .{});
	};

	const color: []const u8 = switch (level) {
		.err => "\x1b[31m",
		.info => "",
		.warn => "\x1b[33m",
		.debug => "\x1b[37;44m",
		.server => "\x1b[34mserver\x1b[0m: ",
		.chat => "\x1b[36mchat\x1b[0m: ",
	};
	const colorReset = "\x1b[0m\n";
	const filePrefix = switch (level) {
		.err => "error",
		.warn => "warning",
		.info => "info",
		.debug => "debug",
		.server => "server",
		.chat => "chat",
	};
	const fileSuffix = "\n";

	logToFile("[{s}]: {s}{s}", .{filePrefix, writer.buffered(), fileSuffix});
	if (supportsANSIColors) {
		logToStdErr(level, "{s}{s}{s}", .{color, writer.buffered(), colorReset});
	} else {
		logToStdErr(level, "[{s}]: {s}{s}", .{filePrefix, writer.buffered(), fileSuffix});
	}

	// GUI error window only for non-headless mode
	_ = openingErrorWindow; // silence unused warning
}

pub fn init() void {
	logFile = null;
	files.cwd().makePath("logs") catch |err| {
		std.log.err("Couldn't create logs folder: {s}", .{@errorName(err)});
		return;
	};
	logFile = std.Io.Dir.cwd().createFile(root.io, "logs/latest.log", .{}) catch |err| {
		std.log.err("Couldn't create logs/latest.log: {s}", .{@errorName(err)});
		return;
	};

	const _timestamp = std.Io.Clock.Timestamp.now(root.io, .real).raw;

	const _path_str = root.stackAllocator.print("logs/ts_{}.log", .{_timestamp.nanoseconds});
	defer root.stackAllocator.free(_path_str);

	logFileTs = std.Io.Dir.cwd().createFile(root.io, _path_str, .{}) catch |err| {
		std.log.err("Couldn't create {s}: {s}", .{_path_str, @errorName(err)});
		return;
	};

	supportsANSIColors = std.Io.File.stdout().supportsAnsiEscapeCodes(root.io) catch unreachable;
}

pub fn deinit() void {
	if (logFile) |_logFile| {
		_logFile.close(root.io);
		logFile = null;
	}

	if (logFileTs) |_logFileTs| {
		_logFileTs.close(root.io);
		logFileTs = null;
	}
}

fn logToFile(comptime format: []const u8, args: anytype) void {
	var buf: [65536]u8 = undefined;
	var fba = std.heap.FixedBufferAllocator.init(&buf);
	const allocator = fba.allocator();

	const string = std.fmt.allocPrint(allocator, format, args) catch format;
	(logFile orelse return).writeStreamingAll(root.io, string) catch {};
	(logFileTs orelse return).writeStreamingAll(root.io, string) catch {};
}

fn logToStdErr(level: Level, comptime format: []const u8, args: anytype) void {
	var buf: [65536]u8 = undefined;
	var fba = std.heap.FixedBufferAllocator.init(&buf);
	const allocator = fba.allocator();

	const _string = std.fmt.allocPrint(allocator, format, args) catch format;
	const string = if (level.isColorCoded() and supportsANSIColors) convertColorToANSI(root.stackAllocator, _string) else _string;
	defer if (level.isColorCoded() and supportsANSIColors) root.stackAllocator.free(string);

	const writer = std.debug.lockStderr(&.{});
	defer std.debug.unlockStderr();
	nosuspend writer.file_writer.interface.writeAll(string) catch {};
}

// Simplified ANSI color conversion for server - no graphics dependencies
fn convertColorToANSI(allocator: root.heap.NeverFailingAllocator, text: []const u8) []const u8 {
	// For server mode, just return the text as-is
	// The color codes are already embedded in the text from runtimeLogFn
	return allocator.dupe(u8, text);
}

pub fn server(comptime format: []const u8, args: anytype) void {
	var runtimeArgs: [args.len]fmt.FormatArg = undefined;
	inline for (0..args.len) |i| {
		runtimeArgs[i] = .fromAnytype(@TypeOf(args[i]), &args[i]);
	}
	runtimeLogFn(.server, format, &runtimeArgs);
}

pub fn chat(comptime format: []const u8, args: anytype) void {
	var runtimeArgs: [args.len]fmt.FormatArg = undefined;
	inline for (0..args.len) |i| {
		runtimeArgs[i] = .fromAnytype(@TypeOf(args[i]), &args[i]);
	}
	runtimeLogFn(.chat, format, &runtimeArgs);
}
