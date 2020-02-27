// Copyright (c) 2020 Chris Watson
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

// Minimum number of stack bytes
const STACK_SIZE = 1024;

pub fn cpu_relax() void {
    asm volatile ("rep; nop");
}

pub inline fn outb(v: u8, port: u16) void {
    asm volatile ("outb %0,%1"
        :
        : [v] "a" (v),
          [v] "dN" (v)
    );
}

pub inline fn inb(port: u16) u8 {
    var v: u8 = undefined;
    asm volatile ("inb %1,%0"
        : [v] "=a" (v)
        : [port] "dN" (port)
    );
    return v;
}

pub inline fn outw(v: u16, port: u16) void {
    asm volatile ("outw %0,%1"
        :
        : [v] "a" (v),
          [port] "dN" (port)
    );
}

pub inline fn inw(port: u16) void {
    var v: u16 = undefined;
    asm volatile ("inw %1,%0"
        : [v] "=a" (v)
        : [port] "dN" (port)
    );
}

pub inline fn outl(port: u16) void {
    asm volatile ("outl %0,%1"
        :
        : [v] "a" (v),
          [port] "dN" (port)
    );
}

pub inline fn inl(port: u16) u16 {
    var v: u32 = undefined;
    asm volatile ("inl %1,%0"
        : [v] "=a" (v)
        : [port] "dN" (port)
    );
    return v;
}

pub inline fn ioDelay() void {
    const delayPort = 0x80;
    asm volatile ("outb %%al,%0"
        :
        : [delayPort] "dN" (delayPort)
    );
}

// These functions are used to reference data in other segments.

pub inline fn ds() u16 {
    var seg: u16 = undefined;
    asm ("movw %%ds,%0"
        : [seg] "=rm" (seg)
    );
    return seg;
}

pub inline fn set_fs(seg: u16) void {
    asm volatile ("movw %0,%%fs"
        :
        : [seg] "rm" (seg)
    );
}

pub inline fn fs() u16 {
    var seg: u16 = undefined;
    asm volatile ("movw %%fs,%0"
        : [seg] "=rm" (seg)
    );
    return seg;
}

pub inline fn set_gs(seg: u16) void {
    asm volatile ("movw %0,%%gs"
        :
        : [seg] "rm" (seg)
    );
}

pub inline fn gs() u16 {
    var seg: u16 = undefined;
    asm volatile ("movw %%gs,%0"
        : [seg] "=rm" (seg)
    );
    return seg;
}

pub inline fn rdfs8(addr: c_uint) u8 {
    var v: u8 = undefined;
    asm volatile ("movb %%fs:%1,%0"
        : [v] "=q" (v)
        : [addr] "m" (@as(u8, addr))
    );
    return v;
}

pub inline fn rdfs16(addr: c_uint) u16 {
    var v: u16 = undefined;
    asm volatile ("movw %%fs:%1,%0"
        : [v] "=r" (v)
        : [addr] "m" (@as(u16, addr))
    );
    return v;
}

pub inline fn rdfs32(addr: c_uint) u32 {
    var v: u32 = undefined;
    asm volatile ("movl %%fs:%1,%0"
        : [v] "=r" (v)
        : [addr] "m" (@as(u32, addr))
    );
    return v;
}

pub inline fn wrfs8(v: u8, addr: c_uint) void {
    asm volatile ("movb %1,%%fs:%0"
        : [addr] "+m" (-> u8)
        : [v] "qi" (v)
    );
}

pub inline fn wrfs16(v: u16, addr: c_uint) void {
    asm volatile ("movw %1,%%fs:%0"
        : [addr] "+m" (-> u16)
        : [v] "ri" (v)
    );
}

pub inline fn wrfs32(v: u32, addr: c_uint) void {
    asm volatile ("movl %1,%%fs:%0"
        : [addr] "+m" (-> u16)
        : [v] "ri" (v)
    );
}

pub inline fn rdgs8(addr: c_uint) u8 {
    var v: u8 = undefined;
    asm volatile ("movb %%gs:%1,%0"
        : [v] "=q" (v)
        : [addr] "m" (@as(u8, addr))
    );
    return v;
}

pub inline fn rdgs16(addr: c_uint) u16 {
    var v: u16 = undefined;
    asm volatile ("movw %%gs:%1,%0"
        : [v] "=r" (v)
        : [addr] "m" (@as(u16, addr))
    );
    return v;
}

pub inline fn rdgs32(addr: c_uint) u32 {
    var v: u32 = undefined;
    asm volatile ("movl %%gs:%1,%0"
        : [v] "=r" (v)
        : [addr] "m" (@as(u32, addr))
    );
    return v;
}

pub inline fn wrgs8(v: u8, addr: c_uint) void {
    asm volatile ("movb %1,%%gs:%0"
        : [addr] "+m" (-> u8)
        : [v] "qi" (v)
    );
}

pub inline fn wrgs16(v: u16, addr: c_uint) void {
    asm volatile ("movw %1,%%gs:%0"
        : [addr] "+m" (-> u16)
        : [v] "ri" (v)
    );
}

pub inline fn wrgs32(v: u32, addr: c_uint) void {
    asm volatile ("movl %1,%%gs:%0"
        : [addr] "+m" (-> u16)
        : [v] "ri" (v)
    );
}

pub inline fn memcmp_fs(s1: ?*const c_void, s2: c_uint, len: usize) bool {
    var diff: bool = undefined;
    asm volatile ("fs; repe; cmpsb"
        : [diff] "=@cc" (diff),
          [s1] "+D" (s1),
          [s2] "+S" (s2),
          [len] "+c" (len)
    );
    return diff;
}

pub inline fn memcmp_gs(s1: ?*const c_void, s2: c_uint, len: usize) bool {
    var diff: bool = undefined;
    asm volatile ("gs; repe; cmpsb"
        : [diff] "=@cc" (diff),
          [s1] "+D" (s1),
          [s2] "+S" (s2),
          [len] "+c" (len)
    );
    return diff;
}

const reg32 = extern struct {
    edi: u32,
    esi: u32,
    ebp: u32,
    _esp: u32,
    ebx: u32,
    edx: u32,
    ecx: u32,
    eax: u32,
    _fsgs: u32,
    _dses: u32,
    eflags: u32,
};

const reg16 = extern struct {
    di,
    hdi: u16,
    si,
    hsi: u16,
    bp,
    hbp: u16,
    _sp,
    _hsp: u16,
    bx,
    hbx: u16,
    dx,
    hdx: u16,
    cx,
    hcx: u16,
    ax,
    hax: u16,
    gs,
    fs: u16,
    es,
    ds: u16,
    flags,
    hflags: u16,
};

const reg8 = extern struct {
    dil,
    dih,
    edi2,
    edi3: u8,
    sil,
    sih,
    esi2,
    esi3: u8,
    bpl,
    bph,
    ebp2,
    ebp3: u8,
    _spl,
    _sph,
    _esp2,
    _esp3: u8,
    bl,
    bh,
    ebx2,
    ebx3: u8,
    dl,
    dh,
    edx2,
    edx3: u8,
    cl,
    ch,
    ecx2,
    ecx3: u8,
    al,
    ah,
    eax2,
    eax3: u8,
};

const biosregs = extern struct {
    reg: extern union {
        reg32: reg32,
        reg16: reg16,
        reg8: reg8,
    },
};

fn something() void {
    var ireg: biosregs = undefined;
    var oreg: biosregs = undefined;
    ireg = .{ .cl = 122 };
}
