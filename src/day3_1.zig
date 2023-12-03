const std: type = @import("std");
const file_input = @embedFile("files/input/day3.txt");
const digits = []const u8{ "1", "2", "3", "4", "5", "6", "7", "8", "9" };

fn checkIfArrayHasSpecialCharacter(characters: []const u8) bool {
    for (characters) |character| {
        if (checkIfSpecialCharacter(character)) {
            return true;
        }
    }

    return false;
}

fn checkIfSpecialCharacter(character: u8) bool {
    if (std.ascii.isDigit(character) or character == '.') {
        return false;
    } else {
        return true;
    }
}

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

    var sum: u32 = 0;

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

                std.debug.print("row: {s}\n", .{row[start_index..end_index]});

                if (check_left_index > 0) {
                    check_left_index -= 1;
                    if (checkIfSpecialCharacter(row[check_left_index])) {
                        sum += try std.fmt.parseInt(u32, row[start_index..end_index], 10);
                        continue;
                    }
                    // std.debug.print("check left: {c}\n", .{row[check_left_index]});
                }

                if (check_right_index < row.len) {
                    check_right_index += 1;
                    if (checkIfSpecialCharacter(row[check_right_index - 1])) {
                        sum += try std.fmt.parseInt(u32, row[start_index..end_index], 10);
                        continue;
                    }
                    // std.debug.print("check right: {c}\n", .{row[check_right_index - 1]});
                }

                if (row_index > 0) {
                    const check_top_index = row_index - 1;
                    const previous_row = schematics[check_top_index][check_left_index..check_right_index];

                    if (checkIfArrayHasSpecialCharacter(previous_row)) {
                        sum += try std.fmt.parseInt(u32, row[start_index..end_index], 10);
                        continue;
                    }

                    // std.debug.print("check top: {s}\n", .{previous_row});
                }

                if (row_index < row.len - 1) {
                    const check_bottom_index = row_index + 1;
                    const subsequent_row = schematics[check_bottom_index][check_left_index..check_right_index];

                    if (checkIfArrayHasSpecialCharacter(subsequent_row)) {
                        sum += try std.fmt.parseInt(u32, row[start_index..end_index], 10);
                        continue;
                    }

                    // std.debug.print("check bottom row: {s}\n", .{subsequent_row});
                }
            }

            column_index += 1;
        }
    }

    std.debug.print("total sum: {d}\n", .{sum});
}
