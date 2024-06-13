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
    try stdout.print("client connected!", .{});
    try handleConnection(connection);
}

fn handleConnection(connection: net.Server.Connection) !void {
    try connection.stream.writeAll("HTTP/1.1 200 OK\r\n\r\n");
}
