const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;
const math = std.math;

const FactorType = enum {
    old,
    value
};

const Factor = union(FactorType) {
    old: void,
    value: u8
};

const Operator = enum {
    mult,
    add
};

const Operation = struct {
    factor1: Factor,
    factor2: Factor,
    operator: Operator
};

const DivTest = struct {
    divide_by: u8,
    when_true: u8,
    when_false: u8
};

const Monkey = struct {
    const Self = @This();

    items: std.ArrayList(u64),
    div_test: DivTest,
    operation: Operation,

    pub fn with_items(self : *const Self, items: std.ArrayList(u16)) Monkey {
        return Monkey {
            .items = items,
            .operation = self.operation,
            .div_test = self.div_test
        };
    }
};

var monkies : [10]Monkey = undefined;

fn parse(filename : []const u8, allocator : mem.Allocator) anyerror![]Monkey {
    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [100]u8 = undefined;

    const MonkeyRow = enum {
        nr,
        items,
        operation,
        tst,
        tst_true,
        tst_false,
        empty
    };

    var i : u16 = 0;
    var row = MonkeyRow.nr;
    var items : std.ArrayListAligned(u64,null) = undefined;
    var divide_by : u8 = undefined;
    var when_true : u8 = undefined;
    var when_false : u8 = undefined;
    var operation : Operation = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        row = switch (row) {
            MonkeyRow.nr => nr: { break :nr MonkeyRow.items; },
            MonkeyRow.items => items: {
                items = std.ArrayList(u64).init(allocator);
                var splits = std.mem.split(u8, line[18..line.len], ",");
                while (splits.next()) |str| {
                    var item = try fmt.parseUnsigned(u8, mem.trim(u8, str, " "), 10);
                    try items.append(item);
                }
                break :items MonkeyRow.operation;
            },
            MonkeyRow.operation => operation: {
                var splits = std.mem.splitBackwards(u8, line[18..line.len], " ");
                var factor1 : Factor = undefined;
                var tmp = splits.next().?;
                if (mem.eql(u8, tmp, "old")) {
                    factor1 = Factor.old;
                } else {
                    var value = try fmt.parseUnsigned(u8, tmp, 10);
                    factor1 = Factor { .value = value };
                }
                var operator : Operator = undefined;
                tmp = splits.next().?;
                if (mem.eql(u8, tmp, "*")) {
                    operator = Operator.mult;
                } else {
                    operator = Operator.add;
                }
                var factor2 : Factor = undefined;
                tmp = splits.next().?;
                if (mem.eql(u8, tmp, "old")) {
                    factor2 = Factor.old;
                } else {
                    var value = try fmt.parseUnsigned(u8, tmp, 10);
                    factor2 = Factor { .value = value };
                }
                operation = Operation {
                    .factor1 = factor1,
                    .factor2 = factor2,
                    .operator = operator
                };
                break :operation MonkeyRow.tst;
            },
            MonkeyRow.tst => tst: {
                var splits = std.mem.splitBackwards(u8, line[18..line.len], " ");
                divide_by = try fmt.parseUnsigned(u8, splits.next().?, 10);
                break :tst MonkeyRow.tst_true;
            },
            MonkeyRow.tst_true => tst_true: {
                var splits = std.mem.splitBackwards(u8, line[18..line.len], " ");
                when_true = try fmt.parseUnsigned(u8, splits.next().?, 10);
                break :tst_true MonkeyRow.tst_false;
            },
            MonkeyRow.tst_false => tst_false: {
                var splits = std.mem.splitBackwards(u8, line[18..line.len], " ");
                when_false = try fmt.parseUnsigned(u8, splits.next().?, 10);

                monkies[i] = Monkey {
                    .items = items,
                    .div_test = DivTest {
                        .divide_by = divide_by,
                        .when_true = when_true,
                        .when_false = when_false
                    },
                    .operation = operation
                };
                i += 1;
                break :tst_false MonkeyRow.empty;
            },
            MonkeyRow.empty => empty: {
                break :empty MonkeyRow.nr;
            }
        };

    }

    return monkies[0..i];
}

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var monkies2 = try parse("input.txt", allocator);

    var inspections = std.AutoHashMap(u8, u16).init(allocator);

    var round : u8 = 0;
    while (round < 20) {
        var i : u8 = 0;
        while (i < monkies2.len) {
            var monkey = monkies2[i];

            if (inspections.get(i)) |v| {
                try inspections.put(i, v + @intCast(u16, monkey.items.items.len));
            } else {
                try inspections.put(i, @intCast(u16, monkey.items.items.len));
            }

            for (monkey.items.items) |item| {
                var factor1 = switch (monkey.operation.factor1) {
                    Factor.old => item,
                    Factor.value => |v| v
                };
                var factor2 = switch (monkey.operation.factor2) {
                    Factor.old => item,
                    Factor.value => |v| v
                };
                var result : u64 = switch (monkey.operation.operator) {
                    Operator.mult => factor1 * factor2,
                    Operator.add => factor1 + factor2
                };
                result = result / 3;

                var new_monkey : u8 = undefined;
                if (result % monkey.div_test.divide_by == 0) {
                    new_monkey = monkey.div_test.when_true;
                } else {
                    new_monkey = monkey.div_test.when_false;
                }
                try monkies2[new_monkey].items.append(result);
            }
            monkies2[i].items.clearRetainingCapacity();

            i += 1;
        }
        round += 1;
    }

    var i : u8 = 0;
    var tmp : [10]u64 = undefined;
    var it = inspections.iterator();
    while (it.next()) |e| {
        tmp[i] = e.value_ptr.*;
        i += 1;
    }

    var result = tmp[0..i];
    std.sort.sort(u64, result, {}, cmpByValue); 

    try stdout.print("Result: {d}\n", .{tmp[0]*tmp[1]});

    try bw.flush();
}

fn cmpByValue(context: void, a: u64, b: u64) bool {
    return std.sort.desc(u64)(context, a, b);
}
