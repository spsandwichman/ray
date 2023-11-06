package raylab

import m "core:math"
import   "core:fmt"
import   "vendor:raylib"

make_example_scene :: proc() -> (s: ^scene) {
    
    s = new(scene)

    s.camera = new(camera)

    s.camera.pos = {0, 0, 7}
    s.camera.rot = {m.to_radians_f32(0),0,m.to_radians_f32(0)}
    s.camera.fov = m.to_radians_f32(65.0)
    s.camera.max_march = 500
    s.camera.min_dist = 0.01
    s.camera.max_dist = 100

    s.objects = make([dynamic]object)
    append(&s.objects, new_sphere("example_sphere")^)

    return
}

new_sphere :: proc(name: string) -> (obj: ^object) {
    obj = new(object)
    obj.name = name
    obj.SDF = 
        "return length(ray-position)-radius;\n" // TODO make this an allocation
    append(&obj.params, 
        param{"radius", .t_float, "4"},
        param{"position", .t_vec3, "vec3(0,0,0)"},
    )
    return
}

compile_scene :: proc(s: ^scene) -> (vertex: string, fragment: string) {
    return
}

sgen_shader :: struct {
    uniforms: [dynamic]^sgen_param,
    in_outs:  [dynamic]^sgen_param, // used to generate in/out interfaces and must be in evaluation order
    SDFs:     [dynamic]^sgen_SDF,
}

sgen_SDF :: struct {
    object_name : ^object,
    global_name : string,
    code : string, // does not include function header or brackets, just raw code
}

sgen_param :: struct {
    base: ^param,
    global_name: string,
    mode: sgen_param_mode,
    dependencies: [dynamic]^sgen_param,
    type: param_type,
    formula: string, // only applicable for dependent params
}

sgen_param_mode :: enum u8 {
    uniform,    // user defined free params
    dependent,  // user defined dep params
    intrinsic_uniform,   // raylab instrinsic free params
    intrinsic_dependent, // raylab instrinsic dep params

}

scene_driver_interface :: struct {
    
}

sgen_default_params :: [?]sgen_param{
    {nil, "rl_resolution",    .intrinsic_uniform, nil, .t_vec2, ""},
    {nil, "rl_time",          .intrinsic_uniform, nil, .t_float, ""},
    {nil, "rl_frametime",     .intrinsic_uniform, nil, .t_float, ""},
    {nil, "rl_cam_pos",       .intrinsic_uniform, nil, .t_vec3, ""},
    {nil, "rl_cam_rot",       .intrinsic_uniform, nil, .t_vec3, ""},
    {nil, "rl_cam_max_march", .intrinsic_uniform, nil, .t_int, ""},
    {nil, "rl_cam_max_dist",  .intrinsic_uniform, nil, .t_float, ""},
    {nil, "rl_cam_min_dist",  .intrinsic_uniform, nil, .t_float, ""},
    {nil, "rl_cam_fov",       .intrinsic_uniform, nil, .t_float, ""},
    {nil, "rl_cam_target",    .intrinsic_dependent, nil, .t_vec3, ""},
    {nil, "rl_cam_local_x",   .intrinsic_dependent, nil, .t_vec3, ""},
    {nil, "rl_cam_local_y",   .intrinsic_dependent, nil, .t_vec3, ""},
    {nil, "rl_uv",            .intrinsic_dependent, nil, .t_vec2, ""},
}
