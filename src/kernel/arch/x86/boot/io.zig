// Copyright (c) 2020 Chris Watson
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

// Minimum number of stack bytes
const STACK_SIZE = 1024;

/// Executes the equivilent of the PAUSE instruction for
/// x86_64 CPUs. This provides a hint to the processor
/// that the code sequence is a spin-wait loop.
pub fn cpu_relax() void {
    asm volatile ("rep; nop");
}

/// Implements the `out` instruction for an x86 processor.
/// `type` must be one of `u8`, `u16`, `u32`, `port` is the
/// port number and `value` will be sent to that port.
pub inline fn out(comptime T: type, port: u16, value: T) void {
    switch (T) {
        u8 => return outb(port, value),
        u16 => return outw(port, value),
        u32 => return outl(port, value),
        else => @compileError("Only u8, u16 or u32 are allowed for port I/O!"),
    }
}

/// Implements the `in` instruction for an x86 processor.
/// `type` must be one of `u8`, `u16`, `u32`, `port` is the
/// port number and the value received from that port will be returned.
pub inline fn in(comptime T: type, port: u16) T {
    switch (T) {
        u8 => return inb(port),
        u16 => return inw(port),
        u32 => return inl(port),
        else => @compileError("Only u8, u16 or u32 are allowed for port I/O!"),
    }
}

pub inline fn outb(port: u16, data: u8) void {
    asm volatile ("outb %[data],%[port]"
        :
        : [port] "{dx}" (port),
          [data] "{al}" (data)
    );
}

pub inline fn inb(port: u16) u8 {
    return asm volatile ("inb %[port],%[result]"
        : [result] "={al}" (-> u8)
        : [port] "{dx}" (port)
    );
}

pub inline fn outw(port: u16, data: u16) void {
    asm volatile ("outw %[data],%[port]"
        :
        : [port] "{dx}" (port),
          [data] "{ax}" (data)
    );
}

pub inline fn inw(port: u16) void {
    return asm volatile ("inw %[port],%[result]"
        : [result] "={ax}" (-> u16)
        : [port] "{dx}" (port)
    );
}

pub inline fn outl(port: u16, data: u32) void {
    asm volatile ("outl %[data],%[port]"
        :
        : [port] "{dx}" (port),
          [data] "{eax}" (data)
    );
}

pub inline fn inl(port: u16) u16 {
    return asm volatile ("inl %[port],%[result]"
        : [result] "={eax}" (-> u32)
        : [data] "{dx}" (data)
    );
}

pub inline fn ioDelay() void {
    const delayPort = 0x80;
    asm volatile ("outb %%al,%0"
        :
        : [delayPort] "dN" (delayPort)
    );
}

pub inline fn memcmp_fs(s1: ?*const c_void, s2: c_uint, len: usize) bool {
    return asm volatile ("fs; repe; cmpsb"
        : [diff] "=@cc" (-> bool),
          [s1] "+D" (s1),
          [s2] "+S" (s2),
          [len] "+c" (len)
    );
}

pub inline fn memcmp_gs(s1: ?*const c_void, s2: c_uint, len: usize) bool {
    return asm volatile ("gs; repe; cmpsb"
        : [diff] "=@cc" (-> bool),
          [s1] "+D" (s1),
          [s2] "+S" (s2),
          [len] "+c" (len)
    );
}
