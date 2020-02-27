const std = @import("std");
const builtin = @import("builtin");
const kernel = @import("kernel");
const tty = kernel.tty;

// Exports
comptime {
    @export(multiboot, .{ .name = "multiboot", .section = ".multiboot" });
    @export(start, .{ .name = "_start" });
}

// Declare constants for the multiboot header.
const ALIGN = 1 << 0; // align loaded modules on page boundaries
const MEMINFO = 1 << 1; // provide memory map
const VIDEO_MODE = 1 << 2; // set the video mode
const FLAGS = ALIGN | MEMINFO | VIDEO_MODE; // this is the Multiboot 'flag' field
const MAGIC = 0x1BADB002; // 'magic number' lets bootloader find the header
const CHECKSUM = -(MAGIC + FLAGS); // checksum of above, to prove we are multiboot

const MultiBoot = extern struct {
    magic: c_long,
    flags: c_long,
    checksum: c_long,

    // For memory info
    header_addr: c_long = 0x00000000,
    load_addr: c_long = 0x00000000,
    load_end_addr: c_long = 0x00000000,
    bss_end_addr: c_long = 0x00000000,
    entry_addr: c_long = 0x00000000,

    // For video mode
    mode_type: c_long = 0x00000001, // 0 for linear graphics, 1 for ega
    width: c_long,
    height: c_long,
    depth: c_long,
};

// Declare a multiboot header that marks the program as a kernel.
var multiboot align(4) = MultiBoot{
    .magic = MAGIC,
    .flags = FLAGS,
    .checksum = CHECKSUM,
    .width = 720,
    .height = 480,
    .depth = 32,
};

// This allocates room for a small stack by creating a symbol at the bottom of it,
// then allocating 16384 bytes for it, and finally creating a symbol at the top.
var stack_bytes: [16 * 1024]u8 align(16) linksection(".bss") = undefined;

// The linker script specifies _start as the entry point to the kernel and the
// bootloader will jump to this position once the kernel has been loaded. It
// doesn't make sense to return from this function as the bootloader is gone.
fn start() callconv(.Naked) void {
    @call(.{ .stack = stack_bytes[0..] }, kmain, .{});
}

// Create a new panic function so that we can see what has gone wrong. This
// defers to kernel.panic.
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
