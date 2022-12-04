const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;

const Range = struct {
    from:  u8,
    to: u8
};

const Pair = struct {
    first:  Range,
    second: Range
};

pub fn main() anyerror!void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [100]u8 = undefined;
    var tmp: [10000]Pair = undefined;
    var i : u16 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const comma_location = mem.indexOfScalar(u8, line, ',').?;
        const first = try parse_range(line[0..comma_location]);
        const second = try parse_range(line[comma_location+1..line.len]);

        const p = Pair {
            .first = first,
            .second = second
        };

        tmp[i] = p;
        i += 1;
    }

    const pairs = tmp[0..i];
    var result : u32 = 0;

    for (pairs)|p| {
        if (any_overlap(p.first, p.second)) {
            result += 1;
        }
    }

    try stdout.print("Result: {d}\n", .{result});

    try bw.flush();
}

fn parse_range(str: []const u8) anyerror!Range {
    const dash_location = mem.indexOfScalar(u8, str, '-').?;
    const from = try fmt.parseUnsigned(u8, str[0..dash_location], 10);
    const to = try fmt.parseUnsigned(u8, str[dash_location+1..str.len], 10);

    const r = Range {
        .from = from,
        .to = to
    };

    return r;
}

fn any_overlap(r1: Range, r2: Range) bool {
    if (in_range(r1.from, r2) or in_range(r1.to, r2)) {
        return true;
    }
    if (in_range(r2.from, r1) or in_range(r2.to, r1)) {
        return true;
    }
    return false;
}

fn in_range(nr: u8, range: Range) bool {
    return nr >= range.from and nr <= range.to;
}