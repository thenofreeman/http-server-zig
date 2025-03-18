const std = @import("std");
const builtin = @import("builtin");

const config = @import("config.zig");

const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    const socket = try config.Socket.init();

    try stdout.print("Server Addr: {any}\n", .{socket._address});

    var server = try socket._address.listen(.{});
    const connection = try server.accept();
    _ = connection;
}
