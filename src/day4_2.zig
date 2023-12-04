const std = @import("std");
const file_input = @embedFile("files/input/day4.txt");
// const file_input = @embedFile("files/input/day4.txt");
const split = std.mem.split;

pub fn getScratchCardsScore() !u64 {
    var sum: u64 = 0;

    var splits = std.mem.tokenize(u8, file_input, "\n");

    var score_map = std.AutoHashMap(u64, u64).init(std.heap.page_allocator);
    defer score_map.deinit();

    // disgusting
    var index_count: u16 = 0;

    while (splits.next()) |_| {
        try score_map.put(index_count, 1);
        index_count += 1;
    }

    splits.reset();

    index_count = 0;

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

        var score: u64 = 0;

        while (checks.next()) |check| {
            // std.debug.print("check: {s}\n", .{check});

            const winner = winner_map.get(check);

            if (winner) |_| {
                score += 1;
            }
        }

        const current_scratch_score = score_map.get(index_count).?;

        while (score > 0) {
            const scratch_count = score_map.get(index_count + score).? + current_scratch_score;

            // std.debug.print("{d}\n", .{scratch_count});

            try score_map.put(index_count + score, scratch_count);

            score -= 1;
        }

        sum += current_scratch_score;

        index_count += 1;
        std.debug.print("{d}\n", .{sum});
    }

    return sum;
}

test "day 4 test" {
    const sum = try getScratchCardsScore();

    std.debug.print("sum: {d}\n", .{sum});
}
