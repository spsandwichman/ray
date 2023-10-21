package raymarcher

import "core:fmt"
import rl "vendor:raylib"

// WIDTH, HEIGHT :: 1600, 900
WIDTH, HEIGHT :: 800, 450
// WIDTH, HEIGHT :: 200, 100

main :: proc() {

    // raylib init
    rl.InitWindow(WIDTH, HEIGHT, "ray")
    defer rl.CloseWindow()
    // rl.SetTargetFPS(60)

    // init camera
    cam : camera
    cam.pos, cam.rot = {0,0,2.5}, {0,0,0}
    cam.fov = 70
    cam.max_march = 200
    cam.min_dist = 0.0001
    cam.max_dist = 100

    // init screen buffer
    cam.buf = new([WIDTH*HEIGHT]color)
    defer free(cam.buf)
    screen_image := rl.Image{
        data = cam.buf,
        width = WIDTH,
        height = HEIGHT,
        mipmaps = 1,
        format = .UNCOMPRESSED_R8G8B8,
    }
    screen_texture : rl.Texture = rl.LoadTextureFromImage(screen_image)
    defer rl.UnloadTexture(screen_texture)

    // init scene
    scene : scene
    scene.camera = &cam
    scene.objects = make([dynamic]object)
    append(&scene.objects, create_mandelbulb())
    // append(&scene.objects, create_sphere({0, 0, -3}, 1))
    // append(&scene.objects, create_sphere({-1, -1, -5}, 1))
    // append(&scene.objects, create_box({1, 1, -5}, {0.5, 3, 0.5}))

    for !rl.WindowShouldClose() {

        // for i in 0..<WIDTH*HEIGHT {
        //     x := i % WIDTH
        //     y := i / WIDTH

        //     cam.buf[i] = { u8(x % 256), u8(y % 256), 100}
        // }

        render(&scene)

        cam.rot.z += 0.1

        rl.UpdateTexture(screen_texture, cam.buf)

        rl.BeginDrawing()
        {
            rl.ClearBackground(rl.BLUE)
            rl.DrawTexture(screen_texture, 0, 0, rl.WHITE)
            rl.DrawText(fmt.ctprintf("%v fps", rl.GetFPS()), 0, 0, 10, rl.WHITE)

            target, loc_x, loc_y := rotate_cam(&cam)

            rl.DrawText(fmt.ctprintf("pos %v rot %v", cam.pos, cam.rot), 0, 13, 10, rl.WHITE)
            rl.DrawText(fmt.ctprintf("target %v", target), 0, 26, 10, rl.WHITE)
            rl.DrawText(fmt.ctprintf("local x %v, local y %v", loc_x, loc_y), 0, 39, 10, rl.WHITE)
        }
        rl.EndDrawing()

        free_all(context.temp_allocator)

    }

    


}