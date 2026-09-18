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
		draw_filled_polygon(points[:len(points)-1], color)
	}
	ctx.cc.path_points = nil
}

draw_filled_polygon :: proc(points: []Path_Point, color: types.Color) {
	if len(points) < 3 { return }
	indices := make([dynamic]int, len(points))
	for i in 0..<len(points) { indices[i] = i }
	orientation := f32(1)
	if polygon_area(points) < 0 { orientation = -1 }
	sgl.c4f(color.r, color.g, color.b, color.a)
	sgl.begin_triangles()
	guard := 0
	for len(indices) > 3 && guard < len(points)*len(points) {
		clipped := false
		for i in 0..<len(indices) {
			previous := points[indices[(i+len(indices)-1)%len(indices)]]
			current := points[indices[i]]
			next := points[indices[(i+1)%len(indices)]]
			if path_cross(previous, current, next) * orientation <= 0 { continue }
			contains := false
			for candidate_index in indices {
				if candidate_index == indices[(i+len(indices)-1)%len(indices)] || candidate_index == indices[i] || candidate_index == indices[(i+1)%len(indices)] { continue }
				if path_point_in_triangle(points[candidate_index], previous, current, next, orientation) {
					contains = true
					break
				}
			}
			if contains { continue }
			sgl.v2f(previous.x, previous.y); sgl.v2f(current.x, current.y); sgl.v2f(next.x, next.y)
			for j in i..<len(indices)-1 { indices[j] = indices[j+1] }
			pop(&indices)
			clipped = true
			break
		}
		if !clipped { break }
		guard += 1
	}
	if len(indices) == 3 {
		sgl.v2f(points[indices[0]].x, points[indices[0]].y)
		sgl.v2f(points[indices[1]].x, points[indices[1]].y)
		sgl.v2f(points[indices[2]].x, points[indices[2]].y)
	}
	sgl.end()
}

polygon_area :: proc(points: []Path_Point) -> f32 {
	area := f32(0)
	for i in 0..<len(points) {
		next := (i+1) % len(points)
		area += points[i].x * points[next].y - points[next].x * points[i].y
	}
	return area * 0.5
}

path_cross :: proc(a, b, c: Path_Point) -> f32 {
	return (b.x-a.x)*(c.y-a.y) - (b.y-a.y)*(c.x-a.x)
}

path_point_in_triangle :: proc(point, a, b, c: Path_Point, orientation: f32) -> bool {
	return path_cross(a, b, point)*orientation >= 0 && path_cross(b, c, point)*orientation >= 0 && path_cross(c, a, point)*orientation >= 0
}