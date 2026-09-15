const std = @import("std");
const atomic = std.atomic;
const builtin = @import("builtin");
const posix = std.posix;
const linux = std.os.linux;

pub var shutdown_requested: atomic.Value(bool) = atomic.Value(bool).init(false);

pub fn init() void {
    if (comptime builtin.target.os.tag == .windows) {
        // Windows: заглушка, обработка Ctrl+C будет через консольный ввод
        // В Zig 0.16 нет прямого доступа к SetConsoleCtrlHandler
    } else {
        // Unix: устанавливаем обработчики сигналов
        const sigaction = posix.Sigaction{
            .handler = .{ .handler = @ptrCast(@alignCast(unixSignalHandlerWrapper)) },
            .mask = empty_sigset(),
            .flags = 0,
        };
        posix.sigaction(posix.SIG.INT, &sigaction, null) catch {};
        posix.sigaction(posix.SIG.TERM, &sigaction, null) catch {};
    }
}

fn empty_sigset() posix.Sigset {
    var set: posix.Sigset = undefined;
    @memset(&set, 0);
    return set;
}

fn unixSignalHandlerWrapper(sig: c_int) callconv(.c) void {
    _ = sig;
    shutdown_requested.store(true, .seq_cst);
}

fn unixSignalHandler(_: c_int) callconv(.c) void {
    shutdown_requested.store(true, .seq_cst);
}

fn windowsCtrlHandler(ctrl_type: u32) callconv(.c) i32 {
    _ = ctrl_type;
    shutdown_requested.store(true, .seq_cst);
    return 1; // TRUE - обработали
}

pub fn isShutdownRequested() bool {
    return shutdown_requested.load(.seq_cst);
}

pub fn reset() void {
    shutdown_requested.store(false, .seq_cst);
}
