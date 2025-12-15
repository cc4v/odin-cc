// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

package colors

import types "../types"

u8_color :: proc (c: types.Color) -> types.ColorU8 {
    _255 := f32(255.0)

    return types.ColorU8 {
        u8(c.r * _255),
        u8(c.g * _255),
        u8(c.b * _255),
        u8(c.a * _255),
    }
}

f32_color :: proc (c: types.ColorU8) -> types.Color {
    _255 := f32(255.0)

    return types.Color {
        f32(c.r) / _255,
        f32(c.g) / _255,
        f32(c.b) / _255,
        f32(c.a) / _255,
    }
}

color_u8_from_hex :: proc(hex: int) -> types.ColorU8 {
    r := u8((hex >> 16) & 0xFF)
    g := u8((hex >> 8) & 0xFF)
    b := u8((hex >> 0) & 0xFF)
    return types.ColorU8{r, g, b, 255}
}

color_from_hex :: proc(hex: int) -> types.Color {
    col_u8 := color_u8_from_hex(hex)
    return f32_color(col_u8)
}

color_from_rgb :: proc(r: u8, g: u8, b: u8) -> types.Color {
    return types.Color {
        r = f32(r) / 255.0,
        g = f32(g) / 255.0,
        b = f32(b) / 255.0,
    }
}

color_from_rgba :: proc(r: u8, g: u8, b: u8, a: u8) -> types.Color {
    return types.Color {
        r = f32(r) / 255.0,
        g = f32(g) / 255.0,
        b = f32(b) / 255.0,
        a = f32(a) / 255.0,
    }
}

color_u8_from_rgb :: proc(r: u8, g: u8, b: u8) -> types.ColorU8 {
    return types.ColorU8 {
        r = r,
        g = g,
        b = b,
    }
}

color_u8_from_rgba :: proc(r: u8, g: u8, b: u8, a: u8) -> types.ColorU8 {
    return types.ColorU8 {
        r = r,
        g = g,
        b = b,
        a = a,
    }
}


black := types.color(0, 0, 0)
white := types.color(255, 255, 255)
gray := types.color(128, 128, 128)
red := types.color(255, 0, 0)
green := types.color(0, 255, 0)
blue := types.color(0, 0, 255)

yellow    := types.color(255, 255, 0)
magenta   := types.color(255, 0, 255)
cyan      := types.color(0, 255, 255)
orange    := types.color(255, 165, 0)
purple    := types.color(128, 0, 128)
indigo    := types.color(75, 0, 130)
pink      := types.color(255, 192, 203)
violet    := types.color(238, 130, 238)
dark_blue := types.color(0, 0, 139)
dark_gray := types.color(169, 169, 169)
dark_green:= types.color(0, 100, 0)
dark_red  := types.color(139, 0, 0)
light_blue:= types.color(173, 216, 230)
light_gray:= types.color(211, 211, 211)
light_green:= types.color(144, 238, 144)
light_red := types.color(255, 204, 203)