const std = @import("std");
const fmt = std.fmt;

pub fn main() anyerror!void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var local_max: u32 = 0;

    var buf: [1024]u8 = undefined;
    var elves: [1000]u32 = undefined;
    var current_elf : u8 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 0) {
            elves[current_elf] = local_max;
            local_max = 0;
            current_elf = current_elf + 1;
        } else {
            const guess = try fmt.parseUnsigned(u32, line, 10);
            local_max = local_max + guess;
        }
    }

    elves[current_elf] = local_max;
    current_elf = current_elf + 1;

    std.sort.sort(u32, elves[0..current_elf], {}, comptime std.sort.desc(u32));

    var result : u32 = 0;
    for (elves[0..3]) |elf| {
        result += elf;
    }
    try stdout.print("Result: {d}\n", .{result});

    try bw.flush();
}