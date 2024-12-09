const std = @import("std");

const input_file = "day03/day03.input";
var list: [1000][100]u8 = undefined;

pub fn main() !void {
    std.debug.print("Hello World!\n", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const data = try ingest(allocator, input_file);

    std.debug.print("{s}\n", .{data});
    // part 1 of the solution
    var total_mul: usize = 0;
    var valid_inputs: u32 = 0;
    var do = true;
    for (list) |string| {
        var int1: u32 = undefined;
        var int1_len: u8 = 3;
        int1 = std.fmt.parseInt(u32, string[0..3], 10) catch err1: {
            int1_len = 2;
            break :err1 std.fmt.parseInt(u32, string[0..2], 10) catch {
                int1_len = 1;
                break :err1 std.fmt.parseInt(u32, string[0..1], 10) catch {
                    break :err1 0; // no int found
                };
            };
        };
        if (string[int1_len] != ',') {
            int1 = 0; // bad format, add nothing
        }
        int1_len += 1;
        var int2: u32 = undefined;
        var int2_len: u8 = 3;
        int2 = std.fmt.parseInt(u32, string[int1_len .. int1_len + 3], 10) catch err1: {
            int2_len = 2;
            break :err1 std.fmt.parseInt(u32, string[int1_len .. int1_len + 2], 10) catch {
                int2_len = 1;
                break :err1 std.fmt.parseInt(u32, string[int1_len .. int1_len + 1], 10) catch {
                    break :err1 0; // no int found
                };
            };
        };
        if (string[int1_len + int2_len] != ')') {
            int2 = 0; //bad format, add nothing
        }
        if (do) {
            valid_inputs += 1;
            total_mul += int1 * int2;
            std.debug.print("found ints: {d} and {d}\n", .{ int1, int2 });
            const dont_pos = find_dont(string);
            if (dont_pos > 0) {
                do = false;
                if (find_do(string) > dont_pos) {
                    do = true;
                }
            }
        } else {
            const do_pos = find_do(string);
            if (do_pos > 0) {
                do = true;
                if (find_dont(string) > do_pos) {
                    do = false;
                }
            }
        }
    }

    std.debug.print("total multiplier: {d}\nvalid inputs: {d}\n", .{ total_mul, valid_inputs });
    // part 2 of the solution

}

fn find_do(string: [100]u8) usize {
    for (string, 0..) |char, i| {
        if (char == 'd') {
            if (string[i + 1] == 'o') {
                if (string[i + 2] == '(') {
                    if (string[i + 3] == ')') {
                        std.debug.print("{s}", .{string});
                        return i;
                    }
                }
            }
        }
    }
    return 0;
}

fn find_dont(string: [100]u8) usize {
    for (string, 0..) |char, i| {
        if (char == 'd') {
            if (string[i + 1] == 'o') {
                if (string[i + 2] == 'n') {
                    if (string[i + 3] == '\'') {
                        if (string[i + 4] == 't') {
                            if (string[i + 5] == '(') {
                                if (string[i + 6] == ')') {
                                    std.debug.print("{s}", .{string});
                                    return i;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return 0;
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
    var i: u32 = 0;
    while (reader.streamUntilDelimiter(writer, '\n', null)) {
        // Clear the line so we can reuse it.
        defer line.clearRetainingCapacity();

        // we gunna split on the mul( token so we can just run possible numbers
        var it = std.mem.tokenizeSequence(u8, line.items, "mul(");
        while (it.next()) |token| {
            for (token, 0..) |char, j| {
                list[i][j] = char;
            }
            std.debug.print("{s}\n", .{token});
            i += 1;
        }
        line_no += 1;
    } else |err| switch (err) {
        error.EndOfStream => { // end of file
            std.debug.print("{d} lines processed. {d} mul( tokens found.\n", .{ line_no, i });
        },
        else => return err, // Propagate error
    }

    return "nice";
}
