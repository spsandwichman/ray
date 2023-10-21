package raymarcher

import m "core:math"
import "core:math/linalg"

render :: proc(c: ^camera, scene: ^scene) {
    
    rot := matrix[3,3]f64 {
        1,        0,              0,
        0,  m.cos(c.rot.x), m.sin(c.rot.x),
        0, -m.sin(c.rot.x), m.cos(c.rot.x),
    } * matrix[3,3]f64 {
        m.cos(c.rot.y), 0, -m.sin(c.rot.y),
              0,        1,        0,
        m.sin(c.rot.y), 0,  m.cos(c.rot.y),
    } * matrix[3,3]f64 {
         m.cos(c.rot.z), m.sin(c.rot.z), 0,
        -m.sin(c.rot.z), m.cos(c.rot.x), 0,
               0,              0,        0,
    }

    new_t  := rot * vec3{0, 0, -1} + c.pos  // target vector
    new_cx := rot * vec3{1, 0, 0} + c.pos   // perpendicular to target vector in camera/screen's local X
    new_cy := rot * vec3{0, 1, 0} + c.pos   // perpendicular to target vector in camera/screen's local Y
    // ^^^ all of these should be normalized!! if they are not, rendering will be WEIRD

    viewport_width := m.tan(m.to_radians(c.fov)/2)*2
    viewport_height := viewport_width * (HEIGHT/WIDTH)

    i, j : f64

    x_step := viewport_width  / (WIDTH - 1)
    y_step := viewport_height / (WIDTH - 1)

    raymarch_direction := linalg.normalize(((x_step * i * new_cx) + (y_step * j * -new_cy)))

    

    


}