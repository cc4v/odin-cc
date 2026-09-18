// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

package cc

import "core:math"
import types "./types"
import sgl "shared:sokol/gl"

Path_Point :: struct { x, y: f32 }

begin_shape :: proc() {
	ctx := get_context()
	if ctx.cc != nil { ctx.cc.path_points = nil }
}

begin_shape_kind :: proc() { begin_shape() }

vertex :: proc(x, y: f32) {
	ctx := get_context()
	if ctx.cc != nil { append(&ctx.cc.path_points, Path_Point{x, y}) }
}

move_to :: proc(x, y: f32) { vertex(x, y) }

bezier_vertex :: proc(cx1, cy1, cx2, cy2, x, y: f32) {
	ctx := get_context()
	if ctx.cc == nil || len(ctx.cc.path_points) == 0 { return }
	start := ctx.cc.path_points[len(ctx.cc.path_points)-1]
	resolution := max(ctx.cc.current_style.curve_resolution, 1)
	for step in 1..=resolution {
		t := f32(step) / f32(resolution)
		one := 1.0 - t
		vertex(one*one*one*start.x + 3*one*one*t*cx1 + 3*one*t*t*cx2 + t*t*t*x,
			one*one*one*start.y + 3*one*one*t*cy1 + 3*one*t*t*cy2 + t*t*t*y)
	}
}

quadratic_vertex :: proc(cx, cy, x, y: f32) {
	ctx := get_context()
	if ctx.cc == nil || len(ctx.cc.path_points) == 0 { return }
	start := ctx.cc.path_points[len(ctx.cc.path_points)-1]
	resolution := max(ctx.cc.current_style.curve_resolution, 1)
	for step in 1..=resolution {
		t := f32(step) / f32(resolution)
		one := 1.0 - t
		vertex(one*one*start.x + 2*one*t*cx + t*t*x, one*one*start.y + 2*one*t*cy + t*t*y)
	}
}

curve_vertex :: proc(x, y: f32) { vertex(x, y) }

bezier :: proc(x1, y1, cx1, cy1, cx2, cy2, x2, y2: f32) {
	begin_shape(); move_to(x1, y1); bezier_vertex(cx1, cy1, cx2, cy2, x2, y2); end_shape(false)
}

curve :: proc(x1, y1, x2, y2, x3, y3, x4, y4: f32) {
	begin_shape(); move_to(x1, y1); bezier_vertex(x2, y2, x3, y3, x4, y4); end_shape(false)
}

begin_contour :: proc() {}
end_contour :: proc() {}

triangle :: proc(x1, y1, x2, y2, x3, y3: f32) {
	begin_shape(); move_to(x1, y1); vertex(x2, y2); vertex(x3, y3); end_shape(true)
}

arc :: proc(x, y, width, height, start, stop: f32) {
	ctx := get_context()
	resolution := 32
	if ctx.cc != nil { resolution = max(ctx.cc.current_style.circle_resolution, 3) }
	begin_shape(); move_to(x, y)
	steps := max(i32(math.ceil(math.abs(stop-start) / (2*math.PI) * f32(resolution))), 2)
	for i in 0..=steps {
		t := f32(i) / f32(steps)
		angle := start + (stop-start)*t
		vertex(x + width*0.5*f32(math.cos(f64(angle))), y + height*0.5*f32(math.sin(f64(angle))))
	}
	end_shape(true)
}

end_shape :: proc(close: bool) {
	ctx := get_context()
	if ctx.cc == nil || len(ctx.cc.path_points) < 2 { return }
	if close && (ctx.cc.path_points[0] != ctx.cc.path_points[len(ctx.cc.path_points)-1]) {
		append(&ctx.cc.path_points, ctx.cc.path_points[0])
	}
	points := ctx.cc.path_points
	color := ctx.cc.current_style.color
	if !ctx.cc.current_style.fill {
		for i in 0..=len(points)-2 { draw_line(points[i].x, points[i].y, points[i+1].x, points[i+1].y, color) }
	} else {
		sgl.c4f(color.r, color.g, color.b, color.a)
		sgl.begin_triangles()
		for i in 1..=len(points)-3 {
			sgl.v2f(points[0].x, points[0].y); sgl.v2f(points[i].x, points[i].y); sgl.v2f(points[i+1].x, points[i+1].y)
		}
		sgl.end()
	}
	ctx.cc.path_points = nil
}