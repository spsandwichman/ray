package raymarcher

import "core:math/linalg"

vec3 :: [3]f64

// object :: struct {
//     position, rotation, scale : vec3
//     sdf : proc(_: vec3) -> f64
// }

color :: [3]u8

camera :: struct {

    // t = [0,0,-1], cx = [1,0,0], cy = [0,1,0]

    pos, rot : vec3,
    dim : [2]int,       // in pixels - this determins how many rays it will cast
    buf : ^[WIDTH][HEIGHT]color,    // [x][y]
    max : int,          // max march count
    lim : f64,          // max distance to stop marching at
    fov : f64,          // horizontal field of veiw, in degrees
}

scene :: struct {
    camera : camera,
    objects : []SDF,
}

SDF :: proc(_: vec3) -> f64

sphere :: proc(ray: vec3) -> f64 {
    pos :: vec3{1,1,1}
    radius :: 2
    return linalg.distance(ray,pos)-radius
}