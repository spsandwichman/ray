package raymarcher

import "core:math/linalg"
import "vendor:raylib"

vec3 :: [3]f64

color :: [3]u8 // RGB8

camera :: struct {

    // t = [0,0,-1], cx = [1,0,0], cy = [0,1,0]

    pos, rot : vec3,
    buf : ^[WIDTH*HEIGHT]color,    // [x][y]
    max_march : int,          // max march count
    max_dist  : f64,          // max distance to stop marching at
    min_dist  : f64,          // min distance to stop marching at
    fov : f64,          // horizontal field of veiw, in degrees
}

scene :: struct {
    camera : ^camera,
    objects : [dynamic]object,
}

scene_SDF :: proc(scene: ^scene, v: vec3) -> (dist: f64) {
    dist = 0h7ff00000_00000000
    for o in scene.objects {
        dist = min(dist, o.sdf(v, o.data))
    }
    return
}

object :: struct {
    sdf : SDF,
    data : rawptr,
}

SDF :: proc(_: vec3, _: rawptr) -> f64

create_sphere :: proc(pos : vec3, radius: f64) -> (obj: object) {

    sphere_data_t :: struct {
        pos : vec3,
        radius : f64
    }

    obj.sdf = sphere_SDF

    data := new(sphere_data_t)
    data.pos = pos
    data.radius = radius

    obj.data = data
    return
}

sphere_SDF :: proc(ray: vec3, data: rawptr) -> f64 {
    
    sphere_data_t :: struct {
        pos : vec3,
        radius : f64
    }

    sphere_data := transmute(^sphere_data_t) data

    return linalg.distance(ray,sphere_data.pos)-sphere_data.radius
}