#version 330

in vec2 tex_coord;

in vec3 target;
in vec3 local_x;
in vec3 local_y;

out vec4 finalColor;

uniform vec2  raylab_resolution;
uniform float raylab_total_time;
uniform float raylab_delta_time;

uniform vec3  c_pos;
uniform vec3  c_rot;
uniform float c_fov;
uniform float c_min_dist;
uniform float c_max_dist;
uniform int   c_max_march;

float object_sphere_SDF(vec3 pos) {
    vec3 sphere_pos = vec3(0,0,0);
    return length(pos-sphere_pos)-0.20;
}

float scene_SDF(vec3 ray) {
    return object_sphere_SDF(ray);
}

void main() {

    // SHADERGEN : RENDER KERNEL
    vec2 pixel = tex_coord * raylab_resolution;

    float viewport_width = tan(c_fov/2)*2;
    float viewport_height = viewport_width * (raylab_resolution.y/raylab_resolution.x);

    float x_step = viewport_width  / (raylab_resolution.x - 1);
    float y_step = viewport_height / (raylab_resolution.y - 1);

    vec3 march_direction = normalize(
        (x_step * (pixel.x - raylab_resolution.x/2.) * local_x) +
        (y_step * (pixel.y - raylab_resolution.y/2.) * -local_y) + target
    );
    vec3 ray = c_pos;

    int iter = 0;
    float dist = scene_SDF(ray); 

    while (dist > c_min_dist && // (sandwich) try to change this to a for loop so it can be unrolled
          dist < c_max_dist &&
          iter < c_max_march) {
        
        ray += march_direction * dist * 1;
        dist = scene_SDF(ray);
        iter += 1;
    }
    // SHADERGEN : END RENDER KERNEL

    // SHADERGEN : MATERIAL COMPOSITOR
    finalColor = vec4(vec3(float(iter)/float(c_max_march)), 1);
}
