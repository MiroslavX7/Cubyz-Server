const std = @import("std");
const atomic = std.atomic;
const os = std.os;

pub var shutdown_requested: atomic.Value(bool) = atomic.Value(bool).init(false);

pub fn init() void {
    if (comptime std.Target.current.os.tag == .windows) {
        // Windows: используем SetConsoleCtrlHandler
        _ = os.windows.SetConsoleCtrlHandler(windowsCtrlHandler, true);
    } else {
        // Unix: устанавливаем обработчики сигналов
        const sigaction = os.Sigaction{
            .handler = .{ .handler = unixSignalHandler },
            .mask = empty_sigset,
            .flags = 0,
        };
        os.sigaction(os.SIG.INT, &sigaction, null) catch {};
        os.sigaction(os.SIG.TERM, &sigaction, null) catch {};
    }
}

fn empty_sigset() os.Sigset {
    var set: os.Sigset = undefined;
    @memset(&set, 0);
    return set;
}

fn unixSignalHandler(_: c_int) callconv(.C) void {
    shutdown_requested.store(true, .SeqCst);
}

fn windowsCtrlHandler(ctrl_type: u32) callconv(.C) i32 {
    _ = ctrl_type;
    shutdown_requested.store(true, .SeqCst);
    return 1; // TRUE - обработали
}

pub fn isShutdownRequested() bool {
    return shutdown_requested.load(.SeqCst);
}

pub fn reset() void {
    shutdown_requested.store(false, .SeqCst);
}
