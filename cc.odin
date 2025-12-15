// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

package cc

import "core:fmt"
import "base:runtime"
import "core:strings"
import sapp "shared:sokol/app"
import sg "shared:sokol/gfx"
import sgl "shared:sokol/gl"
import sglue "shared:sokol/glue"
import slog "shared:sokol/log"
import sdtx "shared:sokol/debugtext"
import colors "./colors"
import types "./types"

Vector2 :: #type types.Vector2
Vector3 :: #type types.Vector3

Color :: #type types.Color
ColorU8 :: #type types.ColorU8

u8_color :: colors.u8_color
f32_color :: colors.f32_color
default_color :: types.default_color
default_color_u8 :: types.default_color_u8

TextCfg :: #type types.TextCfg
default_textcfg :: types.default_textcfg

Event :: #type sapp.Event
Keycode :: #type sapp.Keycode
Mousebutton :: #type sapp.Mousebutton

Modifiers :: u32 // bit_set[Modifier]

Modifier :: enum u16 {
    SHIFT = 1,
    CTRL = 2,
    ALT = 4,
    SUPER = 8,
    LMB = 256,
    RMB = 512,
    MMB = 1024
}

FnCb_WithPtr :: #type proc(rawptr)
FnCb_WithNoPtr :: #type proc()
FnCb :: union { FnCb_WithPtr, FnCb_WithNoPtr}
FnEvent_WithPtr :: #type proc(^sapp.Event, rawptr)
FnEvent_WithNoPtr :: #type proc(^sapp.Event)
FnEvent :: union { FnEvent_WithPtr, FnEvent_WithNoPtr}
FnKeyDown_WithPtr :: #type proc(sapp.Keycode, Modifiers, rawptr)
FnKeyDown_WithNoPtr :: #type proc(sapp.Keycode, Modifiers)
FnKeyDown :: union { FnKeyDown_WithPtr, FnKeyDown_WithNoPtr }
FnKeyUp_WithPtr :: #type proc(sapp.Keycode, Modifiers, rawptr)
FnKeyUp_WithNoPtr :: #type proc(sapp.Keycode, Modifiers)
FnKeyUp :: union { FnKeyUp_WithPtr, FnKeyUp_WithNoPtr }
FnClick_WithPtr  :: #type proc(f32, f32, sapp.Mousebutton, rawptr)
FnClick_WithNoPtr  :: #type proc(f32, f32, sapp.Mousebutton)
FnClick :: union { FnClick_WithPtr, FnClick_WithNoPtr }
FnUnClick_WithPtr :: #type proc(f32, f32, sapp.Mousebutton, rawptr)
FnUnClick_WithNoPtr :: #type proc(f32, f32, sapp.Mousebutton)
FnUnClick :: union { FnUnClick_WithPtr, FnUnClick_WithNoPtr }
FnMove_WithPtr :: #type proc(f32, f32, rawptr)
FnMove_WithNoPtr :: #type proc(f32, f32)
FnMove :: union { FnMove_WithPtr, FnMove_WithNoPtr }

DrawFn :: #type FnCb

CCConfig :: struct  {
	init_fn:      Maybe(FnCb),
	update_fn:    Maybe(FnCb),
	draw_fn:      Maybe(FnCb),
	cleanup_fn:   Maybe(FnCb),
	event_fn:     Maybe(FnEvent),
	keydown_fn:   Maybe(FnKeyDown),
	keyup_fn:     Maybe(FnKeyUp),
	click_fn:     Maybe(FnClick),
	unclick_fn:   Maybe(FnUnClick),
	move_fn:      Maybe(FnMove),
	user_data:    rawptr
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
        text_config =       default_textcfg(),
        fill = true,
        circle_resolution = 32,
        sphere_resolution = 32,
        curve_resolution = 32
    }
}

CCPipelines :: struct {
	alpha: sgl.Pipeline,
	add:   sgl.Pipeline
}

