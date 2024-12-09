const std = @import("std");

const input_file = "day04/day04.input";
var list: [140][140]u8 = undefined;

pub fn main() !void {
    std.debug.print("Hello World!\n", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const data = try ingest(allocator, input_file);

    std.debug.print("{s}\n", .{data});
    // part 1 of the solution

    //std.debug.print("total multiplier: {d}\nvalid inputs: {d}\n", .{valid_inputs});
    // part 2 of the solution involves using the below functions to approve the do/dont calls.

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
        var it = std.mem.tokenizeScalar(u8, line.items, '\n');
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
            std.debug.print("{d} lines processed.\n", .{line_no});
        },
        else => return err, // Propagate error
    }

    return "nice";
}
