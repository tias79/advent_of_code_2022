const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;

pub fn main() anyerror!void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var tmp: [4]u8 = undefined;
    var result : u16 = 4;

    tmp[0] = try in_stream.readByte();
    tmp[1] = try in_stream.readByte();
    tmp[2] = try in_stream.readByte();
    tmp[3] = try in_stream.readByte();

    if (!match(tmp)) {
        while (true) {
            var b = try in_stream.readByte();
            tmp[0] = tmp[1];
            tmp[1] = tmp[2];
            tmp[2] = tmp[3];
            tmp[3] = b;
            result += 1;

            if (match(tmp)) {
                break;
            }
        }
    }

    try stdout.print("Result: {d}\n", .{result});

    try bw.flush();
}

fn match(buf : [4]u8) bool {
    const r1 = buf[0] != buf[1] and buf[0] != buf[2] and buf[0] != buf[3];
    const r2 = buf[1] != buf[0] and buf[1] != buf[2] and buf[1] != buf[3];
    const r3 = buf[2] != buf[0] and buf[2] != buf[1] and buf[2] != buf[3];
    const r4 = buf[3] != buf[0] and buf[3] != buf[1] and buf[3] != buf[2];
    return r1 and r2 and r3 and r4;
}
