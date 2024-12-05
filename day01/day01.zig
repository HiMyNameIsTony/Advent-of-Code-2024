const std = @import("std");

const input_file = "day01/day01.input";
var list1 = std.mem.zeroes([1000]u32);
var list2 = std.mem.zeroes([1000]u32);

pub fn main() !void {
    std.debug.print("Hello World!\n", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const data = try ingest(allocator, input_file);

    std.debug.print("{s}\n", .{data});
    std.mem.sort(u32, &list1, {}, comptime std.sort.asc(u32));
    std.mem.sort(u32, &list2, {}, comptime std.sort.asc(u32));

    var total_distance: usize = 0;
    for (list1, list2) |int1, int2| {
        std.debug.print("{d}\n", .{@as(isize, int1) - @as(isize, int2)});
        total_distance += @as(usize, @abs(@as(isize, int1) - @as(isize, int2)));
    }

    std.debug.print("total diff: {d}\n", .{total_distance});
}

fn ingest(allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    var input_missing = false;
    var file: std.fs.File = undefined;

    if (std.fs.cwd().openFile(input, .{})) |_| {
        //success!
        file = std.fs.cwd().openFile(input, .{}) catch unreachable;
    } else |err| switch (err) {
        error.FileNotFound => {
            input_missing = true;
        },
        else => return err,
    }

    if (input_missing) {
        // this will be an HTTP GET request eventually where we create the file
        return "Missing file input.";
    }
    defer file.close();

    // Wrap the file reader in a buffered reader.
    // Since it's usually faster to read a bunch of bytes at once.
    var buf_reader = std.io.bufferedReader(file.reader());
    const reader = buf_reader.reader();

    var line = std.ArrayList(u8).init(allocator);
    defer line.deinit();

    const writer = line.writer();
    var line_no: u32 = 0;
    while (reader.streamUntilDelimiter(writer, '\n', null)) {
        // Clear the line so we can reuse it.
        defer line.clearRetainingCapacity();

        const ints = try stringToInts(line);
        std.debug.print("line {d} -- {d}, {d}\n", .{ line_no, ints[0], ints[1] });

        list1[line_no] = ints[0];
        list2[line_no] = ints[1];
        line_no += 1;
    } else |err| switch (err) {
        error.EndOfStream => { // end of file
            std.debug.print("{d} lines processed.\n", .{line_no});
        },
        else => return err, // Propagate error
    }

    return "nice";
}

fn stringToInts(line: anytype) ![]u32 {
    var ints = [2]u32{ 0, 0 };
    ints[0] = try std.fmt.parseInt(u32, line.items[0..5], 10);
    ints[1] = try std.fmt.parseInt(u32, line.items[8..13], 10);
    return &ints;
}
