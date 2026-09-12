const std = @import("std");

// Server-specific logging - no graphics dependencies
pub const Level = enum {
    err,
    warn,
    info,
    debug,
    server,
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

pub fn logFn(
    comptime level: std.log.Level,
    comptime _: @EnumLiteral(),
    comptime format: []const u8,
    args: anytype,
) void {
    runtimeLogFn(.fromStdLevel(level), format, args);
}

noinline fn runtimeLogFn(level: Level, comptime format: []const u8, args: anytype) void {
    var buf: [65536]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    const allocator = fba.allocator();
    
    const formatted = std.fmt.allocPrint(allocator, format, args) catch format;
    
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

    logToFile("[{s}]: {s}{s}", .{ filePrefix, formatted, fileSuffix });
    if (supportsANSIColors) {
        logToStdErr("{s}{s}{s}", .{ color, formatted, colorReset });
    } else {
        logToStdErr("[{s}]: {s}{s}", .{ filePrefix, formatted, fileSuffix });
    }
}

pub fn init() void {
    logFile = null;
    logFileTs = null;
    
    // Try to create logs directory and files, but don't fail if it doesn't work
    std.files.cwd().makePath("logs") catch {
        std.log.err("Couldn't create logs folder", .{});
        return;
    };
    
    logFile = std.Io.Dir.cwd().createFile(std.io.default_io, "logs/latest.log", .{}) catch |err| {
        std.log.err("Couldn't create logs/latest.log: {s}", .{@errorName(err)});
        return;
    };

    const _timestamp = std.Io.Clock.Timestamp.now(std.io.default_io, .real).raw;
    const _path_str = std.fmt.allocPrint(std.heap.page_allocator, "logs/ts_{}.log", .{_timestamp.nanoseconds}) catch return;
    defer std.heap.page_allocator.free(_path_str);

    logFileTs = std.Io.Dir.cwd().createFile(std.io.default_io, _path_str, .{}) catch |err| {
        std.log.err("Couldn't create {s}: {s}", .{ _path_str, @errorName(err) });
        return;
    };

    supportsANSIColors = std.Io.File.stdout().supportsAnsiEscapeCodes(std.io.default_io) catch false;
}

pub fn deinit() void {
    if (logFile) |_logFile| {
        _logFile.close(std.io.default_io);
        logFile = null;
    }

    if (logFileTs) |_logFileTs| {
        _logFileTs.close(std.io.default_io);
        logFileTs = null;
    }
}

fn logToFile(comptime format: []const u8, args: anytype) void {
    if (logFile == null) return;
    
    var buf: [65536]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    const allocator = fba.allocator();

    const string = std.fmt.allocPrint(allocator, format, args) catch format;
    logFile.?.writeStreamingAll(std.io.default_io, string) catch {};
    if (logFileTs) |file| {
        file.writeStreamingAll(std.io.default_io, string) catch {};
    }
}

fn logToStdErr(comptime format: []const u8, args: anytype) void {
    const writer = std.debug.lockStderr(&.{});
    defer std.debug.unlockStderr();
    std.fmt.format(writer.writer(), format, args) catch {};
}

pub fn server(comptime format: []const u8, args: anytype) void {
    runtimeLogFn(.server, format, args);
}

pub fn chat(comptime format: []const u8, args: anytype) void {
    runtimeLogFn(.chat, format, args);
}
