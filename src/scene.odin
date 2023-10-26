package raylab

import "core:math/linalg"
import m "core:math"
import "vendor:raylib"
import "core:fmt"

vec3 :: [3]f32

raylab_scene :: struct {
    camera  : ^raylab_camera,
    objects : [dynamic]raylab_object,
    params  : [dynamic]raylab_param,
}

raylab_camera :: struct {
    pos, rot  : vec3,
    max_march : int,          // max march count
    max_dist  : f32,          // max distance to stop marching at
    min_dist  : f32,          // min distance to stop marching at
    fov       : f32,          // horizontal field of veiw, in degrees
}

raylab_object :: struct {
    name : string,
    SDF : string, // raw GLSL code
    params : [dynamic]raylab_param,
}

raylab_param :: struct {
    name : string,
    type : raylab_param_type,
    value : string,
    dependencies: [dynamic]^raylab_param
}

raylab_param_type :: enum {
    t_bool,
    t_int,
    t_uint,
    t_float,
    t_double,
    t_bvec2, t_ivec2, t_uvec2, t_vec2, t_dvec2,
    t_bvec3, t_ivec3, t_uvec3, t_vec3, t_dvec3,
    t_bvec4, t_ivec4, t_uvec4, t_vec4, t_dvec4,

    // t_mat2x2, t_mat2x3, t_mat2x4, // maybe later
    // t_mat3x2, t_mat3x3, t_mat3x4,
    // t_mat4x2, t_mat4x3, t_mat4x4,
}

raylab_param_type_str :: [raylab_param_type]string {
    .t_bool     = "bool",
    .t_int      = "int",
    .t_uint     = "uint",
    .t_float    = "float",
    .t_double   = "double",
    
    .t_bvec2    = "bvec2", 
    .t_ivec2    = "ivec2", 
    .t_uvec2    = "uvec2", 
    .t_vec2     = "vec2", 
    .t_dvec2    = "dvec2",

    .t_bvec3    = "bvec3", 
    .t_ivec3    = "ivec3", 
    .t_uvec3    = "uvec3", 
    .t_vec3     = "vec3", 
    .t_dvec3    = "dvec3",

    .t_bvec4    = "bvec4", 
    .t_ivec4    = "ivec4", 
    .t_uvec4    = "uvec4", 
    .t_vec4     = "vec4", 
    .t_dvec4    = "dvec4",
}