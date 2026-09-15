const std = @import("std");
const builtin = @import("builtin");

pub var shutdown_requested: std.atomic.Value(bool) = std.atomic.Value(bool).init(false);

pub fn init() void {
    if (comptime builtin.target.os.tag == .windows) {
        const windows = std.os.windows;
        const HandlerRoutine = *const fn (ctrl_type: u32) callconv(.winapi) u32;
        
        var handler: HandlerRoutine = struct {
            fn handle(ctrl_type: u32) callconv(.winapi) u32 {
                _ = ctrl_type;
                shutdown_requested.store(true, .seq_cst);
                return 1;
            }
        }.handle;
        
        _ = windows.SetConsoleCtrlHandler(@ptrCast(&handler), true);
    } else {
        const posix = std.posix;
        const sigaction = posix.Sigaction{
            .handler = .{ .handler = @ptrCast(&unixSignalHandlerWrapper) },
            .mask = posix.sigemptyset(),
            .flags = 0,
        };
        posix.sigaction(posix.SIG.INT, &sigaction, null);
        posix.sigaction(posix.SIG.TERM, &sigaction, null);
    }
}

fn unixSignalHandlerWrapper(sig: c_int) callconv(.c) void {
    _ = sig;
    shutdown_requested.store(true, .seq_cst);
}

pub fn isShutdownRequested() bool {
    return shutdown_requested.load(.seq_cst);
}

pub fn reset() void {
    shutdown_requested.store(false, .seq_cst);
}
