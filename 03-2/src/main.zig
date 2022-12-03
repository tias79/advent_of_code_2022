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
        comp:  [100]u8,
        size: usize
    };

    var buf: [100]u8 = undefined;
    var rucksacks: [10000]Rucksack = undefined;
    var i : u16 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var comp: [100]u8 = undefined;
        mem.copy(u8, &comp, line);

        const r = Rucksack {
            .comp = comp,
            .size = line.len
        };

        rucksacks[i] = r;
        i += 1;
    }

    var result : u32 = 0;
    var j: u16 = 0;
    while (j < i) {
        var prio : u8 = 0;
        for (rucksacks[j].comp[0..rucksacks[j].size])|item1| {
            for (rucksacks[j+1].comp[0..rucksacks[j+1].size])|item2| {
                for (rucksacks[j+2].comp[0..rucksacks[j+2].size])|item3| {
                    if (item1 == item2 and item2 == item3) {
                        if (item1 >= 'a' and item1 <= 'z') {
                            prio = item1 - 'a' + 1;
                        } else {
                            prio = item1 - 'A' + 27;
                        }
                    }
                }
            }            
        }
        result += prio;
        try stdout.print("Rucksack: {d}\n", .{prio});
        j += 3;
    }

    try stdout.print("Result: {d}\n", .{result});

    try bw.flush();
}