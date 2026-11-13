const std = @import("std");
const Io = std.Io;
const File = std.Io.File;

pub fn main(init: std.process.Init) !void {
    const IO = init.io;
    const args = try init.minimal.args.toSlice(init.arena.allocator());

    var stdout_buf: [4096]u8 = undefined;
    var stdout_writer = File.stdout().writer(init.io, &stdout_buf);
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

    while (dirs.next()) |dirPath| {
        const dirOrError = std.Io.Dir.openDirAbsolute(
            IO,
            dirPath,
            .{ .iterate = true },
        );

        if (dirOrError) |dir| {
            defer dir.close(IO);

            const progFile = dir.openFile(IO, PROG, .{});
            if (progFile) |file| {
                defer file.close(IO);
                const stat = try File.stat(file, IO);

                const is_file = stat.kind == File.Kind.file;
                const is_exec = (@backingInt(stat.permissions) & 0o111) != 0;

                if (is_file and is_exec) {
                    found = true;

                    var buf: [std.fs.max_path_bytes]u8 = undefined;
                    const len = try file.realPath(IO, &buf);
                    const fullPath = buf[0..len];

                    try out.print("{s}\n", .{fullPath});
                    break;
                }
            } else |_| {}
        } else |_| {}
    }

    if (!found) {
        try out.print("failed to find {s} in {s}\n", .{ PROG, PATH });
    }

    try out.flush();
    if (found) {
        std.process.exit(0);
    } else {
        std.process.exit(1);
    }
}
