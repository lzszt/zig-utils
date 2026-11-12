const std = @import("std");
const Io = std.Io;

pub fn main(init: std.process.Init) !void {
    const IO = init.io;
    const args = try init.minimal.args.toSlice(init.arena.allocator());

    var stdout_buf: [4096]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(init.io, &stdout_buf);
    const out = &stdout_writer.interface;

    if (args.len == 1) {
        try out.print("Usage: {s} PROG\n", .{args[0]});
        try out.flush();
        return;
    }

    const PROG = args[1];

    const PATH: []const u8 = init.environ_map.get("PATH") orelse "";

    var dirs = std.mem.splitScalar(u8, PATH, ':');

    var found = false;

    dirLoop: while (dirs.next()) |dirPath| {
        const dirOrError = std.Io.Dir.openDirAbsolute(
            IO,
            dirPath,
            .{ .iterate = true },
        );

        if (dirOrError) |dir| {
            defer dir.close(IO);
            var dirIterator = dir.iterate();

            while (try dirIterator.next(IO)) |dirContent| {
                if (std.mem.eql(u8, dirContent.name, PROG)) {
                    if (dirContent.kind == std.Io.File.Kind.sym_link) {
                        var buf: [std.fs.max_path_bytes]u8 = undefined;

                        const len = try dir.readLink(IO, PROG, &buf);
                        const fullPath = buf[0..len];

                        try out.print("{s}\n", .{fullPath});
                    } else {
                        try out.print("{s}/{s}\n", .{ dirPath, PROG });
                    }
                    found = true;
                    break :dirLoop;
                }
            }
        } else |_| {}
    }

    if (!found) {
        try out.print("failed to find {s} in {s}\n", .{ PROG, PATH });
    }
    try out.flush();
}
