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

    var head = Pos.init();
    var tail = Pos.init();

    var visited = std.AutoHashMap(Pos, void).init(allocator);
    try visited.put(tail, {});

    var moves2 = try parse("input.txt");
    for (moves2) |move| {
        var i : u16 = 0;
        while (i < move.steps) {
            head = switch (move.dir) {
                Direction.LEFT => head.moveLeft(),
                Direction.RIGHT => head.moveRight(),
                Direction.UP => head.moveUp(),
                Direction.DOWN => head.moveDown()
            };

            if (head.x != tail.x or head.y != tail.y) {
                if (abs(head.y - tail.y) > 1 and head.x == tail.x) {
                    if (head.y > tail.y) {
                        tail = tail.moveUp();
                    } else {
                        tail = tail.moveDown();
                    }
                } else if (abs(head.x - tail.x) > 1 and head.y == tail.y) {
                    if (head.x > tail.x) {
                        tail = tail.moveRight();
                    } else {
                        tail = tail.moveLeft();
                    }
                } else if (abs(head.y - tail.y) > 1 or abs(head.x - tail.x) > 1) {
                    if (head.y > tail.y) {
                        tail = tail.moveUp();
                    } else {
                        tail = tail.moveDown();
                    }
                    if (head.x > tail.x) {
                        tail = tail.moveRight();
                    } else {
                        tail = tail.moveLeft();
                    }
                }
            }
            try visited.put(tail, {});
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