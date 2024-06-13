const std = @import("std");
const net = std.net;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    // You can use print statements as follows for debugging, they'll be visible when running tests.
    try stdout.print("Logs from your program will appear here!\n", .{});

    const address = try net.Address.resolveIp("127.0.0.1", 4221);
    var listener = try address.listen(.{
        .reuse_address = true,
    });
    defer listener.deinit();

    const connection = try listener.accept();
    try stdout.print("client connected!\n", .{});
    try handleConnection(connection);
}

fn handleConnection(connection: net.Server.Connection) !void {
    const stdout = std.io.getStdOut().writer();

    var buffer: [1024]u8 = undefined;
    const bufferSize = try connection.stream.read(buffer[0..]);
    const request = buffer[0..bufferSize];

    try stdout.print("Received request: {s}\n", .{request});

    var splits = std.mem.split(u8, request, " ");

    // Skip the first part of the request, which is the method (GET, POST, etc.)
    _ = splits.next();

    // Extract url from the request
    const url = splits.next() orelse "";

    if (std.mem.eql(u8, url, "/")) {
        try connection.stream.writeAll("HTTP/1.1 200 OK\r\n\r\n");
    } else {
        try connection.stream.writeAll("HTTP/1.1 404 Not Found\r\n\r\n");
    }
}
