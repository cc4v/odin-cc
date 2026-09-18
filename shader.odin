// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

package cc

import sg "shared:sokol/gfx"

Shader :: struct { raw: sg.Shader }

shader_from_desc :: proc(desc: ^sg.Shader_Desc) -> Shader {
	return Shader{raw = sg.make_shader(desc^)}
}

shader_make_pipeline :: proc(shader: Shader, desc: sg.Pipeline_Desc) -> sg.Pipeline {
	pipeline_desc := desc
	pipeline_desc.shader = shader.raw
	return sg.make_pipeline(pipeline_desc)
}

shader_begin :: proc(shader: Shader, pipeline: sg.Pipeline, bindings: ^sg.Bindings) {
	sg.apply_pipeline(pipeline)
	sg.apply_bindings(bindings^)
}

shader_set_uniform :: proc(shader: Shader, slot: int, data: ^sg.Range) {
	sg.apply_uniforms(slot, data^)
}

shader_draw :: proc(shader: Shader, num_elements: int) { sg.draw(0, num_elements, 1) }

shader_destroy :: proc(shader: ^Shader) {
	if shader.raw.id != 0 { sg.destroy_shader(shader.raw); shader.raw = {} }
}

Shader_Rect :: struct {
	shader: Shader,
	pipeline: sg.Pipeline,
	bindings: sg.Bindings,
}

shader_rect_from_desc :: proc(desc: ^sg.Shader_Desc, position_attr: int) -> Shader_Rect {
	shader := shader_from_desc(desc)
	pipeline_desc := sg.Pipeline_Desc{
		shader = shader.raw,
		primitive_type = .TRIANGLE_STRIP,
	}
	pipeline_desc.layout.attrs[position_attr].format = .FLOAT2
	pipeline := sg.make_pipeline(pipeline_desc)
	bindings := sg.Bindings{}
	buffer_desc := sg.Buffer_Desc{
		size = size_of(f32) * 8,
		usage = {vertex_buffer = true, dynamic_update = true},
	}
	bindings.vertex_buffers[0] = sg.make_buffer(buffer_desc)
	return Shader_Rect{shader = shader, pipeline = pipeline, bindings = bindings}
}

shader_rect_begin :: proc(rect: ^Shader_Rect) {
	shader_begin(rect.shader, rect.pipeline, &rect.bindings)
}

shader_rect_set_uniform :: proc(rect: ^Shader_Rect, slot: int, data: ^sg.Range) {
	shader_set_uniform(rect.shader, slot, data)
}

shader_rect_draw :: proc(rect: ^Shader_Rect, x, y, rect_width, rect_height: f32) {
	screen_width := max(width(), 1)
	screen_height := max(height(), 1)
	left := x / f32(screen_width) * 2.0 - 1.0
	right := (x + rect_width) / f32(screen_width) * 2.0 - 1.0
	top := 1.0 - y / f32(screen_height) * 2.0
	bottom := 1.0 - (y + rect_height) / f32(screen_height) * 2.0
	vertices := [8]f32{left, bottom, right, bottom, left, top, right, top}
	sg.update_buffer(rect.bindings.vertex_buffers[0], sg.Range{ptr = rawptr(&vertices), size = size_of(vertices)})
	shader_draw(rect.shader, 4)
}

shader_rect_destroy :: proc(rect: ^Shader_Rect) {
	if rect.bindings.vertex_buffers[0].id != 0 { sg.destroy_buffer(rect.bindings.vertex_buffers[0]) }
	if rect.pipeline.id != 0 { sg.destroy_pipeline(rect.pipeline) }
	shader_destroy(&rect.shader)
	rect.bindings = {}
	rect.pipeline = {}
}