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
    is_address: bool,

    is_dir: bool,
    dir_wordlist: [*:0]u8,

    is_sub: bool,
    sub_wordlist: [*:0]u8,

    save_output: bool,
    output_file: [*:0]u8,
};

pub fn checkArgs(sys_args: [][*:0]u8) void {
    var target = newTarget();

    for (sys_args, 0..sys_args.len) |curr_arg, i| {
        if (argsCmp(curr_arg, TARGET_ARG)) {
            // required fella
            target.is_address = true;
            if (i + 1 > sys_args.len) {
                return;
            }

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
        }
    }
    validateArgs(target);
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

// check if we have all required args to go
// if not then we are fucked
fn validateArgs(target: Target) void {
    const allocator = std.heap.page_allocator;
    var missing_args = std.ArrayList(u8).init(allocator);
    defer missing_args.deinit();

    if (!target.is_address) {
        const target_str = "Target";
        missing_args.appendSlice(target_str) catch {
            return;
        };
    }

    print("Missing args:\n", .{});
    // Convert the ArrayList to a slice for printing
    const args_slice = missing_args.toOwnedSlice();
    print("{any}\n", .{args_slice});
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

fn thereIsNextIndex(curr_index: comptime_int, length: comptime_int) bool {}
