// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

package cc

import sgl "shared:sokol/gl"

scale :: proc(x: f32, y: f32, z: f32) {
    sgl.scale(x, y, z)
}

translate :: proc(x: f32, y: f32, z: f32) {
    sgl.translate(x, y, z)
}

rotate :: proc(angle_rad: f32, x: f32, y: f32, z: f32) {
    sgl.rotate(angle_rad, x, y, z)
}

rad :: proc(deg: f32) -> f32 {
    return sgl.rad(deg)
}

deg :: proc(rad: f32) -> f32 {
    return sgl.deg(rad)
}
