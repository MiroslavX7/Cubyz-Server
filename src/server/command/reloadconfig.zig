const std = @import("std");

const main = @import("main");
const NeverFailingAllocator = main.heap.NeverFailingAllocator;
const ListManaged = main.ListManaged;
const command = main.server.command;
const Source = command.Source;

pub const description = "Reloads server configuration from server.properties file.";
pub const usage = "/reloadconfig";

pub const Args = union(enum) {
    @"/reloadconfig": struct {},
};

pub fn execute(args: Args, source: Source) void {
    _ = args;
    var msg: main.ListManaged(u8) = .init(main.stackAllocator);
    defer msg.deinit();
    
    const args_array = [_][]const u8{};
    _ = main.config.ServerConfig.load(&args_array) catch |err| {
        msg.appendSlice("#ff0000Failed to reload configuration: ");
        msg.appendSlice(@errorName(err));
        source.sendMessage("{s}", .{msg.items});
        return;
    };
    
    msg.appendSlice("#00ff00Configuration reloaded successfully!");
    source.sendMessage("{s}", .{msg.items});
}