CC :: struct {
    config:         CCConfig,
	state:          ^CCState,
	current_style:  CCStyle,
	style_history:  Stack(CCStyle, cc_max_style_history),
	pipelines: CCPipelines,
	// fullscreen:     bool,
	// image_cache:    [dynamic]Image,
	img_count : int,
	window_title_cstr: cstring,
	width : int,
	height : int,
	mouse_x : f32,
	mouse_y : f32,
	mouse_dx : f32,
	mouse_dy : f32,
	scroll_x : f32,
	scroll_y : f32,
	last_modifiers:   Modifiers,
	prev_modifiers:   Modifiers,
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
	init_fn:      Maybe(FnCb),
	cleanup_fn:   Maybe(FnCb),
	event_fn:     Maybe(FnEvent),
	keydown_fn:   Maybe(FnKeyDown),
	keyup_fn:     Maybe(FnKeyUp),
	click_fn:     Maybe(FnClick),
	unclick_fn:   Maybe(FnUnClick),
	move_fn:      Maybe(FnMove),
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

CCState :: struct {
    pass_action: sg.Pass_Action,
    tex_view: sg.View,
    smp: sg.Sampler,
    pip_3d: sgl.Pipeline,
}

@(private)
state := CCState {
    pass_action = {
        colors = { 0 = { load_action = .CLEAR, clear_value = { 0.0, 0.0, 0.0, 1.0 } } },
    },
}

@(private)
init_pipeline :: proc() {
	ctx := get_context()
	
	// Alpha
	alpha_pipdesc := sg.Pipeline_Desc{}
	alpha_pipdesc.label = "alpha-pipeline"
	alpha_pipdesc.colors[0] = sg.Color_Target_State{
		blend = sg.Blend_State{
			enabled =        true,
			src_factor_rgb = .SRC_ALPHA,
			dst_factor_rgb = .ONE_MINUS_SRC_ALPHA,
		}
	}
	ctx.cc.pipelines.alpha = sgl.make_pipeline(alpha_pipdesc)

	// Add
	add_pipdesc := sg.Pipeline_Desc{}
	add_pipdesc.label = "add-pipeline"
	add_pipdesc.colors[0] = sg.Color_Target_State{
		blend = sg.Blend_State{
			enabled =        true,
			src_factor_rgb = .SRC_ALPHA,
			dst_factor_rgb = .ONE,
		}
	}
	ctx.cc.pipelines.add = sgl.make_pipeline(add_pipdesc)
}

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

	text_setup()

	apply_style()

	ctx := get_context()
	if ctx.pref.fullscreen {
		fullscreen()
	}

	if c.config.init_fn != nil {
		fn := c.config.init_fn.(FnCb)
		switch _ in fn {
		case FnCb_WithPtr:
			fn.(FnCb_WithPtr)(c.config.user_data)
		case FnCb_WithNoPtr:
			fn.(FnCb_WithNoPtr)()
		}
	}
}

@(private)
begin :: proc () {
    dw := sapp.width()
    dh := sapp.height()
	// sgl.viewport(0, 0, dw, dh, true)
	sgl.defaults()
	sgl.matrix_mode_projection()
	sgl.ortho(0.0, f32(dw), f32(dh), 0.0, -1.0, 1.0)
}

@(private)
end :: proc () {
	sg.begin_pass({ action = state.pass_action, swapchain = sglue.swapchain() })
	sgl.draw() // FIXME: position/layer
	sdtx.draw() // FIXME: position/layer
    sg.end_pass()
    sg.commit()
}

@(private)
prev_width : int
@(private)
prev_height : int

@(private)
frame :: proc "c" (_: rawptr) {
	context = runtime.default_context()

	// TODO: resized_fn callback
	if c.width != prev_width || c.height != prev_height {
		// TODO: resize window
	}

	prev_width = c.width
	prev_height = c.height

	if c.config.update_fn != nil {
		fn := c.config.update_fn.(FnCb)
		switch _ in fn {
		case FnCb_WithPtr:
			fn.(FnCb_WithPtr)(c.config.user_data)
		case FnCb_WithNoPtr:
			fn.(FnCb_WithNoPtr)()
		}
	}

	text_init_frame()

	begin()
	push_matrix()
	push_style()

	// sgl.defaults()

	if c.config.draw_fn != nil {
		fn := c.config.draw_fn.(FnCb)
		switch _ in fn {
		case FnCb_WithPtr:
			fn.(FnCb_WithPtr)(c.config.user_data)
		case FnCb_WithNoPtr:
			fn.(FnCb_WithNoPtr)()
		}
	}

	pop_style()
	pop_matrix()
	end()

	update_prev_key()

	free_all(context.temp_allocator)
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
		c.last_modifiers = e.modifiers
	}

	if e.type == .MOUSE_DOWN || e.type == .MOUSE_UP {
		c.last_mousebutton = e.mouse_button
	}
}

