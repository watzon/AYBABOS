const std = @import("std");
const debug = std.debug;
const fmt = std.fmt;

pub const CpuInfo = struct {
    vendorId: []const u8,
    cpuFamily: u32,
    model: u32,
    modelName: []const u8,
    stepping: u32,
    // microcode: u32,
    // cacheSize: u32
};

fn getCpuidMax(ext: u8, sig: *u32) u32 {
    var eax: u32 = undefined;
    var ebx: u32 = undefined;
    var ecx: u32 = undefined;
    var edx: u32 = undefined;

    cpuid(ext, &eax, &ebx, &ecx, &edx);

    if (sig.* != 0)
        sig.* = ebx;

    return eax;
}

fn getCpuid(leaf: u32, eax: *u32, ebx: *u32, ecx: *u32, edx: *u32) bool {
    const ext = leaf & 0x80000000;
    const maxLevel = getCpuidMax(ext, 0);

    if (maxLevel == 0 or maxLevel < leaf)
        return true;

    cpuId(leaf, *eax, *ebx, *ecx, *edx);
    return true;
}

/// Using the specified level set the eax, ebx, ecx, and edx pointers to the
/// values returned by the processor.
///
/// See: https://en.wikipedia.org/wiki/CPUID
pub fn cpuid(level: u8, eax: *u32, ebx: *u32, ecx: *u32, edx: *u32) void {
    var a: u32 = undefined;
    var b: u32 = undefined;
    var c: u32 = undefined;
    var d: u32 = undefined;

    asm volatile ("cpuid"
        : [a] "={eax}" (a),
          [b] "={ebx}" (b),
          [c] "={ecx}" (c),
          [d] "={edx}" (d)
        : [level] "{eax}" (level)
    );

    eax.* = a;
    ebx.* = b;
    ecx.* = c;
    edx.* = d;
}

/// Using the specified level and count set the eax, ebx, ecx, and edx pointers to the
/// values returned by the processor.
///
/// See: https://en.wikipedia.org/wiki/CPUID
pub fn cpuidCount(level: u8, count: u8, eax: *u32, ebx: *u32, ecx: *u32, edx: *u32) void {
    var a: u32 = undefined;
    var b: u32 = undefined;
    var c: u32 = undefined;
    var d: u32 = undefined;

    asm volatile ("cpuid"
        : [a] "={eax}" (a),
          [b] "={ebx}" (b),
          [c] "={ecx}" (c),
          [d] "={edx}" (d)
        : [level] "{eax}" (level),
          [count] "{ecx}" (count)
    );

    eax.* = a;
    ebx.* = b;
    ecx.* = c;
    edx.* = d;
}
