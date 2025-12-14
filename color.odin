// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

package cc

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
