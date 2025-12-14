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

black := types.color (0, 0, 0)
white := types.color (255, 255, 255)
red := types.color (255, 0, 0)
green := types.color (0, 255, 0)
blue := types.color (0, 0, 255)