// Copyright (c) 2020 Chris Watson
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

const kernel = @import("../kernel.zig");
const vga = kernel.drivers.graphics.vga;

pub const VGA_WIDTH = 80;
pub const VGA_HEIGHT = 25;
pub const VGA_SIZE = VGA_WIDTH * VGA_HEIGHT;

// State
var row: usize = 0;
var col: usize = 0;
var color: u8 = vga.entryColor(.LightGrey, .Black);
var buffer = @intToPtr([*]volatile u16, 0xB8000);

pub fn reset() void {
    row = 0;
    col = 0;
    var y: usize = 0;
    while (y < VGA_HEIGHT) : (y += 1) {
        var x: usize = 0;
        while (x < VGA_WIDTH) : (x += 1) {
            putCharAt(' ', color, x, y);
        }
    }
}

pub fn setColor(newColor: u8) void {
    color = newColor;
}

pub fn putCharAt(c: u8, newColor: u8, x: usize, y: usize) void {
    const index = y * VGA_WIDTH + x;
    buffer[index] = vga.entry(c, newColor);
}

pub fn putChar(c: u8) void {
    switch (c) {
        '\n' => {
            row += 1;
            return;
        },
        else => {
            putCharAt(c, color, col, row);
            col += 1;
        },
    }

    if (col == VGA_WIDTH) {
        col = 0;
        row += 1;
    }

    if (row == VGA_HEIGHT) {
        row = 0;
    }
}

pub fn write(data: []const u8) void {
    for (data) |c| putChar(c);
}

pub fn writeByte(byte: u8) void {
    putChar(byte);
}