@(private)
_on_event :: proc "c" (event: ^sapp.Event, _: rawptr) {
	context = runtime.default_context()

	if event == nil {
		return
	}

	user_data := c.config.user_data
	prev_mousedown : bool = c.last_mousedown
	prev_keydown : bool = c.last_keydown
	prev_mousebtn := c.last_mousebutton
	prev_keycode := c.last_keycode
	prev_modifiers := c.last_modifiers

	if c.config.event_fn != nil {
		fn := c.config.event_fn.(FnEvent)
		switch _ in fn {
		case FnEvent_WithPtr:
			fn.(FnEvent_WithPtr)(event, c.config.user_data)
		case FnEvent_WithNoPtr:
			fn.(FnEvent_WithNoPtr)(event)
		}
	}

	if event.type == .MOUSE_DOWN && (!prev_mousedown || prev_mousebtn != event.mouse_button) {
		if c.config.click_fn != nil {
			x := event.mouse_x
			y := event.mouse_y
			btn := event.mouse_button

			fn := c.config.click_fn.(FnClick)
			switch _ in fn {
			case FnClick_WithPtr:
				fn.(FnClick_WithPtr)(x, y, btn, c.config.user_data)
			case FnClick_WithNoPtr:
				fn.(FnClick_WithNoPtr)(x, y, btn)
			}
		}
	}

	if event.type == .MOUSE_UP && (prev_mousedown || prev_mousebtn != event.mouse_button) {
		if c.config.unclick_fn != nil {
			x := event.mouse_x
			y := event.mouse_y
			btn := event.mouse_button

			fn := c.config.unclick_fn.(FnUnClick)
			switch _ in fn {
			case FnUnClick_WithPtr:
				fn.(FnUnClick_WithPtr)(x, y, btn, c.config.user_data)
			case FnUnClick_WithNoPtr:
				fn.(FnUnClick_WithNoPtr)(x, y, btn)
			}
		}
	}

	if event.type == .MOUSE_SCROLL {
		c.scroll_x = event.scroll_x
		c.scroll_y = event.scroll_y
	}else{
		c.scroll_x = 0 // WORKAROUND
		c.scroll_y = 0 // WORKAROUND
	}

	if event.type == .MOUSE_MOVE {
		c.mouse_x = event.mouse_x
		c.mouse_y = event.mouse_y
		c.mouse_dx = event.mouse_dx
		c.mouse_dy = event.mouse_dy

		if c.config.move_fn != nil {
			x := event.mouse_x
			y := event.mouse_y

			fn := c.config.move_fn.(FnMove)
			switch _ in fn {
			case FnMove_WithPtr:
				fn.(FnMove_WithPtr)(x, y, c.config.user_data)
			case FnMove_WithNoPtr:
				fn.(FnMove_WithNoPtr)(x, y)
			}
		}
	}else{
		c.mouse_dx = 0 // WORKAROUND
		c.mouse_dy = 0 // WORKAROUND
	}

	if event.type == .KEY_DOWN && (!prev_keydown || prev_keycode != event.key_code || prev_modifiers != event.modifiers) {
		if c.config.keydown_fn != nil {
			modifiers := event.modifiers
			keycode := event.key_code

			fn := c.config.keydown_fn.(FnKeyDown)
			switch _ in fn {
			case FnKeyDown_WithPtr:
				fn.(FnKeyDown_WithPtr)(keycode, modifiers, c.config.user_data)
			case FnKeyDown_WithNoPtr:
				fn.(FnKeyDown_WithNoPtr)(keycode, modifiers)
			}
		}
	}

	if event.type == .KEY_UP && (prev_keydown || prev_keycode != event.key_code || prev_modifiers != event.modifiers) {
		if c.config.keyup_fn != nil {
			modifiers := event.modifiers
			keycode := event.key_code

			fn := c.config.keyup_fn.(FnKeyUp)
			switch _ in fn {
			case FnKeyUp_WithPtr:
				fn.(FnKeyUp_WithPtr)(keycode, modifiers, c.config.user_data)
			case FnKeyUp_WithNoPtr:
				fn.(FnKeyUp_WithNoPtr)(keycode, modifiers)
			}
		}
	}

	update_last_key(event)
}

data :: proc ($T: typeid) -> ^T {
	ctx := get_context()
	if ctx.cc == nil {
		return nil
	} else {
		return config_get_data()
	}
}

@(private)
config_get_data :: proc ($T: typeid) -> ^T {
	return (^T)(c.config.user_data)
}

set_data :: proc (dat: rawptr) {
	ctx := get_context()
	if ctx.cc == nil {
		ctx.pref.user_data = dat
	}else{
		config_set_data(dat)
	}
}

