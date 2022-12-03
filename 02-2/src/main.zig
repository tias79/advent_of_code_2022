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

    const Needed = enum {
        Lose,
        Draw,
        Win
    };

    const Round = struct {
        elf: Shape,
        needed: Needed
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

        var tmp : u8 = line[2] - 'X';
        var needed : Needed = Needed.Lose;
        if (tmp == 0) {
            needed = Needed.Lose;
        }
        if (tmp == 1) {
            needed = Needed.Draw;
        }
        if (tmp == 2) {
            needed = Needed.Win;
        }

        const r = Round {
            .elf = elf_shape,
            .needed = needed,
        };

        rounds[i] = r;
        i += 1;
    }

    var result : u32 = 0;
    for (rounds[0..i]) |round| {
        var mine : Shape = round.elf;
        var elf : Shape = round.elf;

        if (round.needed != Needed.Draw) {
            if (round.needed == Needed.Win) {
                mine = switch (round.elf) {
                    .Rock => Shape.Paper,
                    .Paper => Shape.Scissors,
                    else => Shape.Rock
                };
            }
            if (round.needed == Needed.Lose) {
                mine = switch (round.elf) {
                    .Rock => Shape.Scissors,
                    .Paper => Shape.Rock,
                    else => Shape.Paper
                };
            }
        }

        var shape_score : u8 = @enumToInt(mine) + 1; 
        var outcome_score : u32 = 0;

        if (@enumToInt(mine) == @enumToInt(elf)) {
            outcome_score = 3;
        } else {
            if (mine == Shape.Rock and elf == Shape.Paper) {
                outcome_score = 0;
            } else if (mine == Shape.Rock and elf == Shape.Scissors) {
                outcome_score = 6;
            } else if (mine == Shape.Paper and elf == Shape.Rock) {
                outcome_score = 6;
            } else if (mine == Shape.Paper and elf == Shape.Scissors) {
                outcome_score = 0;
            } else if (mine == Shape.Scissors and elf == Shape.Rock) {
                outcome_score = 0;
            } else if (mine == Shape.Scissors and elf == Shape.Paper) {
                outcome_score = 6;
            }
        }

        var round_result = shape_score + outcome_score;
        result += round_result;

        try stdout.print("Round: {d} {d} = {d}\n", .{@enumToInt(elf), @enumToInt(mine), round_result});
    }


    try stdout.print("Result: {d}\n", .{result});

    try bw.flush();
}