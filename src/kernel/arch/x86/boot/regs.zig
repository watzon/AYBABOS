const boot = @import("./boot.zig");
const biosregs = boot.biosregs;

pub fn initregs(reg: *biosregs) void {
    @memset(@ptrCast([*]u8, reg), 0, @sizeOf(biosregs));
    reg.reg32.eflags |= X86_FLAGS_CF;
    reg.reg16.ds = boot.ds();
    reg.reg16.es = boot.ds();
    reg.reg16.fs = boot.fs();
    reg.reg16.gs = boot.gs();
}
