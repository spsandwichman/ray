package raylab

import "core:fmt"
import m "core:math"
import rl "vendor:raylib"

WIDTH, HEIGHT :: 1600, 900
// WIDTH, HEIGHT :: 1920, 1080
// WIDTH, HEIGHT :: 1000, 500

main :: proc() {

    // raylib init
    rl.InitWindow(WIDTH, HEIGHT, "raylab")
    defer rl.CloseWindow()
    // rl.SetTargetFPS(20)

    // init camera
    cam : raylab_camera
    cam.pos, cam.rot = {0, 0, 7}, {m.to_radians_f32(0),0,m.to_radians_f32(0)}
    cam.fov = m.to_radians_f32(65.0)
    cam.max_march = 500
    cam.min_dist = 0.01
    cam.max_dist = 100

    // init scene
    scene : raylab_scene
    scene.camera = &cam

    // load shader
    shader := rl.LoadShader("res/vert.glsl", "res/frag.glsl") // load default vertex shader
    defer rl.UnloadShader(shader)
    
    // link uniforms
    shader_loc_resolution := transmute(rl.ShaderLocationIndex) rl.GetShaderLocation(shader, "resolution")
    vec2_resolution := [2]f32{f32(WIDTH), f32(HEIGHT)}
    rl.SetShaderValue(shader, shader_loc_resolution, &vec2_resolution, .VEC2)
    
    shader_loc_total_time := transmute(rl.ShaderLocationIndex) rl.GetShaderLocation(shader, "total_time")
    shader_loc_delta_time := transmute(rl.ShaderLocationIndex) rl.GetShaderLocation(shader, "delta_time")

    shader_loc_c_pos       := transmute(rl.ShaderLocationIndex) rl.GetShaderLocation(shader, "c_pos")
    shader_loc_c_rot       := transmute(rl.ShaderLocationIndex) rl.GetShaderLocation(shader, "c_rot")
    shader_loc_c_max_march := transmute(rl.ShaderLocationIndex) rl.GetShaderLocation(shader, "c_max_march")
    shader_loc_c_max_dist  := transmute(rl.ShaderLocationIndex) rl.GetShaderLocation(shader, "c_max_dist")
    shader_loc_c_min_dist  := transmute(rl.ShaderLocationIndex) rl.GetShaderLocation(shader, "c_min_dist")
    shader_loc_c_fov       := transmute(rl.ShaderLocationIndex) rl.GetShaderLocation(shader, "c_fov")


    // target render texture
    target := rl.LoadRenderTexture(WIDTH, HEIGHT)
    defer rl.UnloadRenderTexture(target)

    for !rl.WindowShouldClose() {

        // pass data to shader
        total_time := cast(f32) rl.GetTime()/5 + 1.5
        delta_time := cast(f32) rl.GetFrameTime()

        rl.SetShaderValue(shader, shader_loc_total_time, &total_time, .FLOAT)
        rl.SetShaderValue(shader, shader_loc_delta_time, &delta_time, .FLOAT)


        rl.SetShaderValue(shader, shader_loc_c_pos,       &scene.camera.pos,       .VEC3)
        rl.SetShaderValue(shader, shader_loc_c_rot,       &scene.camera.rot,       .VEC3)
        rl.SetShaderValue(shader, shader_loc_c_fov,       &scene.camera.fov,       .FLOAT)
        rl.SetShaderValue(shader, shader_loc_c_max_dist,  &scene.camera.max_dist,  .FLOAT)
        rl.SetShaderValue(shader, shader_loc_c_min_dist,  &scene.camera.min_dist,  .FLOAT)
        rl.SetShaderValue(shader, shader_loc_c_max_march, &scene.camera.max_march, .INT)

        rl.BeginTextureMode(target)
            rl.ClearBackground(rl.MAGENTA) // magenta is the fallback color if the shader did NOT COMPILE
            rl.DrawRectangle(0, 0, WIDTH, HEIGHT, rl.MAGENTA)
        rl.EndTextureMode()

        rl.BeginDrawing()
        {
             rl.BeginShaderMode(shader)
                rl.DrawTextureEx(target.texture, {0,0}, 0, 1, rl.WHITE)
            rl.EndShaderMode()

            rl.DrawText(fmt.ctprintf("%v fps", rl.GetFPS()), 0, 0, 10, rl.WHITE)
            rl.DrawText(fmt.ctprintf("min_dist %.6f", scene.camera.min_dist), 0, 13*1, 10, rl.WHITE)
            rl.DrawText(fmt.ctprintf("t %v", total_time), 0, 13*2, 10, rl.WHITE)
            rl.DrawText(fmt.ctprintf("dt %v", delta_time), 0, 13*3, 10, rl.WHITE)


        }
        rl.EndDrawing()

        free_all(context.temp_allocator)

        // scene.camera.rot.z += 0.001
        scene.camera.pos.x = m.sin(total_time)*3.0
        scene.camera.pos.z = m.cos(total_time)*3.0
        scene.camera.rot.y = -total_time
        if scene.camera.min_dist >= 0.0003 {
            scene.camera.min_dist = 1/m.pow(total_time, 5)
        }
        
        // scene.camera.rot.x = -total_time/5
        // scene.camera.rot.z = total_time/3

    }

}
