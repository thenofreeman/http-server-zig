const std = @import("std");

const Connection = std.net.Server.Connection;

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

pub fn read_request(conn: Connection, buffer: []u8) !void {
    const reader = conn.stream.reader();

    _ = try reader.read(buffer);
}

pub fn parse_request(text: []u8) Request {
    const line_index = std.mem.indexOfScalar(u8, text, '\n') orelse text.len;

    var iterator = std.mem.splitScalar(u8, text[0..line_index], ' ');

    const method = try Method.init(iterator.next().?);
    const uri = iterator.next().?;
    const version = iterator.next().?;
    const request = Request.init(method, uri, version);

    return request;
}

const Request = struct {
    method: Method,
    version: []const u8,
    uri: []const u8,

    pub fn init(method: Method, uri: []const u8, version: []const u8) Request {
        return Request {
            .method = method,
            .uri = uri,
            .version = version,
        };
    }
};
