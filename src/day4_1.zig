const std = @import("std");
const file_input = @embedFile("files/input/day4.txt");
const split = std.mem.split;

pub fn getScratchCardsScore() !u16 {
    var sum: u16 = 0;

    var splits = split(u8, file_input, "\n");

    while (splits.next()) |line| {
        const fluff = std.mem.indexOf(u8, line, ":").? + 1;

        var cards = line[fluff..];
        cards = std.mem.trim(u8, cards, " ");

        var set = split(u8, cards, "|");

        var winner_map = std.StringHashMap(u8).init(std.heap.page_allocator);
        defer winner_map.deinit();

        const winning_set = set.first();
        var winners = std.mem.tokenize(u8, winning_set, " ");

        while (winners.next()) |winner| {
            try winner_map.put(winner, 0);
        }

        const check_set = set.next().?;
        var checks = std.mem.tokenize(u8, check_set, " ");

        var score: u16 = 0;

        while (checks.next()) |check| {
            std.debug.print("check: {s}\n", .{check});

            const winner = winner_map.get(check);

            if (winner) |v| {
                _ = v;

                if (score == 0) {
                    score = 1;
                } else {
                    score *= 2;
                }
            }
        }

        sum += score;

        std.debug.print("{d}\n", .{sum});
    }

    return sum;
}

test "day 4 test" {
    const sum = try getScratchCardsScore();

    std.debug.print("sum: {d}\n", .{sum});
}
