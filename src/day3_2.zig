const std: type = @import("std");
const file_input = @embedFile("files/input/day3.txt");
// const file_input = @embedFile("files/input/day3_test.txt");
const digits = []const u8{ "1", "2", "3", "4", "5", "6", "7", "8", "9" };

const Position = struct { row: usize, column: usize };
const GearTotal = struct { count: u8, total: u64 };

pub fn main() !void {
    var lines = std.mem.split(u8, file_input, "\n");

    var schematics: [140][140]u8 = undefined;

    var position: u8 = 0;

    while (lines.next()) |line| {
        std.debug.print("{any}\n", .{line});

        for (line, 0..) |character, index| {
            schematics[position][index] = character;
        }

        position += 1;
    }

    var sum: u64 = 0;

    var gear_position_map = std.AutoHashMap(Position, GearTotal).init(std.heap.page_allocator);
    // defer gear_position_map.deinit();

    for (schematics, 0..) |row, row_index| {
        var column_index: u8 = 0;

        while (column_index < row.len) {
            if (std.ascii.isDigit(row[column_index])) {
                const start_index = column_index;

                while (std.ascii.isDigit(row[column_index])) {
                    if (column_index == row.len - 1) {
                        column_index += 1;
                        break;
                    }
                    column_index += 1;
                }

                const end_index = column_index;

                var check_left_index: u8 = start_index;
                var check_right_index: u8 = end_index;

                const number = try std.fmt.parseInt(u32, row[start_index..end_index], 10);

                if (check_left_index > 0) {
                    check_left_index -= 1;
                    if (row[check_left_index] == '*') {
                        std.debug.print("gear found position: {d} {d}\n", .{ row_index, check_left_index });
                        const gear_position = Position{ .row = row_index, .column = check_left_index };

                        const position_list = gear_position_map.get(gear_position);

                        if (position_list) |v| {
                            const new_gear = GearTotal{ .count = v.count + 1, .total = v.total * number };

                            try gear_position_map.put(gear_position, new_gear);
                        } else {
                            const near_gear = GearTotal{ .count = 1, .total = number };

                            try gear_position_map.put(gear_position, near_gear);
                        }
                    }
                }

                if (check_right_index < row.len) {
                    check_right_index += 1;
                    if (row[check_right_index - 1] == '*') {
                        std.debug.print("gear found position: {d} {d}\n", .{ row_index, check_right_index - 1 });
                        const gear_position = Position{ .row = row_index, .column = check_right_index - 1 };

                        const position_list = gear_position_map.get(gear_position);

                        if (position_list) |v| {
                            const new_gear = GearTotal{ .count = v.count + 1, .total = v.total * number };

                            try gear_position_map.put(gear_position, new_gear);
                        } else {
                            const near_gear = GearTotal{ .count = 1, .total = number };

                            try gear_position_map.put(gear_position, near_gear);
                        }
                    }
                }

                if (row_index > 0) {
                    const check_top_index = row_index - 1;
                    const previous_row = schematics[check_top_index][check_left_index..check_right_index];

                    for (previous_row, 0..) |item, count| {
                        if (item == '*') {
                            std.debug.print("gear found position: {d} {d}\n", .{ check_top_index, check_left_index + count });

                            const gear_position = Position{ .row = check_top_index, .column = check_left_index + count };

                            const position_list = gear_position_map.get(gear_position);

                            if (position_list) |v| {
                                const new_gear = GearTotal{ .count = v.count + 1, .total = v.total * number };

                                try gear_position_map.put(gear_position, new_gear);
                            } else {
                                const near_gear = GearTotal{ .count = 1, .total = number };

                                try gear_position_map.put(gear_position, near_gear);
                            }
                        }
                    }
                }

                if (row_index < row.len - 1) {
                    const check_bottom_index = row_index + 1;
                    const subsequent_row = schematics[check_bottom_index][check_left_index..check_right_index];

                    for (subsequent_row, 0..) |item, count| {
                        if (item == '*') {
                            // std.debug.print("gear found position: {d} {d}\n", .{ check_bottom_index, check_left_index + count });

                            const gear_position = Position{ .row = check_bottom_index, .column = check_left_index + count };

                            const position_list = gear_position_map.get(gear_position);

                            if (position_list) |v| {
                                const new_gear = GearTotal{ .count = v.count + 1, .total = v.total * number };

                                try gear_position_map.put(gear_position, new_gear);
                            } else {
                                const near_gear = GearTotal{ .count = 1, .total = number };

                                try gear_position_map.put(gear_position, near_gear);
                            }
                        }
                    }
                }
            }

            column_index += 1;
        }
    }

    var map_values = gear_position_map.valueIterator();

    while (map_values.next()) |value| {
        if (value.count == 2) {
            sum += value.total;
        }
    }

    std.debug.print("total sum: {d}\n", .{sum});
}
