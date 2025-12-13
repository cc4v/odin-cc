package text

import types "../types"

import slog "shared:sokol/log"
import sapp "shared:sokol/app"
import sdtx "shared:sokol/debugtext"

FONT_KC854 :: 0
FONT_C64   :: 1
FONT_ORIC  :: 2
NUM_FONTS  :: 3

setup :: proc() {
    sdtx.setup({
        fonts = {
            FONT_KC854 = sdtx.font_kc854(),
            FONT_C64 = sdtx.font_c64(),
            FONT_ORIC = sdtx.font_oric(),
        },
        logger = { func = slog.func },
    })
}

init_frame :: proc() {
    sdtx.canvas(sapp.widthf() * 0.5, sapp.heightf() * 0.5)
    sdtx.origin(3.0, 3.0)
}