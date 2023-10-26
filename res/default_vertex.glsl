#version 330

// Input vertex attributes
in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec3 vertexNormal;
in vec4 vertexColor;


// Input uniform values
uniform mat4 mvp;
uniform vec3  c_pos;
uniform vec3  c_rot;

// Output vertex attributes (to fragment shader)
out vec2 tex_coord;

out vec3 target;
out vec3 local_x;
out vec3 local_y;

// NOTE: Add here your custom variables

void main()
{
    // Send vertex attributes to fragment shader
    tex_coord = vertexTexCoord;

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

    // Calculate final vertex position
    gl_Position = mvp*vec4(vertexPosition, 1.0);
}