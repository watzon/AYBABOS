// Copyright (c) 2020 Chris Watson
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

// Hardware text mode color constants.
pub const Color = packed enum(u8) {
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
    Red = 4,
    Magenta = 5,
    Brown = 6,
    LightGrey = 7,
    DarkGrey = 8,
    LightBlue = 9,
    LightGreen = 10,
    LightCyan = 11,
    LightRed = 12,
    LightMagenta = 13,
    LightBrown = 14,
    White = 15,
};

pub inline fn entryColor(fg: Color, bg: Color) u8 {
    return @enumToInt(fg) | (@enumToInt(bg) << 4);
}

pub inline fn entry(uc: u8, c: u8) u16 {
    return @as(u16, uc) | @as(u16, c) << 8;
}
