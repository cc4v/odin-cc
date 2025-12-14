// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

package types

import sg "shared:sokol/gfx"

ColorU8 :: struct {
	r: u8,
    g: u8,
    b: u8,
    a: u8
}

Color :: #type sg.Color

default_color :: proc() -> Color {
    return Color {
        a = 1.0
    }
}

default_color_u8 :: proc() -> ColorU8 {
    return ColorU8 {
        a = u8(255)
    }
}

color :: proc "contextless" (r: u8, g: u8, b: u8, a :u8 = 255) -> Color {
    return Color {
        r = f32(r) / 255,
        g = f32(g) / 255,
        b = f32(b) / 255,
        a = f32(a) / 255
    }
}