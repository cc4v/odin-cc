package cc

import text "./text"
import types "./types"

@(private)
text_setup :: proc() {
    text.setup()  
}

@(private)
text_init_frame :: proc() {
    text.init_frame() 
}

text_size :: proc (size: int) {
	ctx := get_context()
	if ctx.cc != nil {
		ctx.cc.current_style.text_config.size = size
		// ctx.cc.apply_style()
	}
}

text :: proc (msg: string, x: f32, y: f32) {
	ctx := get_context()
	if ctx.cc != nil {
		draw_text(msg, x, y, ctx.cc.current_style.text_config)
	}
}

@(private)
draw_text :: proc (msg: string, x: f32, y: f32, cfg: types.TextCfg) {
	ctx := get_context()
	if ctx.cc != nil {
		text.draw_text(x, y, msg, cfg)
	}
}