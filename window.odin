// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

package cc

import sapp "shared:sokol/app"
import types "./types"

width :: proc() -> int {
	ctx := get_context()
	if ctx.cc != nil {
        return int(sapp.widthf())
	}else{
        if ctx.pref.size != nil {
		    return ctx.pref.size.(types.Vector2(int)).x
        } else {
            return 0
        }
	}
}

height :: proc() -> int {
	ctx := get_context()
	if ctx.cc != nil {
        return int(sapp.heightf())
	}else{
        if ctx.pref.size != nil {
		    return ctx.pref.size.(types.Vector2(int)).y
        } else {
            return 0
        }
	}
}