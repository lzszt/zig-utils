const std = @import("std");
const Io = std.Io;
const print = std.debug.print;

// pub fn main(init: std.process.Init) !void {
//     try Io.File.stdout().writeStreamingAll(init.io, "hello world!\n");
// }
pub fn main(init: std.process.Init) !void {
    const args = try init.minimal.args.toSlice(init.arena.allocator());

    if (args.len == 1) {
        std.debug.print("Usage: {s} PROG\n", .{args[0]});
        return;
    }

    const PROG = args[1];

    print("Looking for program: {s}\n", .{PROG});

    const PATH: []const u8 = init.environ_map.get("PATH") orelse "";

    var dirs = std.mem.splitScalar(u8, PATH, ':');

    while (dirs.next()) |dir| {
        print("{s}\n", .{dir});
    }
}
