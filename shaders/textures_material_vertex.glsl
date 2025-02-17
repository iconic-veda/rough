#version 460 core
layout(location = 0) in vec3 aPos; // vertex position
layout(location = 1) in vec3 aNormal; // vertex normal (in object space)
layout(location = 2) in vec3 aColor; // vertex color
layout(location = 3) in vec2 aTexCoords; // texture coordinates
layout(location = 4) in vec3 aTangent; // tangent vector
layout(location = 5) in vec3 aBitangent; // bitangent vector
layout(location = 6) in ivec4 aBoneIds; // bone ids
layout(location = 7) in vec4 aWeights; // bone weights

out VS_OUT {
    vec3 FragPos;
    vec3 FragColor;
    vec2 TexCoords;
    mat3 TBN;
} vs_out;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

const int MAX_BONES = 1000;
const int MAX_BONE_INFLUENCE = 4;
uniform mat4 finalBonesMatrices[MAX_BONES];

uniform float hasAnimation;

void main()
{
    vec4 worldPos;
    vec4 totalPosition = vec4(0.0f);
    if (hasAnimation == 1.0) {
        for (int i = 0; i < MAX_BONE_INFLUENCE; i++)
        {
            if (aBoneIds[i] == -1)
                continue;
            if (aBoneIds[i] >= MAX_BONES)
            {
                totalPosition = vec4(aPos, 1.0f);
                break;
            }
            vec4 localPosition = finalBonesMatrices[aBoneIds[i]] * vec4(aPos, 1.0f);
            totalPosition += localPosition * aWeights[i];
            // vec3 localNormal = mat3(finalBonesMatrices[aBoneIds[i]]) * aNormal;
        }
        worldPos = model * totalPosition;
    } else {
        worldPos = model * vec4(aPos, 1.0);
    }

    vs_out.FragPos = worldPos.xyz;
    vs_out.FragColor = aColor;
    vs_out.TexCoords = aTexCoords;

    vec3 T = normalize(mat3(model) * aTangent);
    vec3 B = normalize(mat3(model) * aBitangent);
    vec3 N = normalize(mat3(model) * aNormal);
    vs_out.TBN = mat3(T, B, N);

    gl_Position = projection * ((view * model) * totalPosition);
}
