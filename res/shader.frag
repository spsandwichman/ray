#version 330

in vec2 fragTexCoord;

out vec4 finalColor;

uniform vec2 resolution;
uniform float total_time; // elapsed seconds since raylib initWindow()
uniform float delta_time; // elapsed seconds since last frame drawn

uniform vec3  c_pos;
uniform vec3  c_rot;
uniform float c_fov;
uniform float c_min_dist;
uniform float c_max_dist;
uniform int   c_max_march;

int MB_ITERATIONS = 20;
const float PI = 3.14159265358979;

void rotate_camera(out vec3 target, out vec3 local_x, out vec3 local_y) {
    
    mat3 rot = mat3(
        1.,       0.,            0.,
        0.,  cos(c_rot.x), sin(c_rot.x),
        0., -sin(c_rot.x), cos(c_rot.x)
    ) * mat3(
         cos(c_rot.y), 0., sin(c_rot.y),
             0.,       1.,     0.,
        -sin(c_rot.y), 0., cos(c_rot.y)
    ) * mat3(
         cos(c_rot.z), sin(c_rot.z), 0.,
        -sin(c_rot.z), cos(c_rot.z), 0.,
              0.,           0.,      1.
    );

    target  = rot * vec3(0., 0., -1.);
    local_x = rot * vec3(1., 0., 0.);
    local_y = rot * vec3(0., 1., 0.);
}

float vmax(vec3 v) {
    return max(max(v.x, v.y), v.z);
}

float scene_SDF(vec3 ray) {

    vec3 sphere_pos = vec3(
        sin(total_time),
        sin(total_time+2*PI/3),
        sin(total_time+4*PI/3)
    );
    float sphere = length(ray-sphere_pos)-0.2;

    vec3 box_pos = vec3(
        -cos(total_time),
        cos(total_time+2*PI/3),
        cos(total_time+4*PI/3)
    );
    float box = vmax(abs(ray-box_pos)-vec3(0.2));

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

    const float repeat_scale = 1;
    ray = sin(ray/repeat_scale)*repeat_scale;

    float power = cos(total_time/3.23)+4;

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

    return min(min(mandel, sphere), min(box, ico));
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

    // Normalized pixel coordinates (from 0 to 1)
    vec2 pixel = fragTexCoord * resolution;

    float viewport_width = tan(c_fov/2)*2;
    float viewport_height = viewport_width * (resolution.y/resolution.x);

    float x_step = viewport_width  / (resolution.x - 1);
    float y_step = viewport_height / (resolution.y - 1);

    vec3 target, local_x, local_y;
    rotate_camera(target, local_x, local_y);

    vec3 v_march = normalize(
        (x_step * (pixel.x - resolution.x/2.) * local_x) +
        (y_step * (pixel.y - resolution.y/2.) * -local_y) +
        target
    );

    vec3 ray = c_pos;

    int iter = 0;
    float dist = scene_SDF(ray);

    while (dist > c_min_dist &&
          dist < c_max_dist &&
          iter < c_max_march) {
        
        ray += v_march * dist;
        dist = scene_SDF(ray);
        iter += 1;
    }

    vec3 range = mix(
        vec3(58, 134, 255)/255.,
        vec3(255, 0, 110)/255.,
        float(iter)/float(c_max_march)*1.8
    );

    vec3 col = mix(
        vec3(0),
        abs(normal(ray, c_min_dist))*1.3,
        float(iter)/float(c_max_march)
    );

    float cond = step(dist, c_min_dist);
    finalColor = vec4(col * cond, 1.) + vec4(1.) * (1-cond);
}