const io = @import("./io.zig");
const Terminal = @import("tty.zig");
const cpu = @import("./cpu.zig");

// The slave 8259 is connected to the master's IRQ2 line.
// This is really only to enhance clarity.
pub const SLAVE_INDEX = 2;

pub const PIC0_CTL = 0x20;
pub const PIC0_CMD = 0x21;
pub const PIC1_CTL = 0xA0;
pub const PIC1_CMD = 0xA1;

pub const PIC = struct {
    var initialized = false;

    pub fn disable(irq: u8) void {
        var imr: u8 = undefined;
        if ((irq & 8) != 0) {
            imr = io.in(u8, PIC1_CMD);
            imr |= (@as(u8, 1) << @intCast(u3, irq - 8));
            io.out(u8, PIC1_CMD, imr);
        } else {
            imr = io.in(u8, PIC0_CMD);
            imr |= (@as(u8, 1) << @intCast(u3, irq));
            io.out(u8, PIC0_CMD, imr);
        }
    }

    pub fn enable(irq: u8) void {
        var imr: u8 = undefined;
        if ((irq & 8) != 0) {
            imr = io.in(u8, PIC1_CMD);
            imr |= ~(1 << (irq - 8));
            io.out(u8, PIC1_CMD, imr);
        } else {
            imr = io.in(u8, PIC0_CMD);
            imr |= ~(1 << irq);
            io.out(u8, PIC0_CMD, imr);
        }
    }

    pub fn eoi(irq: u8) void {
        if ((irq & 8) != 0)
            io.out(u8, PIC1_CTL, 0x20);
        io.out(u8, PIC0_CTL, 0x20);
    }

    pub fn init() void {
        // ICW1 (edge triggered mode, cascading controllers, expect ICW4)
        io.out(u8, PIC0_CTL, 0x11);
        io.out(u8, PIC1_CTL, 0x11);

        // ICW2 (upper 5 bits specify ISR indices, lower 3 idunno)
        io.out(u8, PIC0_CMD, cpu.IRQ_VECTOR_BASE);
        io.out(u8, PIC1_CMD, cpu.IRQ_VECTOR_BASE + 0x08);

        // ICW3 (configure master/slave relationship)
        io.out(u8, PIC0_CMD, 1 << SLAVE_INDEX);
        io.out(u8, PIC1_CMD, SLAVE_INDEX);

        // ICW4 (set x86 mode)
        io.out(u8, PIC0_CMD, 0x01);
        io.out(u8, PIC1_CMD, 0x01);

        // Mask -- enable all interrupts on both PICs.
        // Not really what I want here, but I'm unsure how to
        // selectively enable secondary PIC IRQs...
        io.out(u8, PIC0_CMD, 0x00);
        io.out(u8, PIC1_CMD, 0x00);

        // HACK: Disable busmouse IRQ for now.
        disable(5);

        Terminal.print("PIC(i8259): cascading mode, vectors 0x{b:}-0x{b:}\r\n", .{ cpu.IRQ_VECTOR_BASE, cpu.IRQ_VECTOR_BASE + 0x08 });
    }
};
