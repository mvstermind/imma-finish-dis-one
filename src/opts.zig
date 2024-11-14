const std = @import("std");
const main = @import("main.zig");
const print = std.debug.print;

const TARGET_ARG = [2][]const u8{ "-t", "--target" };
const DWORDLIST_ARG: [2][]const u8 = .{ "-dw", "--dirwordlist" };
const SWORDLIST_ARG: [2][]const u8 = .{ "-sw", "--subwordlist" };
const SAVE_ARG: [2][]const u8 = .{ "-s", "--save" };
const HELP_ARG: [2][]const u8 = .{ "-h", "--help" };

const Target = struct {
    address: [*:0]u8,

    is_dir: bool,
    dir_wordlist: [*:0]u8,

    is_sub: bool,
    sub_wordlist: [*:0]u8,

    save_output: bool,
    output_file: [*:0]u8,
};

pub fn checkArgs(sys_args: [][*:0]u8) void {
    var target: Target = Target{ .address = undefined, .is_sub = false, .is_dir = false };

    for (sys_args, 0..sys_args.len - 1) |curr_arg, i| {
        if (argsCmp(curr_arg, TARGET_ARG)) {
            target.address = sys_args[i + 1];
        }

        if (argsCmp(curr_arg, DWORDLIST_ARG)) {
            target.is_dir = true;
            target.dir_wordlist = sys_args[i + 1];
        }

        if (argsCmp(curr_arg, SWORDLIST_ARG)) {
            target.is_sub = true;
            target.sub_wordlist = sys_args[i + 1];
        }

        if (argsCmp(curr_arg, HELP_ARG)) {
            main.displayHelp();
            return;
        }

        if (argsCmp(curr_arg, SAVE_ARG)) {
            target.save_output = true;
            target.output_file = sys_args[i + 1];
        } else {
            print("Invalid input: \n", .{});
            for () |value| {}
        }
    }

    print("{s}", .{target});
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
