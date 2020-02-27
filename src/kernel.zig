const std = @import("std");
const builtin = @import("builtin");
pub const tty = @import("./kernel/tty.zig");
pub const drivers = @import("./kernel/drivers.zig");

// comptime {
//     @export(panic, .{ .name = "panic" });
//     @export(kmain, .{ .name = "kmain" });
// }

pub fn panic(msg: []const u8, error_return_trace: ?*builtin.StackTrace) noreturn {
    @setCold(true);
    tty.reset();
    tty.write("KERNEL PANIC: ");
    tty.write(msg);
    while (true) {}
}

pub fn kmain() callconv(.C) noreturn {
    tty.reset();
    tty.write("Hello, kernel World!\n");
    while (true) {}
}
