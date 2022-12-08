const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;
const math = std.math;

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

    const matrix_w : u16 = 99;
    const matrix_h : u16 = 99;
    var matrix : [matrix_w*matrix_h]u8 = undefined;

    var visible_trees = std.AutoHashMap(u16, void).init(allocator);
    defer visible_trees.deinit();

    var i : u16 = 0;
    while (true) {
        const b = in_stream.readByte() catch |err| switch (err) {
            error.EndOfStream => break,
            else => |e| return e,
        };
        if (b >= '0' and b <= '9') {
            matrix[i] = b - '0';
            i += 1;
        }
    }

    var x : u16 = 0;
    while (x < matrix_w) {
        // Entire top row
        try visible_trees.put(x, {});
        // Entire bottom row
        try visible_trees.put((matrix_h-1)*matrix_w + x,  {});

        x += 1;
    }

    var y : u16 = 1;
    while (y < (matrix_h-1)) {
        // First on row
        try visible_trees.put(y*matrix_w, {});
        // Last on row
        try visible_trees.put(y*matrix_w+(matrix_w-1), {});

        var highest : u16 = undefined;
        
        // Left to right
        highest = matrix[y*matrix_w];
        x = 1;
        while (x < matrix_w-1) {
            var tree = matrix[y*matrix_w+x];
            if (tree > highest) {
                try visible_trees.put(y*matrix_w+x, {});
                highest = tree;
            }
            x +=1;
        }

        // Right to left
        highest = matrix[y*matrix_w+matrix_w-1];
        x = matrix_w-2;
        while (x > 0) {
            var tree = matrix[y*matrix_w+x];
            if (tree > highest) {
                try visible_trees.put(y*matrix_w+x, {});
                highest = tree;
            }
            x -=1;
        }

        y += 1;
    }

    x = 1;
    while (x < matrix_w-1) {
        var highest : u16 = undefined;

        // Top to bottom
        highest = matrix[x];
        y = 1;
        while (y < matrix_h-1) {
            var tree = matrix[y*matrix_w+x];
            if (tree > highest) {
                try visible_trees.put(y*matrix_w+x, {});
                highest = tree;
            }
            y +=1;
        }

        // Bottom to top
        highest = matrix[x+(matrix_h-1)*matrix_w];
        y = matrix_h-2;
        while (y > 0) {
            var tree = matrix[y*matrix_w+x];
            if (tree > highest) {
                try visible_trees.put(y*matrix_w+x, {});
                highest = tree;
            }
            y -=1;
        }
        x += 1;
    } 


    var result : u16 = 0;

    var it = visible_trees.keyIterator();
    while (it.next()) |_| {
        result += 1;
    }

    try stdout.print("Result: {d}\n", .{result});

    try bw.flush();
}