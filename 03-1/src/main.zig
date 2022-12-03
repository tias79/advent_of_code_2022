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

    const Rucksack = struct {
        comp1:  [100]u8,
        comp2:  [100]u8,
        size: usize
    };

    var buf: [100]u8 = undefined;
    var rucksacks: [10000]Rucksack = undefined;
    var i : u16 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var size : usize = line.len / 2;
        const comp1_slice = line[0..size];
        var comp1 : [100]u8 = undefined;
        mem.copy(u8, &comp1, comp1_slice);
        const comp2_slice = line[size..line.len];
        var comp2 : [100]u8 = undefined;
        mem.copy(u8, &comp2, comp2_slice);

        const r = Rucksack {
            .size = size,
            .comp1 = comp1,
            .comp2 = comp2
        };

        rucksacks[i] = r;
        i += 1;
    }

    var result : u32 = 0;
    for (rucksacks[0..i]) |rucksack| {
        var prio : u8 = 0;
        for (rucksack.comp1[0..rucksack.size])|item1| {
            for (rucksack.comp2[0..rucksack.size])|item2| {
                if (item1 == item2) {
                    if (item1 >= 'a' and item1 <= 'z') {
                        prio = item1 - 'a' + 1;
                    } else {
                        prio = item1 - 'A' + 27;
                    }
                }
            }            
        }
        result += prio;
        try stdout.print("Rucksack: {d}\n", .{prio});
    }

    try stdout.print("Result: {d}\n", .{result});

    try bw.flush();
}