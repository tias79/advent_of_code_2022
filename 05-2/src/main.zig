const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;

// [T]     [Q]             [S]        
// [R]     [M]             [L] [V] [G]
// [D] [V] [V]             [Q] [N] [C]
// [H] [T] [S] [C]         [V] [D] [Z]
// [Q] [J] [D] [M]     [Z] [C] [M] [F]
// [N] [B] [H] [N] [B] [W] [N] [J] [M]
// [P] [G] [R] [Z] [Z] [C] [Z] [G] [P]
// [B] [W] [N] [P] [D] [V] [G] [L] [T]
//  1   2   3   4   5   6   7   8   9 

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var pile0 = std.ArrayList(u8).init(allocator);
    try pile0.appendSlice("BPNQHDRT");
    var pile1 = std.ArrayList(u8).init(allocator);
    try pile1.appendSlice("MGBJTV");
    var pile2 = std.ArrayList(u8).init(allocator);
    try pile2.appendSlice("NRHDSVMQ");
    var pile3 = std.ArrayList(u8).init(allocator);
    try pile3.appendSlice("PZNMC");
    var pile4 = std.ArrayList(u8).init(allocator);
    try pile4.appendSlice("DZB");
    var pile5 = std.ArrayList(u8).init(allocator);
    try pile5.appendSlice("VCWZ");
    var pile6 = std.ArrayList(u8).init(allocator);
    try pile6.appendSlice("GZNCVQLS");
    var pile7 = std.ArrayList(u8).init(allocator);
    try pile7.appendSlice("LGJMDNV");
    var pile8 = std.ArrayList(u8).init(allocator);
    try pile8.appendSlice("TPMFZCG");

    var piles : [9]std.ArrayList(u8) = undefined;
    piles[0] = pile0;
    piles[1] = pile1;
    piles[2] = pile2;
    piles[3] = pile3;
    piles[4] = pile4;
    piles[5] = pile5;
    piles[6] = pile6;
    piles[7] = pile7;
    piles[8] = pile8;

    const Instruction = struct {
        quantity: u8,
        from: u8,
        to: u8
    };

    var buf: [100]u8 = undefined;
    var tmp: [10000]Instruction = undefined;
    var i : u16 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len > 4 and mem.eql(u8, line[0..4], "move")) {
            const space_1 = mem.indexOfScalar(u8, line, ' ').?;
            const space_2 = mem.indexOfScalar(u8, line[space_1+1..line.len], ' ').? + space_1+1;
            const space_3 = mem.indexOfScalar(u8, line[space_2+1..line.len], ' ').? + space_2+1;
            const space_4 = mem.indexOfScalar(u8, line[space_3+1..line.len], ' ').? + space_3+1;
            const space_5 = mem.indexOfScalar(u8, line[space_4+1..line.len], ' ').? + space_4+1;

            const quantity = try fmt.parseUnsigned(u8, line[space_1+1..space_2], 10);
            const from = try fmt.parseUnsigned(u8, line[space_3+1..space_4], 10);
            const to = try fmt.parseUnsigned(u8, line[space_5+1..line.len], 10);

            const inst = Instruction {
                .quantity = quantity,
                .from = from-1,
                .to = to-1
            };

            tmp[i] = inst;
            i += 1;
        }
    }

    const instructions = tmp[0..i];

    for (instructions)|inst| {
        try stdout.print("MOVE {d} FROM {d} TO {d}\n", .{inst.quantity, inst.from, inst.to});
        try bw.flush();

        const items = piles[inst.from].items[piles[inst.from].items.len-inst.quantity..piles[inst.from].items.len];
        piles[inst.from].shrinkRetainingCapacity(piles[inst.from].items.len-inst.quantity);
        try piles[inst.to].appendSlice(items);
    }

    var result : [9]u8 = undefined;
    i = 0;
    while (i < piles.len) {
        result[i] = piles[i].pop();
        i += 1;
    }
    try stdout.print("Result: {s}\n", .{result});

    try bw.flush();
}

