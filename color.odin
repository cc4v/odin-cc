// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

package cc

import "core:log"
import colors "./colors"

background :: proc(c: Color) {
	ctx := get_context()
	if ctx.cc == nil {
		ctx.pref.bg_color = c
	}else{
        ctx.cc.state.pass_action.colors[0].clear_value = c
	}
}

set_color :: proc(c: Color){
	ctx := get_context()
	if ctx.cc != nil {
		ctx.cc.current_style.color = c
		apply_style()
	}
}

set_circle_resolution :: proc(resolution: int){
	ctx := get_context()
	if ctx.cc != nil {
		ctx.cc.current_style.circle_resolution = resolution
		apply_style()
	}
}

set_curve_resolution :: proc(resolution: int){
	ctx := get_context()
	if ctx.cc != nil {
		ctx.cc.current_style.curve_resolution = resolution
		apply_style()
	}
}

set_sphere_resolution :: proc(resolution: int){
	ctx := get_context()
	if ctx.cc != nil {
		ctx.cc.current_style.sphere_resolution = resolution
		apply_style()
	}
}

get_color :: proc() -> Color {
	ctx := get_context()
	if ctx.cc != nil {
		return ctx.cc.current_style.color
	}else{
        log.warn("cc: failed to get color")
		return colors.white
	}
}

fill :: proc (){
	ctx := get_context()
	if ctx.cc != nil {
		ctx.cc.current_style.fill = true
		// ctx.cc.apply_style()
	}
}

no_fill :: proc(){
	ctx := get_context()
	if ctx.cc != nil {
		ctx.cc.current_style.fill = false
		// ctx.cc.apply_style()
	}
}