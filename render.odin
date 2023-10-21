package raymarcher

import rl "vendor:raylib"
import "core:fmt"
import m "core:math"
import "core:math/linalg"

rotate_cam :: proc(c: ^camera) -> (target, local_x, local_y : vec3) {
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
        -m.sin(c.rot.z), m.cos(c.rot.z), 0,
               0,              0,        1,
    }

    target  = rot * vec3{0, 0, -1} // target vector
    local_x = rot * vec3{1, 0, 0}   // perpendicular to target vector in camera/screen's local X
    local_y = rot * vec3{0, 1, 0}   // perpendicular to target vector in camera/screen's local Y
    // ^^^ all of these should be normalized!! if they are not, rendering will be WACK
    return
}

render :: proc(scene: ^scene) {
    
    target, new_cx, new_cy := rotate_cam(scene.camera)

    viewport_width := m.tan(m.to_radians(scene.camera.fov)/2)*2
    viewport_height := viewport_width * (f64(HEIGHT)/f64(WIDTH))

    x_step := viewport_width  / (WIDTH - 1)
    y_step := viewport_height / (HEIGHT - 1)

    for x in 0..<WIDTH {
        for y in 0..<HEIGHT {
            v_march := linalg.normalize(
                (x_step * (cast(f64) x - WIDTH/2) * new_cx) + 
                (y_step * (cast(f64) y - HEIGHT/2) * -new_cy) + // invert _cy because pixel rendering order
                + target
            )

            ray := scene.camera.pos


            
            scene.camera.buf[x + y*WIDTH] = {0,0,0}
            

            iter := 0
            for scene_SDF(scene, ray) > scene.camera.min_dist && 
                scene_SDF(scene, ray) < scene.camera.max_dist &&
                iter < scene.camera.max_march {
                
                // march
                ray += v_march * scene_SDF(scene, ray)
                iter += 1   
            }
            // fmt.println(iter)

            
            // has hit
            if scene_SDF(scene, ray) <= scene.camera.min_dist {
                scene.camera.buf[x + y*WIDTH] = {90, 90, 255} - {
                    u8(iter),
                    u8(iter),
                    u8(iter),
                }
            } else { // has not hit
                scene.camera.buf[x + y*WIDTH] = {
                    u8(iter),
                    u8(iter),
                    u8(iter),
                } * 2
            }
            // c := clamp(f64(iter)/20, 0, 1)
            // scene.camera.buf[x + y*WIDTH] = {
            //     cast(u8)(c*256),
            //     cast(u8)(c*256),
            //     cast(u8)(c*256),
            // }

            // fmt.println(iter, c)

            
            
        }
    }

}