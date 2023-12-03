const std: type = @import("std");
const ascii = @import("std").ascii;
const file_input = @embedFile("files/input/day1.txt");
const split = std.mem.split;

pub fn main() !void {
    var sum: i32 = 0;

    var map = std.StringHashMap(u8).init(std.heap.page_allocator);
    defer map.deinit();

    try map.put("one", '1');
    try map.put("two", '2');
    try map.put("three", '3');
    try map.put("four", '4');
    try map.put("five", '5');
    try map.put("six", '6');
    try map.put("seven", '7');
    try map.put("eight", '8');
    try map.put("nine", '9');

    var splits = split(u8, file_input, "\n");

    while (splits.next()) |line| {
        var first_digit: u8 = 0;
        var last_digit: u8 = 0;
        var current_position: u8 = 0;

        for (line) |char| {
            if (std.ascii.isDigit(char)) {
                if (first_digit == 0) {
                    first_digit = char;
                }

                last_digit = char;
            } else {
                if (current_position >= 4) {
                    const five_slide = line[current_position - 4 .. current_position + 1];
                    // std.debug.print("{s} five slide: \n", .{five_slide});
                    const five_slide_result = map.get(five_slide);
                    if (five_slide_result) |v| {
                        if (first_digit == 0) {
                            first_digit = v;
                        }
                        last_digit = v;
                    }
                }

                if (current_position >= 3) {
                    const four_slide = line[current_position - 3 .. current_position + 1];
                    const four_slide_result = map.get(four_slide);
                    if (four_slide_result) |v| {
                        if (first_digit == 0) {
                            first_digit = v;
                        }
                        last_digit = v;
                    }
                }

                if (current_position >= 2) {
                    const three_slide = line[current_position - 2 .. current_position + 1];
                    const three_slide_result = map.get(three_slide);
                    if (three_slide_result) |v| {
                        if (first_digit == 0) {
                            first_digit = v;
                        }
                        last_digit = v;
                    }
                }
            }

            current_position = current_position + 1;
        }

        const number = [_]u8{ first_digit, last_digit };

        const combined_number = std.fmt.parseInt(i8, &number, 10) catch |err| return err;

        sum += combined_number;

        std.debug.print("{s}\n", .{line});
        std.debug.print("{d}\n", .{combined_number});
    }

    std.debug.print("{d}\n", .{sum});
}

/// I spent an hour trying to read data with zigs and just decided to encode it :pepehands:
fn readLinesFromFile(filename: []const u8) !std.ArrayList([]const u8) {
    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();
    const reader = file.reader();
    _ = reader;

    var lines = std.ArrayList([]const u8).init(std.heap.page_allocator);
    defer lines.deinit();

    var buffer: [1024]u8 = undefined;
    const data = try file.readAll(&buffer);
    _ = data;

    var buffer_lines = std.mem.tokenize(u8, &buffer, "\n");
    while (buffer_lines.next()) |line| {
        try lines.append(line);
    }
}

// lul
test "day 1 test" {
    var list = std.ArrayList([]const u8).init(std.testing.allocator);
    defer list.deinit();

    std.debug.print("Start of test: \n", .{});

    for (list.items) |item| {
        std.debug.print("{s}\n", .{item});
    }
}
