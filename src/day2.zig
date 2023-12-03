const std: type = @import("std");
const file_input = @embedFile("files/input/day2.txt");
const split = std.mem.split;

const Pull = struct { count: u8, color: []const u8 };

const Game = struct { pulls: []Pull };

const GameSet = struct { game_index: u16, valid: bool, games: []Game };

const total_marble_map = std.ComptimeStringMap(u8, .{ .{ "red", 12 }, .{ "green", 13 }, .{ "blue", 14 } });

pub fn main() !void {
    var lines = std.mem.tokenize(u8, file_input, "\n");

    var games = std.ArrayList(GameSet).init(std.heap.page_allocator);
    defer games.deinit();

    while (lines.next()) |line| {
        const game = try convertLineToGame(line);
        try games.append(game);
    }

    // calculate total
    var valid_sets = std.ArrayList(GameSet).init(std.heap.page_allocator);
    defer valid_sets.deinit();

    var sum: u16 = 0;

    for (games.items) |parsed_games| {
        if (try checkIfValidGameSet(parsed_games)) {
            sum += parsed_games.game_index;

            // std.debug.print("{d}\n", .{parsed_games.game_index});
            // std.debug.print("{d}\n", .{sum});
        }
    }

    std.debug.print("{d}", .{sum});
}

fn checkIfValidGameSet(set: GameSet) !bool {
    for (set.games) |game| {
        for (game.pulls) |pull| {
            const color_count = total_marble_map.get(pull.color);

            if (color_count) |v| {
                if (pull.count > v) {
                    // std.debug.print("invalid Game: {d}, color: {s}, count: {d}\n", .{ set.game_index, pull.color, pull.count });

                    return false;
                }
            }
        }
    }

    return true;
}

fn convertLineToGame(line: []const u8) !GameSet {
    var result = std.mem.split(u8, line, ":");

    const game_number = result.first();
    const games = result.next().?;

    const index = try std.fmt.parseInt(u8, game_number[5..], 10);

    const parsed_games = try get_games(games);

    return GameSet{ .game_index = index, .valid = true, .games = parsed_games };
}

fn get_games(games: []const u8) ![]Game {
    var split_games = std.mem.split(u8, games, ";");

    var parsed_games = std.ArrayList(Game).init(std.heap.page_allocator);
    defer parsed_games.deinit();

    while (split_games.next()) |game| {
        const pulls = try get_pulls(game);
        try parsed_games.append(Game{ .pulls = pulls });
    }

    return parsed_games.toOwnedSlice();
}

fn get_pulls(game: []const u8) ![]Pull {
    var split_pulls = std.mem.split(u8, game, ",");

    var pulls = std.ArrayList(Pull).init(std.heap.page_allocator);
    defer pulls.deinit();

    while (split_pulls.next()) |pull| {
        var split_pull = std.mem.tokenize(u8, pull, " ");

        const count = split_pull.next().?;
        var color = split_pull.next().?;
        color = std.mem.trim(u8, color, "\n\r");

        try pulls.append(Pull{ .count = try std.fmt.parseInt(u8, count, 10), .color = color });
    }

    return pulls.toOwnedSlice();
}
