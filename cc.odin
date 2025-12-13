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

Vector2 :: #type types.Vector2
Vector3 :: #type types.Vector3
Color :: #type types.Color

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
FNEvent :: #type proc(^sapp.Event, rawptr)
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
	color: Color
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
	style_history:  Stack(CCStyle, cc_max_style_history),
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
	cc:  ^CC,
	pref: InitialPreference
}

@(private)
g_ctx := CCContext{}

@(private)
c : CC

@(private)
init :: proc "c" (_: rawptr) {
	context = runtime.default_context()

	sg.setup({
        environment = sglue.environment(),
        logger = { func = slog.func },
    })
    sgl.setup({
        logger = { func = slog.func },
    })

	apply_style()

	if c.config.init_fn != nil {
		c.config.init_fn.(FNCb)(c.config.user_data)
	}
}

@(private)
frame :: proc "c" (_: rawptr) {
	context = runtime.default_context()

	if c.config.update_fn != nil {
		c.config.update_fn.(FNCb)(c.config.user_data)
	}

	// c.gg.begin()
	push_matrix()
	push_style()
	if c.config.draw_fn != nil {
		c.config.draw_fn.(FNCb)(c.config.user_data)
	}
	pop_style()
	pop_matrix()
	// c.gg.end()

	update_prev_key()
}

@(private)
update_prev_key :: proc() {
	c.prev_keycode = c.last_keycode
	c.prev_keydown = c.last_keydown
	c.prev_mousebutton = c.last_mousebutton
	c.prev_mousedown = c.last_mousedown
}

@(private)
update_last_key :: proc (e: ^sapp.Event) {
	if e.type == .KEY_DOWN {
		c.last_keydown = true
	}
	if e.type == .KEY_UP {
		c.last_keydown = false
	}

	if e.type == .MOUSE_DOWN {
		c.last_mousedown = true
	}
	if e.type == .MOUSE_UP {
		c.last_mousedown = false
	}

	if e.type == .KEY_DOWN || e.type == .KEY_UP {
		c.last_keycode = e.key_code
	}

	if e.type == .MOUSE_DOWN || e.type == .MOUSE_UP {
		c.last_mousebutton = e.mouse_button
	}
}

@(private)
on_event :: proc "c" (event: ^sapp.Event, _: rawptr) {
	context = runtime.default_context()

	if event == nil {
		return
	}

	update_last_key(event)

	if c.config.event_fn != nil {
		c.config.event_fn.(FNEvent)(event, c.config.user_data)
	}

	if event.type == .MOUSE_DOWN {

	}
}

@(private)
get_context:: proc() -> ^CCContext {
    return &g_ctx
}

// alias of get_context()
@(private)
ctx :: proc() -> ^CCContext {
    return get_context()
}

@(private)
cleanup :: proc "c" (_: rawptr) {
	context = runtime.default_context()

	if c.config.cleanup_fn != nil {
		c.config.cleanup_fn.(FNCb)(c.config.user_data)
	}
}

@(private)
setup :: proc (config: CCConfig) {
    ctx := ctx()

	w := 400
	h := 400
	bg_color := colors.white

    c = CC {
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
		bg_color = ctx.pref.bg_color.(Color)
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

    ctx.cc = &c
    // c.gg.run()

	sapp.run({
		width =               i32(w),
		height =              i32(h),
		init_userdata_cb =    init,
		frame_userdata_cb =   frame,
		event_userdata_cb =   on_event,
		cleanup_userdata_cb = cleanup,
		window_title =        "Sokol Drawing Template",
	})
}

run :: proc (draw_fn: DrawFn) {
	setup({
		draw_fn = draw_fn
    })
}
