const std = @import("std");
const fmt = std.fmt;

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var local_max: u64 = 0;
    var global_max: u64 = 0;

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 0) {
            if (local_max > global_max) {
                global_max = local_max;
            }
            local_max = 0;
        } else {
            const guess = try fmt.parseUnsigned(u32, line, 10);
            local_max = local_max + guess;
        }
    }

    if (local_max > global_max) {
        global_max = local_max;
    }

    try stdout.print("Max: {d}\n", .{global_max});
    try bw.flush();
}