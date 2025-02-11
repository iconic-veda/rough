#version 460 core

in vec2 frag_tex_coord;
in vec3 frag_pos;
in vec3 frag_normal;

struct Material {
    sampler2D ambient;
    sampler2D diffuse;
    sampler2D specular;
    float shininess;

    sampler2D height;
};
uniform Material material;

uniform vec3 viewPos;

out vec4 FragColor;

void main()
{
    // ambient
    vec3 ambient = texture(material.ambient, frag_tex_coord).rgb * texture(material.diffuse, frag_tex_coord).rgb;

    // diffuse
    vec3 norm = normalize(frag_normal);
    // vec3 lightDir = normalize(light.position - frag_pos);
    // float diff = max(dot(norm, lightDir), 0.0);
    // vec3 diffuse = light.diffuse * diff * texture(material.diffuse, TexCoords).rgb;
    vec3 diffuse = texture(material.diffuse, frag_tex_coord).rgb;

    // specular
    // vec3 viewDir = normalize(viewPos - frag_pos);
    // vec3 reflectDir = reflect(-lightDir, norm);
    // float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
    vec3 specular = texture(material.specular, frag_tex_coord).rgb;

    vec3 result = ambient + diffuse + specular;
    FragColor = vec4(result, 1.0);
}
