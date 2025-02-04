#version 460 core

layout(location = 0) in vec3 pos;
layout(location = 1) in vec3 normal;
layout(location = 2) in vec2 tex_coord;

out vec2 frag_tex_coord;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main()
{
    frag_tex_coord = tex_coord;

    gl_Position = projection * view * model * vec4(pos, 1.0);
}
