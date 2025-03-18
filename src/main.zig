const std = @import("std");
const builtin = @import("builtin");

const stdout = std.io.getStdOut().writer();

pub const Socket = struct {
    _address: std.net.Address,
    _stream: std.net.Stream,

    pub fn init() !Socket {
        const host = [4]u8 { 127, 0, 0, 1 };
        const port = 3490;
        const addr = std.net.Address.initIp4(host, port);

        const socket = try std.posix.socket(
            addr.any.family,
            std.posix.SOCK.STREAM,
            std.posix.IPPROTO.TCP
        );
        const stream = std.net.Stream { .handle = socket };

        return Socket { ._address = addr, ._stream = stream };
    }
};

pub fn main() !void {
    const socket = try Socket.init();

    try stdout.print("Server Addr: {any}\n", .{socket._address});

    var server = try socket._address.listen(.{});
    const connection = try server.accept();
    _ = connection;
}
