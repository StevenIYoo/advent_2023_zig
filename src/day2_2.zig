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

    var sum: u32 = 0;

    for (games.items) |parsed_games| {
        sum += findPower(parsed_games);
    }

    std.debug.print("{d}", .{sum});
}

fn findPower(set: GameSet) u32 {
    var max_red: u16 = 0;
    var max_blue: u16 = 0;
    var max_green: u16 = 0;

    for (set.games) |game| {
        for (game.pulls) |pull| {
            if (std.mem.eql(u8, "red", pull.color) and pull.count > max_red) {
                max_red = pull.count;
            }

            if (std.mem.eql(u8, "blue", pull.color) and pull.count > max_blue) {
                max_blue = pull.count;
            }

            if (std.mem.eql(u8, "green", pull.color) and pull.count > max_green) {
                max_green = pull.count;
            }
        }
    }

    return max_red * max_blue * max_green;
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
        // I SPENT 4 HOURS TRYING TO DEBUG WHY THE LAST PULL WASN'T BEING PARSED AND THEN WINDOWS :madga:
        color = std.mem.trim(u8, color, "\n\r");

        try pulls.append(Pull{ .count = try std.fmt.parseInt(u8, count, 10), .color = color });
    }

    return pulls.toOwnedSlice();
}
