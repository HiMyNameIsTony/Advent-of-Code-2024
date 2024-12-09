const std = @import("std");

const input_file = "day02/day02.input";
var list1 = std.mem.zeroes([1000][9]u32);

pub fn main() !void {
    std.debug.print("Hello World!\n", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const data = try ingest(allocator, input_file);

    std.debug.print("{s}\n", .{data});
    // part 1 of the solution
    var safe_cnt: u32 = 0;
    var safe_cnt_p2: u32 = 0;
    for (list1) |line| {
        if (safe_check(&line)) {
            safe_cnt += 1;
        } else if (part2(line)) {
            safe_cnt_p2 += 1;
        }
    }
    std.debug.print("safe reports: {}\n", .{safe_cnt});
    // part 2 of the solution is handled in the below function, only if a line is de
    std.debug.print("safe reports with problem dampener: {}\n", .{safe_cnt + safe_cnt_p2});
}

// given an unsafe line, attempt to remove elements from it to see if that would make it safe
fn part2(line: [9]u32) bool {
    //remove elements one at a time to see if it works. brute force it, baby!
    std.debug.print("unsafe line: {any}\n", .{line});
    for (0..8) |i| {
        var new_line = std.mem.zeroes([8]u32);
        for (new_line, 0..) |_, j| {
            if (j < i) {
                new_line[j] = line[j];
            } else {
                new_line[j] = line[j + 1];
            }
        }
        std.debug.print("new line: {any}\n", .{new_line});
        if (safe_check(&new_line)) {
            return true;
        }
    }
    return false; // if we get through the whole for loop, there's so safe removal
}

// given an array of ints, determine if the line is safe or not
fn safe_check(line: []const u32) bool {
    var up: bool = undefined;
    var safe: bool = true;
    var last_bool: u32 = 0;
    for (line, 0..) |int, i| {
        if (!safe or (int == 0)) { // out of data
            return safe;
        }

        const diff: i33 = @as(i33, int) - @as(i33, last_bool);
        if (i == 1) {
            if ((diff >= 1) and (diff <= 3)) { // safe increasing sequence
                up = true;
            } else if ((diff <= -1) and (diff >= -3)) { // safe decreasing sequence
                up = false;
            } else {
                safe = false; // unsafe sequence
            }
        } else if (i > 1) {
            if (up and (diff >= 1) and (diff <= 3)) {
                // still safe
            } else if (!up and (diff <= -1) and (diff >= -3)) {
                // still safe
            } else {
                safe = false;
            }
        }
        last_bool = int;
    }
    return false; // should never get here, as every line ends with a zero'd int
}

// bring in the data from the text file provided and place it in the appropriate global variable(s)
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

        var it = std.mem.tokenizeScalar(u8, line.items, ' ');
        var i: u32 = 0;
        while (it.next()) |int| {
            list1[line_no][i] = try std.fmt.parseInt(u32, int, 10);

            i += 1;
        }
        // std.debug.print("ints parsed: ", .{});
        // for (list1[line_no]) |int| {
        //     std.debug.print("{d} ", .{int});
        // }
        // std.debug.print("\n", .{});
        line_no += 1;
    } else |err| switch (err) {
        error.EndOfStream => { // end of file
            std.debug.print("{d} lines processed.\n", .{line_no});
        },
        else => return err, // Propagate error
    }

    return "nice";
}
