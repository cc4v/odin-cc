// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

package cc

import "core:fmt"
import "core:log"
import "core:os"
import "core:strings"

import sg "shared:sokol/gfx"
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
            img := Image{
                width =       int(width),
                height =      int(height),
                nr_channels = int(nr_channels),
                ok =          false,
                data =        stb_img_data,
                ext =         ext,
                path =        path,
                id =          len(ctx.cc.image_cache)
            }
            append(&ctx.cc.image_cache, img)
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

    fmt.println(img_desc)

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
	// img_desc.data.subimage[0][0] = sg.Range{
	// 	ptr  = img.data,
	// 	size = img_size
	// }
	img.simg = sg.make_image(img_desc)

	smp_desc := sg.Sampler_Desc{
		min_filter = .LINEAR,
		mag_filter = .LINEAR,
		wrap_u =     .CLAMP_TO_EDGE,
		wrap_v =     .CLAMP_TO_EDGE
	}

    // fmt.println(smp_desc)

	img.ssmp = sg.make_sampler(smp_desc)

    // fmt.println("simg_ok")

	img.simg_ok = true
	img.ok = true
}


// draw image

image :: proc(img: ^Image, x: f32, y: f32) {
    // TODO: Implement
}

image_with_size:: proc(img: ^Image, x: f32, y: f32, w: f32, h: f32) {
    // TODO: Implement
}