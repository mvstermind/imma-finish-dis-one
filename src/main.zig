const std = @import("std");
const ascii = @import("ascii.zig");
const opts = @import("opts.zig");

pub fn main() !void {
    const args = std.os.argv;

    if (args.len <= 1) {
        displayHelp();
    }

    opts.checkArgs(args[1..]);

    ascii.display();
}

pub fn displayHelp() void {
    const help =
        \\Options:
        \\    -t  --target      = victim address
        \\    -dw --dirwordlist = directory enumeration wordlist
        \\    -sw --subwordlist = subdomain enumeration wordlist
        \\    -m  --mode        = enumeration options (subdomain / dir)
        \\    -s  --save        = save output results to txt file
        \\
        \\Example:
        \\./tf-is-this-shit -t 10.x.x.x -m sub -sw ~/wordlist
        \\                     ^target   ^          ^--------------|
        \\                               |                         |
        \\                          will enumerate only subdomains |
        \\                                                         |
        \\                                          subdomains wordlist
    ;

    std.debug.print("{s}\n", .{help});
}
