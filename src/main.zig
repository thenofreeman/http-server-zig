const std = @import("std");
const builtin = @import("builtin");

const config = @import("config.zig");
const request = @import("request.zig");

const stdout = std.io.getStdOut().writer();

pub const Method = enum {
    GET,

    pub fn init(text: []const u8) !Method {
        return MethodMap.get(text).?;
    }

    pub fn is_supported(m: []const u8) bool {
        const method = MethodMap.get(m);

        if (method) |_| {
            return true;
        }

        return false;
    }
};

// Similar to a hashtable, optimized for small sets
const MethodMap = std.static_string_map.StaticStringMap(Method).initComptime(.{
    .{ "GET", Method.GET },
});

pub fn main() !void {
    const socket = try config.Socket.init();

    try stdout.print("Server Addr: {any}\n", .{socket._address});

    var server = try socket._address.listen(.{});
    const connection = try server.accept();

    var buffer: [1000]u8 = undefined;
    for (0..buffer.len) |i| {
        buffer[i] = 0;
    }

    _ = try request.read_request(connection, buffer[0..buffer.len]);

    try stdout.print("{s}\n", .{buffer});
}
