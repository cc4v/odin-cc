// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

// Reference:
// https://github.com/openframeworks/openFrameworks/blob/996f7880bc250254480561a2f2dab3554a830084/libs/openFrameworks/gl/ofGLProgrammableRenderer.cpp

package cc

import sg "shared:sokol/gfx"
import sgl "shared:sokol/gl"
// import slog "shared:sokol/log"
import "core:log"

cc_max_style_history :: 32

push_matrix :: proc() {
	sgl.push_matrix()
}

pop_matrix :: proc() {
	sgl.pop_matrix()
}

@(private)
apply_style :: proc() {
	style := &c.current_style
    style.text_config.color = style.color
}

@(private)
set_style :: proc (style: CCStyle) {
	c.current_style = style
	apply_style()
}

push_style :: proc () {
	sgl.push_pipeline()

    ctx := get_context()
	if ctx.cc != nil {
		err0 := stack_push(&ctx.cc.style_history, ctx.cc.current_style)
        if err0 == true {
            log.warn("cc: push_style() maximum number of style pushes ${cc_max_style_history} reached, did you forget to pop somewhere?")
        }
	}
}

pop_style :: proc () {
	sgl.pop_pipeline()

    ctx := get_context()
	if ctx.cc != nil {
		if stack_size(ctx.cc.style_history) > 0 {
            style, err := stack_pop(&ctx.cc.style_history)
            if err != false {
                log.error("cc: failed to pop_style")
            }else{
			    set_style(style.(CCStyle))
            }
		}
	}
}