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

    const Shape = enum {
        Rock,
        Paper,
        Scissors
    };

    const Round = struct {
        elf: Shape,
        mine: Shape
    };

    var buf: [4]u8 = undefined;
    var rounds: [10000]Round = undefined;
    var i : u16 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var elf : u8 = line[0] - 'A';
        var elf_shape : Shape = Shape.Rock;
        if (elf == 0) {
            elf_shape = Shape.Rock;
        }
        if (elf == 1) {
            elf_shape = Shape.Paper;
        }
        if (elf == 2) {
            elf_shape = Shape.Scissors;
        }

        var me : u8 = line[2] - 'X';
        var my_shape : Shape = Shape.Rock;
        if (me == 0) {
            my_shape = Shape.Rock;
        }
        if (me == 1) {
            my_shape = Shape.Paper;
        }
        if (me == 2) {
            my_shape = Shape.Scissors;
        }

        const r = Round {
            .elf = elf_shape,
            .mine = my_shape,
        };

        rounds[i] = r;
        i += 1;
    }

    var result : u32 = 0;
    for (rounds[0..i]) |round| {
        var shape_score : u8 = @enumToInt(round.mine) + 1; 
        var outcome_score : u32 = 0;

        if (@enumToInt(round.mine) ==  @enumToInt(round.elf)) {
            outcome_score = 3;
        } else {
            if (round.mine == Shape.Rock and round.elf == Shape.Paper) {
                outcome_score = 0;
            } else if (round.mine == Shape.Rock and round.elf == Shape.Scissors) {
                outcome_score = 6;
            } else if (round.mine == Shape.Paper and round.elf == Shape.Rock) {
                outcome_score = 6;
            } else if (round.mine == Shape.Paper and round.elf == Shape.Scissors) {
                outcome_score = 0;
            } else if (round.mine == Shape.Scissors and round.elf == Shape.Rock) {
                outcome_score = 0;
            } else if (round.mine == Shape.Scissors and round.elf == Shape.Paper) {
                outcome_score = 6;
            }
        }

        var round_result = shape_score + outcome_score;
        result += round_result;

        try stdout.print("Round: {d} {d} = {d}\n", .{@enumToInt(round.elf), @enumToInt(round.mine), round_result});
    }


    try stdout.print("Result: {d}\n", .{result});

    try bw.flush();
}