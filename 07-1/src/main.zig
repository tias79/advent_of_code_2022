const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;

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

    var buf: [100]u8 = undefined;
    var current_dir = std.ArrayList([]u8).init(allocator);

    var dirs = std.StringHashMap(u32).init(allocator);

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var splits = std.mem.split(u8, line, " ");
        var tmp = splits.next().?;
        if (mem.eql(u8, tmp, "$")) {
            if (mem.eql(u8, splits.next().?, "cd")) {
                var path = splits.next().?;
                if (mem.eql(u8, path, "/")) {
                    current_dir.clearRetainingCapacity();
                } else if (mem.eql(u8, path, "..")) {
                    _ = current_dir.pop();
                } else if (mem.eql(u8, path, ".")) {
                    continue;
                } else  {
                    try current_dir.append(try allocator.dupe(u8, path));
                }
            }
        } else if (mem.eql(u8, tmp, "dir")) {
            continue;
        } else {
            const nrBytes = try fmt.parseUnsigned(u32, tmp, 10);

            var dir_copy = try current_dir.clone();
            while (true) {
                var path = to_string(dir_copy, allocator);
                var value = dirs.get(path);
                if (value) |existingNrBytes| {
                    try dirs.put(path, existingNrBytes + nrBytes);
                } else {
                    try dirs.put(path, nrBytes);
                }

                if (dir_copy.popOrNull()) |_|{
                    continue;
                } else {
                    break;
                }
            }
            dir_copy.deinit();
        }
    }

    var result : u32 = 0;
    var it = dirs.iterator();
    while (it.next()) |entry| {
        if (entry.value_ptr.* <= 100000) {
            try stdout.print("{s} - {d}\n", .{entry.key_ptr.*, entry.value_ptr.*});
            result += entry.value_ptr.*;
        }
    }
    try stdout.print("Result: {d}\n", .{result});

    try bw.flush();
}

fn to_string(dir : std.ArrayList([]u8), allocator : mem.Allocator) []const u8 {
    var result : []const u8 = "";

    for (dir.items) |str| {
        var tmp : []const u8 = undefined;
        if (result.len == 0) {
            tmp = std.fmt.allocPrint(allocator, "{s}", .{str}) catch "error";
        } else {
            tmp = std.fmt.allocPrint(allocator, "{s}/{s}", .{result, str}) catch "error";
        }
        result = tmp;
    }

    return result;
}
