// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

package cc

import "core:fmt"
import "core:log"
import "core:os"
import "core:strings"

import colors "./colors"
import util "./util"

import sg "shared:sokol/gfx"
import sgl "shared:sokol/gl"
import sapp "shared:sokol/app"
import stbi "vendor:stb/image"

Image :: struct {
	id:          int,
	width:       int,
	height:      int,
	nr_channels: int,
	ok:          bool,
	data:        rawptr,
	ext:         string,
	simg_ok:     bool,
	simg:        sg.Image,
	ssmp:        sg.Sampler,
	sview:       sg.View,
	path:        string
}

// returns error at last parameter if load failed
load_image :: proc(path_str: string) -> (Image, bool) {
    ctx := get_context()

    path := path_str

    // pwd := os.get_current_directory()
    // defer delete(pwd)

    // sep := "/"

    // if !os.is_file(path) {
    //     // try adding pwd to make absolute
    // }

    // if not found, return error
    if !os.is_file(path) {
        log.error("cc.load_image: file not found:", path)
        return Image{}, true
    }

    ext := ""

    {
        lst := strings.split(path, ".")
        defer delete(lst)
        if len(lst) > 0 {
            ext = lst[len(lst) - 1]
        }
    }

    if ctx.cc != nil {
        width : i32
        height : i32
        nr_channels : i32

        cstr_path := strings.clone_to_cstring(path)
        defer delete(cstr_path)

		stb_img_data := stbi.load(cstr_path, &width, &height, &nr_channels, 4)
        if stb_img_data != nil {
			ctx.cc.img_count += 1

            img := Image{
                width =       int(width),
                height =      int(height),
                nr_channels = int(nr_channels),
                ok =          false,
                data =        stb_img_data,
                ext =         ext,
                path =        path,
                // id =          len(ctx.cc.image_cache)
				id =          ctx.cc.img_count
            }
            // append(&ctx.cc.image_cache, img)
            init_sokol_image(&img)
            return img, false
        }else{
            return Image{}, true
        }
	}else{
        log.warn("cc: Please call load_image after cc initialized (at setup/init function)")

        return Image{}, true
    }
}

// destroy GPU resources associated with the image
delete_image :: proc(image: ^Image) {
	if image != nil && image.ok {
		if image.simg.id > 0 {
			sg.destroy_image(image.simg)
		}
		if image.ssmp.id > 0 {
			sg.destroy_sampler(image.ssmp)
		}
	}
}

@(private)
init_sokol_image :: proc(img: ^Image) {
	// fmt.println('\n init sokol image $img.path ok=$img.simg_ok')
	img_desc := sg.Image_Desc{
		width =       i32(img.width),
		height =      i32(img.height),
		num_mipmaps = 0,
		// wrap_u = .clamp_to_edge, // XTODO SAMPLER
		// wrap_v = .clamp_to_edge,
		label =       strings.unsafe_string_to_cstring(img.path),
		d3d11_texture = nil
	}

    // fmt.println(img_desc)

	// NOTE the following code, sometimes, result in hard-to-detect visual errors/bugs:
	// img_size := usize(img.nr_channels * img.width * img.height)
	// As an example see https://github.com/vlang/vab/issues/239
	// The image will come out blank for some reason and no SOKOL_ASSERT
	// nor any CI check will/can currently catch this.
	// Since all of gg currently runs with more or less *defaults* from sokol_gfx/sokol_gl
	// we should currently just use the sum of each of the RGB and A channels (= 4) here instead.
	// Optimized PNG images that have no alpha channel is often optimized to only have
	// 3 (or less) channels which stbi will correctly detect and set as `img.nr_channels`
	// but the current sokol_gl context setup expects 4. It *should* be the same with
	// all other stbi supported formats.
	img_size := uint(4 * img.width * img.height)
	img_desc.data.mip_levels[0] = sg.Range{
		ptr  = img.data,
		size = img_size
	}
	img.simg = sg.make_image(img_desc)

	smp_desc := sg.Sampler_Desc{
		min_filter = .LINEAR,
		mag_filter = .LINEAR,
		wrap_u =     .CLAMP_TO_EDGE,
		wrap_v =     .CLAMP_TO_EDGE
	}

    // fmt.println(smp_desc)

	img.ssmp = sg.make_sampler(smp_desc)

	img.sview = sg.make_view({ texture = { image = img.simg } })

    // fmt.println("simg_ok")

	img.simg_ok = true
	img.ok = true
}


// draw image

image :: proc(img: ^Image, x: f32, y: f32) {
	ctx := get_context()
	if ctx.cc != nil {
		if img != nil && img.ok && img.simg_ok {
			image_with_size(img, x, y, f32(img.width), f32(img.height))
		}
	}
}

image_with_size:: proc(img: ^Image, x: f32, y: f32, w: f32, h: f32) {
	ctx := get_context()
	if ctx.cc != nil {
		if img != nil && img.ok && img.simg_ok {
			// TODO: should load alpha pipeline if alpha blending is needed

			color := colors.white
			// color := ctx.cc.current_style.color
			// color := colors.red

			c := colors.u8_color(color)

			// fmt.println("color", c)

			ww := sapp.widthf()
   			wh := sapp.heightf()

			u0f := f32(0)
			v0f := f32(0)
			u1f := f32(1)
			v1f := f32(1)

			px0 := util.mapf(x, 0, ww, -1, 1)
			py0 := util.mapf(y, 0, wh, 1, -1)
			px1 := util.mapf(x + w, 0, ww, -1, 1)
			py1 := util.mapf(y + h, 0, wh, 1, -1)

			// fmt.println("ww, wh", ww, wh)
			// fmt.println(x, y, w, h)
			// fmt.println(px0, py0, px1, py1)

			sgl.defaults()
			sgl.enable_texture()
			sgl.texture(img.sview, img.ssmp)
			sgl.begin_quads()
			sgl.c4b(c.r, c.g, c.b, c.a)
			sgl.v2f_t2f(px0, py0, u0f, v0f)
			sgl.v2f_t2f(px1, py0, u1f, v0f)
			sgl.v2f_t2f(px1, py1, u1f, v1f)
			sgl.v2f_t2f(px0, py1, u0f, v1f)
			sgl.end()

			sgl.disable_texture()
		}
	}
}