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
    sdtx.canvas(sapp.widthf(), sapp.heightf())
    // sdtx.origin(0.0, 0.0)
}

draw_text :: proc (x: f32, y: f32, msg: string, cfg: types.TextCfg) {
    sdtx.font(0) // WORKAROUND

    // TODO: set font size

    cu := colors.u8_color(cfg.color)
    sdtx.color4b(
        cu.r,
        cu.g,
        cu.b,
        cu.a)

    sdtx.pos(x / 8.0, y / 8.0) // WORKAROUND
    sdtx.printf(msg)

    // fmt.println("color:", cfg.color)
}