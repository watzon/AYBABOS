const std = @import("std");
const debug = std.debug;

pub const IRQ_VECTOR_BASE = 0x50;

pub const Cpuid = struct {
    eax: u32,
    ebx: u32,
    ecx: u32,
    edx: u32,
};

pub const CpuInfo = struct {
    vendorId: [12]u8,
    family: u32,
    model: u32,
    modelName: [48]u8,
    stepping: u32,
    // cacheSize: u32

    pub fn init() CpuInfo {
        // EAX=0: Highest Function Parameter and Manufacturer ID
        const vInfo = getCpuid(0);
        const vendorId = getVendorId(vInfo);

        // EAX=1: EAX=1: Processor Info and Feature Bits
        const pInfo = getCpuid(1);
        const stepping = getSteppingId(pInfo);
        const model = getModel(pInfo);
        const family = getFamily(pInfo);

        // EAX=80000000H: Returns CPUID's Highest Value for Extended Processor Information
        const epInfo = getCpuidCount(0, 0x8b);

        // EAX=80000002h,80000003h,80000004h: Processor Brand String
        const modelName = getModelName();

        return .{
            .vendorId = vendorId,
            .stepping = stepping,
            .model = model,
            .family = family,
            .modelName = modelName,
        };
    }

    fn getVendorId(manInfo: Cpuid) [12]u8 {
        const ebx = manInfo.ebx;
        const ecx = manInfo.edx;
        const edx = manInfo.ecx;
        const data = [3]u32{ ebx, ecx, edx };
        return @bitCast([12]u8, data);
    }

    fn getSteppingId(pInfo: Cpuid) u32 {
        return pInfo.eax & 0xF;
    }

    fn getModel(pInfo: Cpuid) u32 {
        const family = (pInfo.eax >> 8) & 0xF;
        var model = (pInfo.eax >> 4) & 0xF;
        if (family == 6 or family == 15) {
            const extendedModel = (pInfo.eax >> 16) & 0xF;
            model = (extendedModel << 4) + model;
        }
        return model;
    }

    fn getFamily(pInfo: Cpuid) u32 {
        var family = (pInfo.eax >> 8) & 0xF;
        if (family == 15) {
            const extendedFamily = (pInfo.eax >> 20) & 0xFF;
            family = family + extendedFamily;
        }
        return family;
    }

    fn getModelName() [48]u8 {
        const p1 = getCpuid(0x80000002);
        const p2 = getCpuid(0x80000003);
        const p3 = getCpuid(0x80000004);
        const data = [12]u32{ p1.eax, p1.ebx, p1.ecx, p1.edx, p2.eax, p2.ebx, p2.ecx, p2.edx, p3.eax, p3.ebx, p3.ecx, p3.edx };
        return @bitCast([48]u8, data);
    }
};

fn getCpuidMax(ext: u32) u32 {
    const info = cpuid(ext);
    return info.eax;
}

pub fn getCpuid(leaf: u32) Cpuid {
    const ext = leaf & 0x80000000;
    const maxLevel = getCpuidMax(ext);

    if (maxLevel == 0 or maxLevel < leaf)
        return .{ .eax = 0, .ebx = 0, .ecx = 0, .edx = 0 };

    return cpuid(leaf);
}

pub fn getCpuidCount(leaf: u32, count: u32) Cpuid {
    const ext = leaf & 0x80000000;
    const maxLevel = getCpuidMax(ext);

    if (maxLevel == 0 or maxLevel < leaf)
        return .{ .eax = 0, .ebx = 0, .ecx = 0, .edx = 0 };

    return cpuidCount(leaf, count);
}

/// Using the specified level set the eax, ebx, ecx, and edx pointers to the
/// values returned by the processor.
///
/// See: https://en.wikipedia.org/wiki/CPUID
pub fn cpuid(level: u32) Cpuid {
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

    return .{ .eax = a, .ebx = b, .ecx = c, .edx = d };
}

/// Using the specified level and count set the eax, ebx, ecx, and edx pointers to the
/// values returned by the processor.
///
/// See: https://en.wikipedia.org/wiki/CPUID
pub fn cpuidCount(level: u32, count: u32) Cpuid {
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

    return .{ .eax = a, .ebx = b, .ecx = c, .edx = d };
}

pub fn lsb(x: u16) u8 {
    return @intCast(u8, x & 0xFF);
}

pub fn lsw(x: u16) u32 {
    return @intCast(u32, x) & 0xFFFF;
}

pub fn msb(x: u16) u8 {
    return @intCast(u8, (x >> 8) & 0xFF);
}

pub fn msw(x: u16) u32 {
    return (@intCast(u32, x) >> 16) & 0xFFFF;
}
