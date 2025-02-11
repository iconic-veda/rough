#version 460 core

layout(location = 0) in vec3 pos;
layout(location = 1) in vec3 normal;
layout(location = 2) in vec2 tex_coord;

out vec3 frag_pos;
out vec3 frag_normal;
out vec2 frag_tex_coord;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main()
{
    frag_pos = vec3(model * vec4(pos, 1.0));
    frag_normal = mat3(transpose(inverse(model))) * normal;
    frag_tex_coord = tex_coord;

    gl_Position = projection * view * vec4(frag_pos, 1.0);
}
