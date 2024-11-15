const std = @import("std");
const main = @import("main.zig");
const print = std.debug.print;

const TARGET_ARG: [2][]const u8 = .{ "-t", "--target" };
const DWORDLIST_ARG: [2][]const u8 = .{ "-dw", "--dirwordlist" };
const SWORDLIST_ARG: [2][]const u8 = .{ "-sw", "--subwordlist" };
const SAVE_ARG: [2][]const u8 = .{ "-s", "--save" };
const HELP_ARG: [2][]const u8 = .{ "-h", "--help" };

pub const ALL_ARGS: [10][]const u8 = .{
    TARGET_ARG[0],    TARGET_ARG[1],
    DWORDLIST_ARG[0], DWORDLIST_ARG[1],
    SWORDLIST_ARG[0], SWORDLIST_ARG[1],
    SAVE_ARG[0],      SAVE_ARG[1],
    HELP_ARG[0],      HELP_ARG[1],
};

const Error = error{MissingArgs};

const Target = struct {
    address: [*:0]u8,
    is_address: bool,

    is_dir: bool,
    dir_wordlist: [*:0]u8,

    is_sub: bool,
    sub_wordlist: [*:0]u8,

    save_output: bool,
    output_file: [*:0]u8,
};

pub fn checkArgs(sys_args: [][*:0]u8) bool {
    var target = newTarget();

    // first check if there is valid input at all i.e if there is no flags next
    // to each other
    if (flagPositions(sys_args) == false) {
        return false;
    }

    for (sys_args, 0..sys_args.len) |curr_arg, i| {
        if (argsCmp(curr_arg, TARGET_ARG)) {
            if (thereIsNextIds(i, sys_args.len)) {
                target.is_address = true;
                target.address = sys_args[i + 1];
            } else {
                return false;
            }
        }

        if (argsCmp(curr_arg, DWORDLIST_ARG)) {
            if (thereIsNextIds(i, sys_args.len)) {
                target.is_dir = true;
                target.dir_wordlist = sys_args[i + 1];
            } else {
                return false;
            }
        }

        if (argsCmp(curr_arg, SWORDLIST_ARG)) {
            if (thereIsNextIds(i, sys_args.len)) {
                target.is_sub = true;
                target.sub_wordlist = sys_args[i + 1];
            } else {
                return false;
            }
        }

        if (argsCmp(curr_arg, HELP_ARG)) {
            main.displayHelp();
            return true;
        }

        if (argsCmp(curr_arg, SAVE_ARG)) {
            if (thereIsNextIds(i, sys_args.len)) {
                target.save_output = true;
                target.output_file = sys_args[i + 1];
            } else {
                return false;
            }
        }
    }
    std.debug.print("--Target :3 {s}\n", .{target.address});

    return true;
}

fn argsCmp(input_arg: [*:0]u8, command_arg: [2][]const u8) bool {
    if (std.mem.eql(u8, input_arg[0..std.mem.len(input_arg)], command_arg[0])) {
        return true;
    }
    if (std.mem.eql(u8, input_arg[0..std.mem.len(input_arg)], command_arg[1])) {
        return true;
    }
    return false;
}

fn newTarget() Target {
    return Target{
        .is_address = false,
        .is_dir = false,
        .is_sub = false,
        .save_output = false,
        .output_file = undefined,
        .address = undefined,
        .dir_wordlist = undefined,
        .sub_wordlist = undefined,
    };
}

fn thereIsNextIds(curr_index: u64, length: u64) bool {
    if (curr_index + 1 > length) {
        return false;
    } else {
        return true;
    }
}

fn flagPositions(user_flags: [][*]u8) bool {
    for (user_flags, 0..) |flag, i| {
        // skip HELP_ARG as it doesn't require a value
        if (flag == HELP_ARG[0] or flag == HELP_ARG[1]) {
            continue;
        }

        var is_valid_flag = false;
        for (ALL_ARGS) |arg| {
            if (flag == arg) {
                is_valid_flag = true;
                break;
            }
        }

        if (is_valid_flag) {
            if (i + 1 < user_flags.len) {
                const next_value = user_flags[i + 1];

                var is_next_flag = false;
                for (ALL_ARGS) |next_arg| {
                    if (next_value == next_arg) {
                        is_next_flag = true;
                        break;
                    }
                }

                if (is_next_flag) {
                    return false; // found a flag instead of an argument
                }
            } else {
                return false; // no argument for this flag
            }
        } else {
            return false; // invalid flag found
        }
    }

    return true; // all flags have valid arguments, except HELP_ARG
}

test "subject: does it recognize args?" {
    const valid_input: [4][*:0]u8 = .{
        @constCast("-t"),
        @constCast("10.10.10.10"),
        @constCast("-dw"),
        @constCast("./here"),
    };
    try std.testing.expect(checkArgs(@constCast(valid_input[0..])));

    const invalid_input: [3][*:0]u8 = .{
        @constCast("-dw"),
        @constCast("-t"),
        @constCast("10.10.10.10"),
    };

    // this should fail cuz -dw doesn't have any arg
    try std.testing.expect(checkArgs(@constCast(invalid_input[0..])));
}
