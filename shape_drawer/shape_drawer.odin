// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

package shape_drawer

// import "core:fmt"
import "core:math"
import types "../types"
import colors "../colors"
import sgl "shared:sokol/gl"
import sapp "shared:sokol/app"
import util "../util"

draw_rect_filled :: proc (x: f32, y: f32, w: f32, h: f32, col: types.Color) {
    draw_quad(x, y, w, h, col)
}

draw_rect_empty :: proc (x: f32, y: f32, w: f32, h: f32, col: types.Color) {

    // TODO: line width

    // // WORKAROUND
    // // FIXME: too many draw calls?
    // draw_quad(x,     y,     w, 1, col)
    // draw_quad(x,     y,     1, h, col)
    // draw_quad(x,     y + h, w, 1, col)
    // draw_quad(x + w, y,     1, h, col)

    draw_line(x,        y,     x + w,  y,       col)
    draw_line(x,        y,     x,      y + h,   col)
    draw_line(x,        y + h, x + w,  y + h,   col)
    draw_line(x + w,    y,     x + w,  y + h,   col)
}

draw_line :: proc (x1: f32, y1: f32, x2: f32, y2: f32, col: types.Color) {
    ww := sapp.widthf()
    wh := sapp.heightf()
    
    // fmt.println("color", col)

    c := colors.u8_color(col)

    // FIXME: need optimization? SIMD or something
    px1 := util.mapf(x1, 0, ww, -1, 1)
    py1 := util.mapf(y1, 0, wh, 1, -1)
    px2 := util.mapf(x2, 0, ww, -1, 1)
    py2 := util.mapf(y2, 0, wh, 1, -1)

    // sgl.defaults()
    sgl.begin_lines()
    sgl.c4b(c.r, c.g, c.b, c.a)
    sgl.v2f(px1, py1)
    sgl.v2f(px2, py2)
    sgl.end()
}

@(private)
draw_quad :: proc (x: f32, y: f32, w: f32, h: f32, col: types.Color) {
    ww := sapp.widthf()
    wh := sapp.heightf()
    
    // fmt.println("color", col)

    c := colors.u8_color(col)

    // FIXME: need optimization? SIMD or something
    x0 := util.mapf(x, 0, ww, -1, 1)
    y0 := util.mapf(y, 0, wh, 1, -1)
    x1 := util.mapf(x + w, 0, ww, -1, 1)
    y1 := util.mapf(y + h, 0, wh, 1, -1)

    // fmt.println("x y w h", x, y, w, h)
    // fmt.println("ww, wh", ww, wh)
    // fmt.println("x0 y0 x1 y1", x0, y0, x1, x1)

    // sgl.defaults()
    sgl.begin_quads()
    sgl.c4b(c.r, c.g, c.b, c.a)
    sgl.v2f(x0, y0)
    sgl.v2f(x1, y0)
    sgl.v2f(x1, y1)
    sgl.v2f(x0, y1)
    sgl.end()
}

draw_circle_filled :: proc (x: f32, y: f32, radius: f32, col: types.Color, segments: int) {
    ww := sapp.widthf()
    wh := sapp.heightf()

    // fmt.println("color", col)

    c := colors.u8_color(col)

    x0 := util.mapf(x, 0, ww, -1, 1)
    y0 := util.mapf(y, 0, wh, 1, -1)
    rw := abs(util.mapf(radius, 0, ww, -1, 1))
    rh := abs(util.mapf(radius, 0, wh, -1, 1))

	nx := x0
	ny := y0
	theta := f32(0)
	xx := f32(0)
	yy := f32(0)

    // sgl.defaults()
    sgl.begin_triangle_strip()
    sgl.c4b(c.r, c.g, c.b, c.a)
	for i := 0; i < segments + 1; i += 1 {
		theta = f32(math.TAU) * f32(i) / f32(segments)
		xx = rw * math.cos(theta)
		yy = rh * math.sin(theta)
		sgl.v2f(xx + nx, yy + ny)
		sgl.v2f(nx, ny)
	}
	sgl.end()
}

draw_circle_empty :: proc (x: f32, y: f32, radius: f32, col: types.Color, segments: int) {
    ww := sapp.widthf()
    wh := sapp.heightf()
    c := colors.u8_color(col)

    x0 := util.mapf(x, 0, ww, -1, 1)
    y0 := util.mapf(y, 0, wh, 1, -1)
    rw := abs(util.mapf(radius, 0, ww, -1, 1))
    rh := abs(util.mapf(radius, 0, wh, -1, 1))

	nx := x0
	ny := y0
	theta := f32(0)
	xx := f32(0)
	yy := f32(0)

    // fmt.println("x0, y0", x0, y0)
    // fmt.println("rw, rh", rw, rh)

    // sgl.defaults()
	sgl.begin_line_strip()
    sgl.c4b(c.r, c.g, c.b, c.a)
	for i := 0; i < segments + 1; i += 1 {
		theta = f32(math.TAU) * f32(i) / f32(segments)
		xx = rw * math.cos(theta)
		yy = rh * math.sin(theta)
		sgl.v2f(xx + nx, yy + ny)
        // fmt.println("v2f:", xx + nx, yy + ny)
	}
	sgl.end()
}