const io = @import("./io.zig");

/// Read from the specified CMOS register.
///
/// See: https://wiki.osdev.org/CMOS
pub fn read(index: u8) u8 {
    io.out(u8, 0x70, index);
    return io.in(u8, 0x71);
}

/// Write to the specified CMOS register.
///
/// See: https://wiki.osdev.org/CMOS
pub fn write(index: u8, data: u8) void {
    io.out(u8, 0x70, index);
    io.out(u8, 0x71, data);
}
