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

    // part 2 of the solution

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

        var it = std.mem.tokenizeScalar(u8, line.items, ' ');
        var i: u32 = 0;
        while (it.next()) |int| {
            list1[line_no][i] = try std.fmt.parseInt(u32, int, 10);

            i += 1;
        }
        std.debug.print("ints parsed: ", .{});
        for (list1[line_no]) |int| {
            std.debug.print("{d} ", .{int});
        }
        std.debug.print("\n", .{});
        line_no += 1;
    } else |err| switch (err) {
        error.EndOfStream => { // end of file
            std.debug.print("{d} lines processed.\n", .{line_no});
        },
        else => return err, // Propagate error
    }

    return "nice";
}
