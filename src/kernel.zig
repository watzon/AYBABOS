const std = @import("std");
const builtin = @import("builtin");
pub const tty = @import("./kernel/tty.zig");
pub const drivers = @import("./kernel/drivers.zig");

// comptime {
//     @export(panic, .{ .name = "panic" });
//     @export(kmain, .{ .name = "kmain" });
// }
