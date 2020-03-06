const io = @import("io.zig");
const idt = @import("idt.zig");
const Terminal = @import("tty.zig");

fn sendCommand(cmd: u8) void {

    // Wait until the keyboard is ready and the command buffer is empty
    while ((io.in(u8, 0x64) & 0x2) != 0) {}
    io.out(u8, 0x60, cmd);
}

pub fn init() void {
    // Register IRQ handler for IRQ-Keyboard (1)
    idt.setIRQHandler(1, kbdIrqHandler);
    idt.setIRQHandler(12, mouseIrqHandler);

    // Empty keyboard buffer
    while ((io.in(u8, 0x64) & 0x1) != 0) {
        _ = io.in(u8, 0x60);
    }

    // Activate the keyboard
    sendCommand(0xF4);

    idt.enableIRQ(1);

    vga.print("Keyboard initialized\n", .{});
}

pub const KeyEvent = struct {
    set: ScancodeSet,
    scancode: u16,
    char: ?u8,
};

var foo: u32 = 0;
var lastKeyPress: ?KeyEvent = null;

pub fn getKey() ?KeyEvent {
    _ = @atomicLoad(u32, &foo, .SeqCst);
    var copy = lastKeyPress;
    lastKeyPress = null;
    return copy;
}

const ScancodeSet = enum {
    default,
    extended0,
    extended1,
};

const ScancodeInfo = packed struct {
    unused: u8,
    lowerCase: u8,
    upperCase: u8,
    graphCase: u8,
};

const scancodeTableDefault = @bitCast([128]ScancodeInfo, @ptrCast(*const [512]u8, @embedFile("stdkbd_default.bin")).*);

var isShiftPressed = false;
var isAltPressed = false;
var isControlPressed = false;
var isGraphPressed = false;

fn pushScancode(set: ScancodeSet, scancode: u16, isRelease: bool) void {
    if (set == .default) {
        switch (scancode) {
            29 => isControlPressed = !isRelease,
            42 => isShiftPressed = !isRelease,
            56 => isAltPressed = !isRelease,
            else => {},
        }
    } else if (set == .extended0) {
        switch (scancode) {
            56 => isGraphPressed = !isRelease,
            else => {},
        }
    }

    if (!isRelease) {
        var keyinfo = if (scancode < 128 and set == .default) scancodeTableDefault[scancode] else ScancodeInfo{
            .unused = undefined,
            .lowerCase = 0,
            .upperCase = 0,
            .graphCase = 0,
        };

        var chr = if (isGraphPressed) keyinfo.graphCase else if (isShiftPressed) keyinfo.upperCase else keyinfo.lowerCase;

        lastKeyPress = KeyEvent{
            .set = set,
            .scancode = scancode,
            .char = if (chr != 0) chr else null,
        };
    }

    vga.print("[kbd:{}/{}/{}]", .{ set, scancode, if (isRelease) "R" else "P" });
}

pub const FKey = enum {
    F1,
    F2,
    F3,
    F4,
    F5,
    F6,
    F7,
    F8,
    F9,
    F10,
    F11,
    F12,
};

const IrqState = enum {
    default,
    receiveE0,
    receiveE1_Byte0,
    receiveE1_Byte1,
};

var irqState: IrqState = .default;
var e1Byte0: u8 = undefined;

fn kbdIrqHandler(cpu: *idt.CpuState) *idt.CpuState {
    var newCpu = cpu;

    const inputData = io.in(u8, 0x60);
    irqState = switch (irqState) {
        .default => switch (inputData) {
            0xE0 => IrqState.receiveE0,
            0xE1 => IrqState.receiveE1_Byte0,
            else => blk: {
                const scancode = inputData & 0x7F;
                const isRelease = (inputData & 0x80 != 0);

                switch (scancode) {
                    59...68, 87, 88 => {
                        if (isRelease)
                            return cpu;

                        // TODO: Implement this
                        // return @import("root").handleFKey(cpu, switch (scancode) {
                        //     59 => FKey.F1,
                        //     60 => FKey.F2,
                        //     61 => FKey.F3,
                        //     62 => FKey.F4,
                        //     63 => FKey.F5,
                        //     64 => FKey.F6,
                        //     65 => FKey.F7,
                        //     66 => FKey.F8,
                        //     67 => FKey.F9,
                        //     68 => FKey.F10,
                        //     87 => FKey.F11,
                        //     88 => FKey.F12,
                        //     else => unreachable,
                        // });
                        pushScancode(.default, scancode, isRelease);
                    },
                    else => pushScancode(.default, scancode, isRelease),
                }

                break :blk IrqState.default;
            },
        },
        .receiveE0 => switch (inputData) {
            // these are "fake shifts"
            0x2A, 0x36 => IrqState.default,
            else => blk: {
                pushScancode(.extended0, inputData & 0x7F, (inputData & 0x80 != 0));

                break :blk IrqState.default;
            },
        },
        .receiveE1_Byte0 => blk: {
            e1Byte0 = inputData;
            break :blk .receiveE1_Byte1;
        },
        .receiveE1_Byte1 => blk: {
            const scancode = (@as(u16, inputData) << 8) | e1Byte0;

            pushScancode(.extended1, scancode, (inputData & 0x80) != 0);

            break :blk .default;
        },
    };

    return newCpu;
}

fn mouseIrqHandler(cpu: *idt.CpuState) *idt.CpuState {
    @panic("EEK, A MOUSE!");
}
