package types

import sg "shared:sokol/gfx"

// Color :: struct {
// 	r: u8,
//     g: u8,
//     b: u8,
//     a: u8
// }

Color :: #type sg.Color

color :: proc "contextless" (r: u8, g: u8, b: u8, a :u8 = 255) -> Color {
    return Color {
        r = f32(r) / 255,
        g = f32(g) / 255,
        b = f32(b) / 255,
        a = f32(a) / 255
    }
}