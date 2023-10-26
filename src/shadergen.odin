package raylab

import m "core:math"
import   "core:fmt"

make_example_scene :: proc() -> (s: ^raylab_scene) {
    
    s = new(raylab_scene)

    s.camera = new(raylab_camera)

    s.camera.pos = {0, 0, 7}
    s.camera.rot = {m.to_radians_f32(0),0,m.to_radians_f32(0)}
    s.camera.fov = m.to_radians_f32(65.0)
    s.camera.max_march = 500
    s.camera.min_dist = 0.01
    s.camera.max_dist = 100

    obj := raylab_object{}
    obj.name = "example_sphere"
    obj.SDF =
        "vec3 sphere_pos = vec3(0,0,0);\n"  +
        "return length(pos-sphere_pos)-radius;\n"
    append(&obj.params, raylab_param{"radius", .t_float, "4", {}})

    s.objects = make([dynamic]raylab_object)
    append(&s.objects, obj)

    return
}

raylab_uniform :: struct {
    name : string,
    type : raylab_param_type,
}

// included by default in compiled shaders
raylab_intrinsic_uniforms := [?]raylab_uniform{
    {"raylab_time",       .t_float},
    {"raylab_frame_time", .t_float},
    {"raylab_fps",        .t_float},
    {"raylab_resolution", .t_vec2},
}

compile_scene :: proc(s: ^raylab_scene) -> (vertex, fragment: string) {
    
    
    
    
    
    
    return
}

emit_param_declaration :: proc(param: ^raylab_param) -> string {
    return fmt.aprintf("%s %s = %s;\n", raylab_param_type_str[param.type], param.name, param.value)
}