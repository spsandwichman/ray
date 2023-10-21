package raymarcher

import "core:math/linalg"
import m "core:math"
import "vendor:raylib"
import "core:fmt"

vec3 :: [3]f64

color :: [3]u8 // RGB8

vmax :: proc(v: vec3) -> f64 {
    return max(v.x, v.y, v.z)
}

vabs :: proc(v: vec3) -> vec3 {
    return {abs(v.x),abs(v.y),abs(v.z)}
}

vlen :: linalg.length

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

object :: struct {
    sdf : SDF,
    data : rawptr,
}

SDF :: proc(_: vec3, _: rawptr) -> f64

scene_SDF :: proc(scene: ^scene, v: vec3) -> (dist: f64) {
    dist = 0h7ff00000_00000000
    for o in scene.objects {
        dist = min(dist, o.sdf(v, o.data))
    }
    return
}

/* --------------------------------- spheres -------------------------------- */

sphere_data :: struct {
    pos : vec3,
    radius : f64
}

create_sphere :: proc(pos : vec3, radius: f64) -> (obj: object) {

    obj.sdf = sphere_SDF

    data := new(sphere_data)
    data.pos = pos
    data.radius = radius

    obj.data = data
    return
}

sphere_SDF :: proc(ray: vec3, data: rawptr) -> f64 {
    
    sphere := transmute(^sphere_data) data

    return linalg.distance(ray,sphere.pos)-sphere.radius
}

/* ---------------------------------- boxes --------------------------------- */

box_data :: struct {
    pos : vec3,
    size : vec3,
}

create_box :: proc(pos : vec3, size: vec3) -> (obj: object) {

    obj.sdf = box_SDF

    data := new(box_data)
    data.pos = pos
    data.size = size

    obj.data = data
    return
}

box_SDF :: proc(ray: vec3, data: rawptr) -> f64 {
    
    box := transmute(^box_data) data

    return vmax(vabs(ray - box.pos) - box.size)
}

/* --------------------------------- FRACTAL -------------------------------- */

create_mandelbulb :: proc() -> (obj: object) {
    obj.sdf = mandelbulb_SDF
    return
}

mandelbulb_SDF :: proc(ray: vec3, data: rawptr) -> f64 {
    iterations :: 20
    power :: 4

    z := ray
    dr : f64 = 1
    r : f64 = 0

    for i in 0..<iterations {
        r = vlen(z)
        if r > 4 do break

        // fmt.println(r)

        theta := m.acos(z.z/r)
        phi := m.atan2(z.y, z.x)
        dr = m.pow(r, power-1)*power*dr + 1

        zr := m.pow(r, power)
        theta = theta*power
        phi = phi*power



        z = zr * vec3{
            m.sin(theta)*m.cos(phi), 
            m.sin(phi)*m.sin(theta),
            m.cos(theta),
        }
        z += ray
    }


    return 0.5 * m.ln(r)*r/dr
}