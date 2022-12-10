const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;
const math = std.math;

const InstrcutionType = enum {
    addx,
    noop,
};
const Instruction = union(InstrcutionType) {
    addx: i16,
    noop: void,
};

var instructions : [10000]Instruction = undefined;

fn parse(filename : []const u8) anyerror![]Instruction {
    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [100]u8 = undefined;

    var i : u16 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var splits = std.mem.split(u8, line, " ");
        _ = splits.next().?;
        var inst : Instruction = undefined;
        if (splits.next()) |x| {
            var nr : i16 = undefined;
            if (x[0] == '-') {
                nr = try fmt.parseUnsigned(u8, x[1..x.len], 10);
                nr = nr * -1;
            } else {
                nr = try fmt.parseUnsigned(u8, x, 10);
            }

            inst = Instruction{ .addx = nr };
        } else {
            inst = Instruction.noop;
        }

        instructions[i] = inst;

        i += 1;
    }

    return instructions[0..i];
}

pub fn main() anyerror!void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var instructions2 = try parse("input.txt");

    var cycles : [1000]i16 = undefined;
    var cycle : u16 = 0;
    var x : i16 = 1;

    for (instructions2) |inst| {
        var nr_cycles : u8 = switch (inst) {
            Instruction.noop => 1,
            Instruction.addx => 2
        };

        while (nr_cycles > 0) {
            cycles[cycle] = x;
            nr_cycles -= 1;
            cycle += 1;
        }

        x = switch (inst) {
            Instruction.noop => x,
            Instruction.addx => |new_x| x + new_x
        };
    }

    cycle = 0;

    var row : u8 = 0;

    while (row < 6) {
        var p : u8 = 0;
        while (p < 40) {
            x = cycles[cycle];
            if (p == x-1 or p == x or p == x+1) {
                try stdout.print("#", .{});
            } else {
                try stdout.print(".", .{});
            }
            p += 1;
            cycle += 1;
        }
        try stdout.print("\n", .{});
        row += 1;
    }

    try bw.flush();
}