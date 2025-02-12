#version 460 core
layout(location = 0) in vec3 aPos; // vertex position
layout(location = 1) in vec3 aNormal; // vertex normal (in object space)
layout(location = 2) in vec3 aColor; // vertex color
layout(location = 3) in vec2 aTexCoords; // texture coordinates
layout(location = 4) in vec3 aTangent; // tangent vector
layout(location = 5) in vec3 aBitangent; // bitangent vector

out VS_OUT {
    vec3 FragPos;
    vec3 FragColor;
    vec2 TexCoords;
    mat3 TBN;
} vs_out;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main()
{
    vec4 worldPos = model * vec4(aPos, 1.0);
    vs_out.FragPos = worldPos.xyz;
    vs_out.TexCoords = aTexCoords;

    vec3 T = normalize(mat3(model) * aTangent);
    vec3 B = normalize(mat3(model) * aBitangent);
    vec3 N = normalize(mat3(model) * aNormal);
    vs_out.TBN = mat3(T, B, N);

    gl_Position = projection * view * worldPos;
}
