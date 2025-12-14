// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

package shape_drawer

// import "core:fmt"
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

    // WORKAROUND
    // FIXME: too many draw calls?
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
    r := c.r
    g := c.g
    b := c.b
    a := c.a

    // FIXME: need optimization? SIMD or something
    px1 := util.mapf(x1, 0, ww, -1, 1)
    py1 := util.mapf(y1, 0, wh, 1, -1)
    px2 := util.mapf(x2, 0, ww, -1, 1)
    py2 := util.mapf(y2, 0, wh, 1, -1)

    sgl.defaults()
    sgl.begin_lines()
    sgl.v2f_c4b(px1, py1, r, g, b, a)
    sgl.v2f_c4b(px2, py2, r, g, b, a)
    sgl.end()
}

@(private)
draw_quad :: proc (x: f32, y: f32, w: f32, h: f32, col: types.Color) {
    ww := sapp.widthf()
    wh := sapp.heightf()
    
    // fmt.println("color", col)

    c := colors.u8_color(col)
    r := c.r
    g := c.g
    b := c.b
    a := c.a

    // FIXME: need optimization? SIMD or something
    x0 := util.mapf(x, 0, ww, -1, 1)
    y0 := util.mapf(y, 0, wh, 1, -1)
    x1 := util.mapf(x + w, 0, ww, -1, 1)
    y1 := util.mapf(y + h, 0, wh, 1, -1)

    // fmt.println("x y w h", x, y, w, h)
    // fmt.println("ww, wh", ww, wh)
    // fmt.println("x0 y0 x1 y1", x0, y0, x1, x1)

    sgl.defaults()
    sgl.begin_quads()
    sgl.v2f_c4b(x0, y0, r, g, b, a)
    sgl.v2f_c4b(x1, y0, r, g, b, a)
    sgl.v2f_c4b(x1, y1, r, g, b, a)
    sgl.v2f_c4b(x0, y1, r, g, b, a)
    sgl.end()
}