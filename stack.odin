// Original code: https://github.com/greenya/SpaceLib/blob/main/src/core/stack.odin
//
// modified for CC by Fumiya Funatsu

/*

Zlib License

Copyright (C) 2025 Fumiya Funatsu
Copyright (C) 2025 Yuriy Grynevych

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgement in the product documentation would
   be appreciated but is not required.

2. Altered source versions must be clearly marked as such, and must not
   be misrepresented as being the original software.

3. This notice may not be removed or altered from any source
   distribution.

*/

package cc
// NOTE: original package was spacelib_core, changed it for usability

Stack :: struct ($T: typeid, $N: int) {
    size    : int,
    items   : [N] T,
}

// returns error or not at last paramter
stack_push :: #force_inline proc(stack: ^Stack($T, $N), value: T) -> bool {
    // assert(stack.size < len(stack.items))

    if !(stack.size < len(stack.items)) {
        return false
    }

    stack.items[stack.size] = value
    stack.size += 1

    return true
}

// returns error or not at last paramter
stack_pop :: #force_inline proc(stack: ^Stack($T, $N)) -> (Maybe(T), bool) {
    // assert(stack.size > 0)
    
    if !(stack.size > 0) {
        return nil, false
    }

    stack.size -= 1
    return stack.items[stack.size], true
}

// returns error or not at last paramter
stack_drop :: #force_inline proc(stack: ^Stack($T, $N)) {
    // assert(stack.size > 0)
    if !(stack.size > 0) {
        return false
    }

    stack.size -= 1

    return true
}

// returns error or not at last paramter
stack_top :: #force_inline proc(stack: Stack($T, $N)) -> (Maybe(T), bool) {
    // assert(stack.size > 0)
    if !(stack.size > 0) {
        return nil, false
    }

    return stack.items[stack.size-1], true
}

stack_items :: #force_inline proc(stack: ^Stack($T, $N)) -> [] T {
    return stack.items[:stack.size]
}

stack_clear :: #force_inline proc(stack: ^Stack($T, $N)) -> T {
    stack.size = 0
}

stack_is_empty :: #force_inline proc(stack: Stack($T, $N)) -> bool {
    return stack.size == 0
}

stack_is_full :: #force_inline proc(stack: Stack($T, $N)) -> bool {
    return stack.size == len(stack.items)
}

stack_size :: #force_inline proc(stack: Stack($T, $N)) -> int {
    return stack.size
}

stack_size_max :: #force_inline proc(stack: Stack($T, $N)) -> int {
    return len(stack.items)
}