@(private)
config_set_data :: proc (user_data_ptr: rawptr) {
	c.config.user_data = user_data_ptr
}

// set_data_new[T]() {
// 	mut ctx := context()
// 	mut dat := &T{}
// 	if unsafe { ctx.cc == nil } {
// 		ctx.pref.user_data = dat
// 	}else{
// 		ctx.cc.set_data(dat)
// 	}
// }

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
		fn := c.config.cleanup_fn.(FnCb)
		switch _ in fn {
		case FnCb_WithPtr:
			fn.(FnCb_WithPtr)(c.config.user_data)
		case FnCb_WithNoPtr:
			fn.(FnCb_WithNoPtr)()
		}
	}
}

@(private)
setup :: proc (config: CCConfig) {
    ctx := ctx()

	w := 400
	h := 400
	bg_color := colors.white

    c = CC {
		config = config,
		current_style = default_style(),
		state = &state
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
		c.config.init_fn = ctx.pref.init_fn.(FnCb)
	}

    if c.config.cleanup_fn == nil && ctx.pref.cleanup_fn != nil {
		c.config.cleanup_fn = ctx.pref.cleanup_fn.(FnCb)
	}

    if c.config.event_fn == nil && ctx.pref.event_fn != nil {
		c.config.event_fn = ctx.pref.event_fn.(FnEvent)
	}

    if c.config.keydown_fn == nil && ctx.pref.keydown_fn != nil {
		c.config.keydown_fn = ctx.pref.keydown_fn.(FnKeyDown)
	}

    if c.config.keyup_fn == nil && ctx.pref.keyup_fn != nil {
		c.config.keyup_fn = ctx.pref.keyup_fn.(FnKeyUp)
	}

    if c.config.click_fn == nil && ctx.pref.click_fn != nil {
		c.config.click_fn = ctx.pref.click_fn.(FnClick)
	}

    if c.config.unclick_fn == nil && ctx.pref.unclick_fn != nil {
		c.config.unclick_fn = ctx.pref.unclick_fn.(FnUnClick)
	}

    if c.config.move_fn == nil && ctx.pref.move_fn != nil {
		c.config.move_fn = ctx.pref.move_fn.(FnMove)
	}

	if ctx.pref.title == "" {
		ctx.pref.title = "Canvas"
	}

	// set bg_color
	state.pass_action.colors[0].clear_value = bg_color

	// c.fullscreen = ctx.pref.fullscreen

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

	c.window_title_cstr = strings.clone_to_cstring(ctx.pref.title)

	prev_width = w
	prev_height = h
	c.width = w
	c.height = h

    ctx.cc = &c
    // c.gg.run()


	sapp.run({
		width =               i32(w),
		height =              i32(h),
		init_userdata_cb =    init,
		frame_userdata_cb =   frame,
		event_userdata_cb =   _on_event,
		cleanup_userdata_cb = cleanup,
		window_title =        c.window_title_cstr,
	})
}

on_init :: proc(init_fn: FnCb) {
    ctx := get_context()
    ctx.pref.init_fn = init_fn
}

on_event :: proc(event_fn: FnEvent) {
    ctx := get_context()
    ctx.pref.event_fn = event_fn
}

on_exit :: proc(exit_fn: FnCb) {
    ctx := get_context()
    ctx.pref.cleanup_fn = exit_fn
}

on_key_pressed :: proc(keydown_fn: FnKeyDown) {
    ctx := get_context()
    ctx.pref.keydown_fn = keydown_fn
}

on_key_released :: proc(keyup_fn: FnKeyUp) {
    ctx := get_context()
    ctx.pref.keyup_fn = keyup_fn
}

on_mouse_pressed :: proc(click_fn: FnClick) {
    ctx := get_context()
    ctx.pref.click_fn = click_fn
}

on_mouse_released :: proc(unclick_fn: FnUnClick) {
    ctx := get_context()
    ctx.pref.unclick_fn = unclick_fn
}

on_mouse_moved :: proc(move_fn: FnMove) {
    ctx := get_context()
    ctx.pref.move_fn = move_fn
}

run_with_data :: proc (draw_fn: DrawFn, user_data: rawptr) {
	setup({
		draw_fn = draw_fn,
		user_data = rawptr(user_data)
	})
}

run :: proc (draw_fn: DrawFn) {
	setup({
		draw_fn = draw_fn
    })
}

// TODO?: run_app, run_app_new / maybe unneeded because of Odin's syntax and philosophy