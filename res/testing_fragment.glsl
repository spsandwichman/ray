#version 330

in vec2 tex_coord;

in vec3 raylab_cam_target;
in vec3 raylab_cam_local_x;
in vec3 raylab_cam_local_y;

uniform vec2 raylab_resolution;
uniform float raylab_total_time; // elapsed seconds since raylib initWindow()
uniform float raylab_delta_time; // elapsed seconds since last frame drawn

uniform vec3  raylab_cam_pos;
uniform vec3  raylab_cam_rot;
uniform float raylab_cam_fov;
uniform float raylab_cam_min_dist;
uniform float raylab_cam_max_dist;
uniform int   raylab_cam_max_march;

int MB_ITERATIONS = 20;
const float PI = 3.14159265358979;
float total_time = raylab_total_time/3;


float vmax(vec3 v) {
    return max(max(v.x, v.y), v.z);
}

float scene_SDF(vec3 ray) {

    vec3 sphere_pos = vec3(
        sin(total_time),
        sin(total_time+2*PI/3),
        sin(total_time+4*PI/3)
    );
    float sphere = length(ray-sphere_pos)-0.20;

    vec3 box_pos = vec3(
        -cos(total_time),
        cos(total_time+2*PI/3),
        cos(total_time+4*PI/3)
    );
    float box = vmax(abs(ray-box_pos)-vec3(0.20));

    vec3 ico_pos = vec3(
        cos(total_time),
        cos(total_time+2*PI/3),
        -cos(total_time+4*PI/3)
    );
    float ico;
    {
        float g = sqrt(5.)*.5+.5;
        vec3 n = normalize(vec3(1,g,0));
        float d = 0;
        vec3 p = abs(ray-ico_pos);
        d = max(d, dot(p,n));
        d = max(d, dot(p,n.yzx));
        d = max(d, dot(p,n.zxy));
        ico = d-0.2;
    }

    const float repeat_scale = 0.95;
    //ray = sin(ray/repeat_scale)*repeat_scale;

    float power = cos(raylab_total_time/7)+4;

    vec3 z = ray;
    float dr = 1;
    float r;

    for (int i = 0; i < MB_ITERATIONS; i++ ) {
        r = length(z);
        if (r > 4) break;

        float theta = acos(z.z/r);
        float phi = atan(z.y, z.x);
        dr = pow(r, power-1)*power*dr + 1;

        float zr = pow(r, power);
        theta *= power;
        phi *= power;

        z = zr * vec3(
            sin(theta)*cos(phi),
            sin(phi)*sin(theta),
            cos(theta)
        );
        z += ray;
    }
    float mandel = 0.5 * log(r)*r/dr;

    // return mandel;
    return min(min(mandel, sphere), min(box, ico));
    // return min(sphere, min(box,ico));
}

vec3 normal(vec3 ray, float epsilon) {
    vec3 e = vec3(epsilon, 0, 0);
    return normalize(vec3(
        scene_SDF(ray+e.xyy) - scene_SDF(ray-e.xyy),
        scene_SDF(ray+e.yxy) - scene_SDF(ray-e.yxy),
        scene_SDF(ray+e.yyx) - scene_SDF(ray-e.yyx)
    ));
}

void main() {
    
    vec2 pixel = tex_coord * raylab_resolution;

    float viewport_width = tan(raylab_cam_fov/2)*2;
    float viewport_height = viewport_width * (raylab_resolution.y/raylab_resolution.x);

    float x_step = viewport_width  / (raylab_resolution.x - 1);
    float y_step = viewport_height / (raylab_resolution.y - 1);

    vec3 v_march = normalize(
        (x_step * (pixel.x - raylab_resolution.x/2.) * raylab_cam_local_x) +
        (y_step * (pixel.y - raylab_resolution.y/2.) * -raylab_cam_local_y) +
        raylab_cam_target
    );

    vec3 ray = raylab_cam_pos;

    int iter = 0;
    float dist = scene_SDF(ray);

    // try to change this to a for loop
    while (dist > raylab_cam_min_dist &&
          dist < raylab_cam_max_dist &&
          iter < raylab_cam_max_march) {
        
        ray += v_march * dist * 1;
        dist = scene_SDF(ray);
        iter += 1;
    }

    float dist_from_camera = length(ray - raylab_cam_pos);

    vec3 col = mix(
        vec3(1),
        abs(normal(ray, raylab_cam_min_dist)),
        float(iter)*4/float(raylab_cam_max_march)
    );

    float hit_surface = step(dist, raylab_cam_min_dist);
    vec3 surface_color = col * hit_surface + vec3(0) * (1 - hit_surface);
    gl_FragColor = vec4(mix(surface_color, vec3(0), dist_from_camera*0.04), 1);
}
