const Terminal = @import("tty.zig");
const task = @import("./task.zig");
const current = task.current;

pub const Function = enum {
    Putch = 0x1235,
    Sleep = 0x1982,
    Yield = 0x1983,
    PosixOpen = 0x1985,
    PosixClose = 0x1986,
    PosixRead = 0x1987,
    PosixSeek = 0x1988,
    PosixKill = 0x1989,
    PosixGetuid = 0x1990,
};

pub fn invoke0(function: u32) u32 {
    return asm ("int $0x80"
        : [result] "={eax}" (result)
        : [function] "{eax}" (function)
    );
}

pub fn invoke1(function: u32, d: u32) u32 {
    return asm ("int $0x80"
        : [result] "={eax}" (result)
        : [function] "{eax}" (function),
          [d] "{edx}" (d)
    );
}

pub fn invoke2(function: u32, d: u32, c: u32) u32 {
    return asm ("int $0x80"
        : [result] "={eax}" (result)
        : [function] "{eax}" (function),
          [d] "{edx}" (d),
          [c] "{ecx}" (c)
    );
}

pub fn invoke3(function: u32, d: u32, c: u32, b: u32) u32 {
    return asm ("int $0x80"
        : [result] "={eax}" (result)
        : [function] "{eax}" (function),
          [d] "{edx}" (d),
          [c] "{ecx}" (c),
          [b] "{ebx}" (b)
    );
}

// pub fn handle(function: Function, arg1: u32, arg2: u32, arg3: u32) u32 {
//     switch (function) {
//         .Yield => task.yield(),
//         .Putch => vga.print("%c", arg1 & 0xFF),
//         .Sleep => current.sys.sleep(arg1),
//         .PosixOpen => {
//             task.checkSanity("syscall");
//             vga.print("syscall: open('%s', '%u')\n", arg1, arg2);
//             return current.sys.open(@as(u8, arg1), arg2);
//         },
//         .PosixClose => {
//             vga.print("syscall: close('%d')\n", arg1);
//             return current.sys.close(arg1);
//         },
//         .PosixSeek => {
//
//         },
//         .PosixKill => {
//
//         },
//         .PosixGetuid => {
//
//         }
//     };
//     return 0;
// }
