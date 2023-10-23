package raylab

import rl "vendor:raylib"
import "core:fmt"
import m "core:math"
import "core:math/linalg"

rotate_cam :: proc(c: ^camera) -> (target, local_x, local_y : vec3) {
    rot := matrix[3,3]f32 {
        1,        0,              0,
        0,  m.cos(c.rot.x), m.sin(c.rot.x),
        0, -m.sin(c.rot.x), m.cos(c.rot.x),
    } * matrix[3,3]f32 {
        m.cos(c.rot.y), 0, -m.sin(c.rot.y),
              0,        1,        0,
        m.sin(c.rot.y), 0,  m.cos(c.rot.y),
    } * matrix[3,3]f32 {
         m.cos(c.rot.z), m.sin(c.rot.z), 0,
        -m.sin(c.rot.z), m.cos(c.rot.z), 0,
               0,              0,        1,
    }

    target  = rot * vec3{0, 0, -1} // target vector
    local_x = rot * vec3{1, 0, 0}   // perpendicular to target vector in camera/screen's local X
    local_y = rot * vec3{0, 1, 0}   // perpendicular to target vector in camera/screen's local Y
    // ^^^ all of these should be normalized!! if they are not, rendering will be WACK
    return
}
