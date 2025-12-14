// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

package cc

import "core:strings"
import "core:log"
import sapp "shared:sokol/app"
import types "./types"

width :: proc() -> int {
	ctx := get_context()
	if ctx.cc != nil {
        return int(sapp.widthf())
	}else{
        if ctx.pref.size != nil {
		    return ctx.pref.size.(types.Vector2(int)).x
        } else {
            return 0
        }
	}
}

height :: proc() -> int {
	ctx := get_context()
	if ctx.cc != nil {
        return int(sapp.heightf())
	}else{
        if ctx.pref.size != nil {
		    return ctx.pref.size.(types.Vector2(int)).y
        } else {
            return 0
        }
	}
}

title :: proc(str: string) {
	ctx := get_context()
	if ctx.cc != nil {
        delete(ctx.cc.window_title_cstr)
        ctx.cc.window_title_cstr = strings.clone_to_cstring(str)
        sapp.set_window_title(ctx.cc.window_title_cstr)
	}else{
        ctx.pref.title = str
	}
}

size :: proc(w: int, h: int) {
	ctx := get_context()
	if ctx.cc != nil {
        log.warn("cc: currently dynamically change window size is not possible")
	}else{
        ctx.pref.size = Vector2(int){w, h}
	}
}

quit :: proc() {
	sapp.request_quit() // does not require ctx right now, but sokol multi-window might in the future
}

mouse_x :: proc() -> f32 {
	ctx := get_context()
	if ctx.cc != nil {
        return ctx.cc.mouse_x
	}else{
        return 0 // WORKAROUND
	}
}

mouse_y :: proc() -> f32 {
	ctx := get_context()
	if ctx.cc != nil {
        return ctx.cc.mouse_y
	}else{
        return 0 // WORKAROUND
	}
}

mouse_dx :: proc() -> f32 {
	ctx := get_context()
	if ctx.cc != nil {
        return ctx.cc.mouse_dx
	}else{
        return 0 // WORKAROUND
	}
}

mouse_dy :: proc() -> f32 {
	ctx := get_context()
	if ctx.cc != nil {
        return ctx.cc.mouse_dy
	}else{
        return 0 // WORKAROUND
	}
}

scroll_x :: proc() -> f32 {
	ctx := get_context()
	if ctx.cc != nil {
        return ctx.cc.scroll_x
	}else{
        return 0 // WORKAROUND
	}
}

scroll_y :: proc() -> f32 {
	ctx := get_context()
	if ctx.cc != nil {
        return ctx.cc.scroll_y
	}else{
        return 0 // WORKAROUND
	}
}

// TODO: mouse_buttons()

mouse_button :: proc() -> sapp.Mousebutton {
	ctx := get_context()
	if ctx.cc != nil {
        return ctx.cc.last_mousebutton
	}else{
        return .INVALID // WORKAROUND
	}
}

mouse_pressed :: proc() -> bool {
	ctx := get_context()
	if ctx.cc != nil {
        return ctx.cc.last_mousedown
	}else{
        return false // WORKAROUND
	}
}

mouse_released :: proc() -> bool {
	ctx := get_context()
	if ctx.cc != nil {
        return !ctx.cc.last_mousedown
	}else{
        return true // WORKAROUND
	}
}

mouse_just_pressed :: proc(mouse_button: sapp.Mousebutton) -> bool {
	ctx := get_context()
	if ctx.cc != nil {
        c := ctx.cc
		return c.last_mousedown && c.last_mousebutton == mouse_button \
			&& (c.prev_mousebutton != c.last_mousebutton || c.prev_mousedown != c.last_mousedown)
	}else{
        return false // WORKAROUND
	}
}

mouse_just_released :: proc(mouse_button: sapp.Mousebutton) -> bool {
	ctx := get_context()
	if ctx.cc != nil {
        c := ctx.cc
		return !c.last_mousedown && c.last_mousebutton == mouse_button \
			&& (c.prev_mousebutton != c.last_mousebutton || c.prev_mousedown != c.last_mousedown)
	}else{
        return false // WORKAROUND
	}
}

key :: proc() -> sapp.Keycode {
	ctx := get_context()
	if ctx.cc != nil {
        return ctx.cc.last_keycode
	}else{
        return .INVALID // WORKAROUND
	}
}

key_pressed :: proc() -> bool {
	ctx := get_context()
	if ctx.cc != nil {
        return ctx.cc.last_keydown
	}else{
        return false // WORKAROUND
	}
}

key_released :: proc() -> bool {
	ctx := get_context()
	if ctx.cc != nil {
        return !ctx.cc.last_keydown
	}else{
        return true // WORKAROUND
	}
}

key_just_pressed :: proc(keycode: sapp.Keycode) -> bool {
	ctx := get_context()
	if ctx.cc != nil {
		c := ctx.cc
		return c.last_keydown && c.last_keycode == keycode \
			&& (c.prev_keycode != c.last_keycode || c.prev_keydown != c.last_keydown)
	}else{
        return false // WORKAROUND
	}
}

key_just_released :: proc(keycode: sapp.Keycode) -> bool {
	ctx := get_context()
	if ctx.cc != nil {
		c := ctx.cc
		return !c.last_keydown && c.last_keycode == keycode \
			&& (c.prev_keycode != c.last_keycode || c.prev_keydown != c.last_keydown)
	}else{
        return false // WORKAROUND
	}
}

// TODO: fullscreen functions

// pub fn is_fullscreen() bool {
// 	return gg.is_fullscreen()
// }

// pub fn toggle_fullscreen() {
// 	gg.toggle_fullscreen()
// }

// pub fn fullscreen() {
// 	mut ctx := context()
// 	if unsafe { ctx.cc != nil } {
// 		gg.toggle_fullscreen()
// 	}else{
// 		ctx.pref.fullscreen = true
// 	}
// }


// TODO: screnn size functions

// pub fn screen_width() int {
// 	return gg.screen_size().width
// }

// pub fn screen_height() int {
// 	return gg.screen_size().height
// }