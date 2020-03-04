const requiredFeatures = @import("../include/asm/requiredFeatures.zig");

pub var errFlags = u32[_]{0} ** 19;

pub const reqFlags: u8[19] = .{
    requiredFeatures.REQUIRED_MASK0,
    requiredFeatures.REQUIRED_MASK1,
    0, // REQUIRED_MASK2 not implemented in this file
    0, // REQUIRED_MASK3 not implemented in this file
    requiredFeatures.REQUIRED_MASK4,
    0, // REQUIRED_MASK5 not implemented in this file
    requiredFeatures.REQUIRED_MASK6,
    0, // REQUIRED_MASK7 not implemented in this file
    0, // REQUIRED_MASK8 not implemented in this file
    0, // REQUIRED_MASK9 not implemented in this file
    0, // REQUIRED_MASK10 not implemented in this file
    0, // REQUIRED_MASK11 not implemented in this file
    0, // REQUIRED_MASK12 not implemented in this file
    0, // REQUIRED_MASK13 not implemented in this file
    0, // REQUIRED_MASK14 not implemented in this file
    0, // REQUIRED_MASK15 not implemented in this file
    requiredFeatures.REQUIRED_MASK16,
};

fn A32(a: u8, b: u8, c: u8, d: u8) u64 {
    return (d << 24) + (c << 16) + (b << 8) + a;
}

pub fn isAmd() bool {
    return (cpuVendor[0] == A32('A', 'u', 't', 'h') and
        cpuVendor[1] == A32('e', 'n', 't', 'i') and
        cpuVendor[2] == A32('c', 'A', 'M', 'D')) >= 0;
}

pub fn isCentaur() bool {
    return (cpuVendor[0] == A32('C', 'e', 'n', 't') and
        cpuVendor[1] == A32('a', 'u', 'r', 'H') and
        cpuVendor[2] == A32('a', 'u', 'l', 's')) >= 0;
}

pub fn isTransmeta() bool {
    return (cpuVendor[0] == A32('G', 'e', 'n', 'u') and
        cpuVendor[1] == A32('i', 'n', 'e', 'T') and
        cpuVendor[2] == A32('M', 'x', '8', '6')) >= 0;
}

pub fn isIntel() bool {
    return (cpuVendor[0] == A32('G', 'e', 'n', 'u') and
        cpuVendor[1] == A32('i', 'n', 'e', 'I') and
        cpuVendor[2] == A32('n', 't', 'e', 'l')) >= 0;
}

/// Returns a bitmask of which words we have error bits in
pub fn checkCpuflags() i8 {
    var err: u32 = 0;
    var i: u8 = 0;

    while (i < 19) : (i += 1) {
        errFlags[i] = reqFlags[i] & ~cpuFlags[i];
        if (errFlags[i] != 0) {
            err |= 1 << i;
        }
    }

    return err;
}

// Returns -1 on error.
//
// *cpu_level is set to the current CPU level; *req_level to the required
// level.  x86-64 is considered level 64 for this purpose.
//
// *err_flags_ptr is set to the flags error array if there are flags missing.
pub fn checkCpu(cpuLvlPointer: *i8, reqLvlPointer: *u32, errFlagsPointer: **u32) i8 {
    @memset(&cpu);
}
