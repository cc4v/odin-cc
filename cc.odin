// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

package cc

import "core:fmt"
import "base:runtime"
import sapp "shared:sokol/app"
import sg "shared:sokol/gfx"
import sgl "shared:sokol/gl"
import sglue "shared:sokol/glue"
import slog "shared:sokol/log"
import colors "./colors"
import types "./types"

Color :: #type types.Color

Vector2 :: struct($T: typeid) {
	x: T,
	y: T,
}

Vector3 :: struct($T: typeid) {
	x: T,
	y: T,
    z: T
}

Modifier :: enum i32 {
    SHIFT = 1,
    CTRL = 2,
    ALT = 4,
    SUPER = 8,
    LMB = 256,
    RMB = 512,
    MMB = 1024
}

FNCb :: #type proc(rawptr)
FNEvent :: #type proc(sapp.Event, rawptr)
FNKeyDown :: #type proc(sapp.Keycode, Modifier, rawptr)
FNKeyUp :: #type proc(sapp.Keycode, Modifier, rawptr)
FNClick :: #type proc(f32, f32, sapp.Mousebutton, rawptr)
FNUnClick :: #type proc(f32, f32, sapp.Mousebutton, rawptr)
FNMove :: #type proc(f32, f32, rawptr)
DrawFn :: #type FNCb

CCConfig :: struct  {
	init_fn:      Maybe(FNCb),
	update_fn:    Maybe(FNCb),
	draw_fn:      Maybe(FNCb),
	cleanup_fn:   Maybe(FNCb),
	event_fn:     Maybe(FNEvent),
	keydown_fn:   Maybe(FNKeyDown),
	keyup_fn:     Maybe(FNKeyUp),
	click_fn:     Maybe(FNClick),
	unclick_fn:   Maybe(FNUnClick),
	move_fn:      Maybe(FNMove),
	user_data:    rawptr
}

TextCfg :: struct {

}

CCStyle :: struct {
    color:             Color, // = gg.black,
	text_config:       TextCfg,
	fill:              bool, // = true,
	circle_resolution: int,
	sphere_resolution: int, // = 32,
	curve_resolution:  int  // = 32
}

default_style :: proc() -> CCStyle {
    return {
        color =             colors.black,
        text_config =       {},
        fill = true,
        circle_resolution = 32,
        sphere_resolution = 32,
        curve_resolution = 32
    }
}

CC :: struct {
    config:         CCConfig,
	current_style:  CCStyle,
	style_history:  Stack(CCStyle),
	last_keycode:   sapp.Keycode,
	prev_keycode:   sapp.Keycode,
	last_keydown:   bool,
	prev_keydown:   bool,
	last_mousebutton:   sapp.Mousebutton,
	prev_mousebutton:   sapp.Mousebutton,
	last_mousedown: bool,
	prev_mousedown: bool,
}

InitialPreference :: struct {
    size:         Maybe(Vector2(int)),
	init_fn:      Maybe(FNCb),
	cleanup_fn:   Maybe(FNCb),
	event_fn:     Maybe(FNEvent),
	keydown_fn:   Maybe(FNKeyDown),
	keyup_fn:     Maybe(FNKeyUp),
	click_fn:     Maybe(FNClick),
	unclick_fn:   Maybe(FNUnClick),
	move_fn:      Maybe(FNMove),
	bg_color:     Maybe(Color),
	title:        string, // = "Canvas"
	fullscreen:   bool,
	user_data:    rawptr   
}

CCContext :: struct {
	cc:  CC,
	pref: InitialPreference
}

g_ctx := CCContext{}

get_context:: proc() -> ^CCContext {
    return &g_ctx
}

// alias of get_context()
ctx :: proc() -> ^CCContext {
    return get_context()
}

setup :: proc (config: CCConfig) {
    ctx := ctx()

	w := 400
	h := 400
	bg_color := colors.white

    c := CC {
		config = config
	}

    if ctx.pref.user_data != nil && c.config.user_data == nil {
		c.config.user_data = ctx.pref.user_data
	}

    if ctx.pref.size != nil {
		w = ctx.pref.size.(Vector2(int)).x
		h = ctx.pref.size.(Vector2(int)).y
	}

    if ctx.pref.bg_color != nil {
		bg_color = ctx.pref.bg_color.(types.Color)
	}

    if c.config.init_fn == nil && ctx.pref.init_fn != nil {
		c.config.init_fn = ctx.pref.init_fn.(FNCb)
	}

    if c.config.cleanup_fn == nil && ctx.pref.cleanup_fn != nil {
		c.config.cleanup_fn = ctx.pref.cleanup_fn.(FNCb)
	}

    if c.config.event_fn == nil && ctx.pref.event_fn != nil {
		c.config.event_fn = ctx.pref.event_fn.(FNEvent)
	}

    if c.config.keydown_fn == nil && ctx.pref.keydown_fn != nil {
		c.config.keydown_fn = ctx.pref.keydown_fn.(FNKeyDown)
	}

    if c.config.keyup_fn == nil && ctx.pref.keyup_fn != nil {
		c.config.keyup_fn = ctx.pref.keyup_fn.(FNKeyUp)
	}

    if c.config.click_fn == nil && ctx.pref.click_fn != nil {
		c.config.click_fn = ctx.pref.click_fn.(FNClick)
	}

    if c.config.unclick_fn == nil && ctx.pref.unclick_fn != nil {
		c.config.unclick_fn = ctx.pref.unclick_fn.(FNUnClick)
	}

    if c.config.move_fn == nil && ctx.pref.move_fn != nil {
		c.config.move_fn = ctx.pref.move_fn.(FNMove)
	}

    // c.gg = gg.new_context(
	// 	bg_color:      bg_color
	// 	width:         w
	// 	height:        h
	// 	create_window: true
	// 	window_title:  ctx.pref.title
	// 	init_fn:       c.init
	// 	frame_fn:      c.frame
	// 	cleanup_fn:    c.cleanup
	// 	event_fn:      c.on_event
	// 	click_fn:      c.on_click
	// 	unclick_fn:    c.on_unclick
	// 	keyup_fn:      c.on_keyup
	// 	keydown_fn:    c.on_keydown
	// 	move_fn:       c.on_move
	// 	user_data:     c.config.user_data
	// 	fullscreen:    ctx.pref.fullscreen
	// )

    ctx.cc = c
    // c.gg.run()

	sapp.run({
		width =             640,
		height =            480,
		// init_userdata_cb =  init,
		// frame_userdata_cb = frame,
		// cleanup_cb =        cleanup,
		window_title =      "Sokol Drawing Template",
	})
}

run :: proc (draw_fn: DrawFn) {
	setup({
		draw_fn = draw_fn
    })
}
