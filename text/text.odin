// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

package text

import types "../types"
import colors "../colors"

import "core:strings"
import "core:fmt"

import slog "shared:sokol/log"
import sapp "shared:sokol/app"
import sdtx "shared:sokol/debugtext"

// FONT_KC854 :: 0
// FONT_C64   :: 1
// FONT_ORIC  :: 2
// NUM_FONTS  :: 3

setup :: proc() {
    sdtx.setup({
        fonts = {
            0 = sdtx.font_oric()
            // FONT_KC854 = sdtx.font_kc854(),
            // FONT_C64 = sdtx.font_c64(),
            // FONT_ORIC = sdtx.font_oric(),
        },
        logger = { func = slog.func },
    })
}

init_frame :: proc() {
    // sdtx.canvas(sapp.widthf(), sapp.heightf())
    // sdtx.origin(0.0, 0.0)
}

draw_text :: proc (x: f32, y: f32, msg: string, cfg: types.TextCfg) {
    sdtx.font(0) // WORKAROUND

    font_size := f32(cfg.size)

    // set font size
    // NOTE: default font size of debugtext = 8 x 8

    sdtx.canvas(sapp.widthf() / (font_size / 8), sapp.heightf() / (font_size / 8))
    sdtx.origin(0.0, 0.0)

    cu := colors.u8_color(cfg.color)
    sdtx.color4b(
        cu.r,
        cu.g,
        cu.b,
        cu.a)

    sdtx.pos(x / font_size, y / font_size)
    sdtx.printf(msg)

    // fmt.println("color:", cfg.color)
}