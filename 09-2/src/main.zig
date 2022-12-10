const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;
const math = std.math;

var moves : [10000]Move = undefined;

const Direction = enum {
    UP,
    DOWN,
    LEFT,
    RIGHT
};

const Move = struct {
    steps : u16,
    dir : Direction
};

const Pos = struct {
    x : i16,
    y : i16,

    pub fn init() Pos {
        return Pos {
            .x = 0,
            .y = 0
        };
    }

    pub fn moveLeft(self : Pos) Pos {
        return Pos {
            .x = self.x-1,
            .y = self.y
        };
    }

    pub fn moveRight(self : Pos) Pos {
        return Pos {
            .x = self.x+1,
            .y = self.y
        };
    }

    pub fn moveUp(self : Pos) Pos {
        return Pos {
            .x = self.x,
            .y = self.y+1
        };
    }

    pub fn moveDown(self : Pos) Pos {
        return Pos {
            .x = self.x,
            .y = self.y-1
        };
    }

};

fn parse(filename : []const u8) anyerror![]Move {
    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [100]u8 = undefined;

    var i : u16 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var splits = std.mem.split(u8, line, " ");
        var dir : Direction = Direction.UP;
        var dir_buf = splits.next().?;
        if (mem.eql(u8, dir_buf, "D")) {
            dir = Direction.DOWN;
        }
        if (mem.eql(u8, dir_buf, "L")) {
            dir = Direction.LEFT;
        }
        if (mem.eql(u8, dir_buf, "R")) {
            dir = Direction.RIGHT;
        }

        var steps_buf = splits.next().?;
        var steps = try fmt.parseUnsigned(u16, steps_buf, 10);

        var move = Move {
            .steps = steps,
            .dir = dir
        };
        moves[i] = move;

        i += 1;
    }

    return moves[0..i];
}

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var knots : [10]Pos = undefined;
    knots[0] = Pos.init();
    knots[1] = Pos.init();
    knots[2] = Pos.init();
    knots[3] = Pos.init();
    knots[4] = Pos.init();
    knots[5] = Pos.init();
    knots[6] = Pos.init();
    knots[7] = Pos.init();
    knots[8] = Pos.init();
    knots[9] = Pos.init();

    var visited = std.AutoHashMap(Pos, void).init(allocator);
    defer visited.deinit();
    try visited.put(knots[9], {});

    var moves2 = try parse("input.txt");
    for (moves2) |move| {
        var i : u16 = 0;
        while (i < move.steps) {
            knots[0] = switch (move.dir) {
                Direction.LEFT => knots[0].moveLeft(),
                Direction.RIGHT => knots[0].moveRight(),
                Direction.UP => knots[0].moveUp(),
                Direction.DOWN => knots[0].moveDown()
            };

            knots[1] = calcMove(knots[0], knots[1]);
            knots[2] = calcMove(knots[1], knots[2]);
            knots[3] = calcMove(knots[2], knots[3]);
            knots[4] = calcMove(knots[3], knots[4]);
            knots[5] = calcMove(knots[4], knots[5]);
            knots[6] = calcMove(knots[5], knots[6]);
            knots[7] = calcMove(knots[6], knots[7]);
            knots[8] = calcMove(knots[7], knots[8]);
            knots[9] = calcMove(knots[8], knots[9]);

            try visited.put(knots[9], {});
            i += 1;
        }
    }

    try stdout.print("Result: {d}\n", .{visited.count()});

    try bw.flush();
}

pub fn abs(val : i16) i16 {
    if (val < 0) {
        return val * -1;
    }
    return val;
}

pub fn calcMove(head : Pos, tail : Pos) Pos {
    var newPos = Pos {
        .x = tail.x,
        .y = tail.y
    };
    if (head.x != tail.x or head.y != tail.y) {
        if (abs(head.y - tail.y) > 1 and head.x == tail.x) {
            if (head.y > tail.y) {
                newPos = newPos.moveUp();
            } else {
                newPos = newPos.moveDown();
            }
        } else if (abs(head.x - tail.x) > 1 and head.y == tail.y) {
            if (head.x > tail.x) {
                newPos = newPos.moveRight();
            } else {
                newPos = newPos.moveLeft();
            }
        } else if (abs(head.y - tail.y) > 1 or abs(head.x - tail.x) > 1) {
            if (head.y > tail.y) {
                newPos = newPos.moveUp();
            } else {
                newPos = newPos.moveDown();
            }
            if (head.x > tail.x) {
                newPos = newPos.moveRight();
            } else {
                newPos = newPos.moveLeft();
            }
        }
    }

    return newPos;
}