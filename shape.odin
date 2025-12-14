// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

package cc

import sd "./shape_drawer"

line :: proc (x1: f32, y1: f32, x2: f32, y2: f32) {
	ctx := get_context()
	if ctx.cc != nil {
        col := ctx.cc.current_style.color
        sd.draw_line(x1, y1, x2, y2, col)
    }
}

rect :: proc (x: f32, y: f32, w: f32, h: f32) {
	ctx := get_context()
	if ctx.cc != nil {
		col := ctx.cc.current_style.color
		if ctx.cc.current_style.fill {
			sd.draw_rect_filled(x, y, w, h, col)
		} else {
			sd.draw_rect_empty(x, y, w, h, col)
		}
	}
}

square :: proc (x: f32, y: f32, s: f32) {
    w := s
    h := s
    rect(x, y, s, s)
}

circle :: proc (x: f32, y: f32, radius: f32) {
	ctx := get_context()
	if ctx.cc != nil {
		col := ctx.cc.current_style.color
		segments := ctx.cc.current_style.circle_resolution
		if ctx.cc.current_style.fill {
			sd.draw_circle_filled(x, y, radius, col, segments)
		} else {
			sd.draw_circle_empty(x, y, radius, col, segments)
		}
	}
}