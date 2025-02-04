#version 460 core

in vec2 frag_tex_coord;

struct Material {
    sampler2D diffuse;
    sampler2D specular;
    sampler2D normal;
    sampler2D height;
};

uniform Material material;

out vec4 FragColor;

void main()
{
    FragColor = vec4(vec3(texture(material.diffuse, frag_tex_coord)), 1.0);
}
