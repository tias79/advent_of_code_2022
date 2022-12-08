const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;
const math = std.math;

const Tree = struct {
    height : u8,
    up : u8,
    down : u8,
    left : u8,
    right : u8
};

const Matrix = struct {
    const Self = @This();

    const width : u16 = 99;
    const height : u16 = 99;

    buf : [width*height]Tree = undefined,

    pub fn get(self: Matrix, x : i16, y : i16) Tree {
        return self.buf[@intCast(u8, x) + @intCast(u8, y) * width];
    }

    pub fn put(self: *Self, x : i16, y : i16, tree : Tree) void {
        self.buf[@intCast(usize, x + y * width)] = tree;
    }

    fn init(filename : []const u8) anyerror!Matrix {
        var file = try std.fs.cwd().openFile(filename, .{});
        defer file.close();

        var buf_reader = std.io.bufferedReader(file.reader());
        var in_stream = buf_reader.reader();

        var matrix = Matrix {
            .buf = undefined
        };

        var i : u16 = 0;
        while (true) {
            const b = in_stream.readByte() catch |err| switch (err) {
                error.EndOfStream => break,
                else => |e| return e,
            };
            if (b >= '0' and b <= '9') {
                matrix.buf[i] = Tree {
                    .height = b - '0',
                    .up = 0,
                    .down = 0,
                    .left = 0,
                    .right = 0
                };
                i += 1;
            }
        }

        return matrix;
    }
};

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var matrix = try Matrix.init("input.txt");

    var visible_trees = std.AutoHashMap(u16, void).init(allocator);
    defer visible_trees.deinit();

    var x : i16 = undefined;
    var y : i16 = undefined;

    // Top to bottom
    x = 0;
    while (x < Matrix.width) {
        y = 0;
        var tmp = std.mem.zeroes([10]u8);
        while (y < Matrix.height) {
            var tree = matrix.get(x, y);
            tree.up = @intCast(u8, y) - biggest(tmp[tree.height..10]);
            matrix.put(x, y, tree);
            tmp[tree.height] = @intCast(u8, y);
            y += 1;
        }
        x += 1;
    }

    // Bottom to top
    x = 0;
    while (x < Matrix.width) {
        y = Matrix.height-1;
        var tmp = [_]u8{ Matrix.width-1, Matrix.width-1, Matrix.width-1, Matrix.width-1, Matrix.width-1, Matrix.width-1, Matrix.width-1, Matrix.width-1, Matrix.width-1, Matrix.width-1 };
        while (y >= 0) {
            var tree = matrix.get(x, y);
            tree.down = smallest(tmp[tree.height..10]) - @intCast(u8, y);
            matrix.put(x, y, tree);
            tmp[tree.height] = @intCast(u8, y);
            y -= 1;
        }

        x += 1;
    }

    // Left to right
    y = 0;
    while (y < Matrix.height) {
        x = 0;
        var tmp = std.mem.zeroes([10]u8);
        while (x < Matrix.width) {
            var tree = matrix.get(x, y);
            tree.left = @intCast(u8, x) - biggest(tmp[tree.height..10]);
            matrix.put(x, y, tree);
            tmp[tree.height] = @intCast(u8, x);
            x += 1;
        }

        y += 1;
    }

    // Right to left
    y = 0;
    while (y < Matrix.height) {
        x = Matrix.width-1;
        var tmp = [_]u8{ Matrix.width-1, Matrix.width-1, Matrix.width-1, Matrix.width-1, Matrix.width-1, Matrix.width-1, Matrix.width-1, Matrix.width-1, Matrix.width-1, Matrix.width-1 };
        while (x >= 0) {
            var tree = matrix.get(x, y);
            tree.right = smallest(tmp[tree.height..10]) - @intCast(u8, x);
            matrix.put(x, y, tree);
            tmp[tree.height] = @intCast(u8, x);
            x += -1;
        }
        y += 1;
    }

    var result : u32 = 0;

    for (matrix.buf) |tree| {
        var tmp : u32 = @intCast(u32, tree.up) * @intCast(u32, tree.down) * @intCast(u32, tree.left) * @intCast(u32, tree.right);
        if (tmp > result) {
            result = tmp;
        }
    }

    try stdout.print("Result: {d}\n", .{result});

    try bw.flush();
}

fn smallest(slice : []u8) u8 {
    var tmp : u8 = 100;
    for (slice) |c| {
        if (c < tmp) {
            tmp = c;
        }
    }

    return tmp;
}

fn biggest(slice : []u8) u8 {
    var tmp : u8 = 0;
    for (slice) |c| {
        if (c > tmp) {
            tmp = c;
        }
    }

    return tmp;
}
