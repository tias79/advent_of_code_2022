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

    var result : u16 = 14;
    var tmp : [14]u8 = undefined;
    try in_stream.readNoEof(&tmp);

    if (!try match(tmp)) {
        while (true) {
            var b = try in_stream.readByte();
            for (tmp[0..tmp.len-1]) |_, i| {
                tmp[i] = tmp[i+1];
            }
            tmp[tmp.len-1] = b;
            result += 1;

            if (try match(tmp)) {
                break;
            }
        }
    }

    try stdout.print("Result: {d}\n", .{result});

    try bw.flush();
}

fn match(buf : [14]u8) anyerror!bool {
    var tmp : [14]u8 = undefined;
    mem.copy(u8, &tmp, &buf);
    std.sort.sort(u8, &tmp, {}, comptime std.sort.asc(u8));

    for (tmp[0..tmp.len-1]) |_, i| {
        if (tmp[i] == tmp[i+1]) {
            return false;
        }
    }

    return true;
}
