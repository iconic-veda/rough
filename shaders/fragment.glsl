#version 460 core

in vec3 frag_pos;
in vec3 frag_normal;
in vec2 frag_tex_coord;

out vec4 FragColor;

struct Material {
    sampler2D diffuse;
    sampler2D specular;
    float shininess;
};

struct DirectionalLight {
    vec3 direction;

    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

struct PointLight {
    vec3 position;

    vec3 ambient;
    vec3 diffuse;
    vec3 specular;

    float constant;
    float linear;
    float quadratic;
};

#define MAX_POINT_LIGHTS 4

uniform PointLight point_lights[MAX_POINT_LIGHTS];
uniform DirectionalLight directional_light;

uniform vec3 view_pos;
uniform Material material;

vec3 calculate_directional_light(DirectionalLight light, vec3 normal, vec3 view_dir);
vec3 calculate_point_light(PointLight light, vec3 norm, vec3 frag_pos, vec3 view_pos);

void main()
{
    vec3 norm = normalize(frag_normal);
    vec3 view_dir = normalize(view_pos - frag_pos);

    vec3 result = calculate_directional_light(directional_light, norm, view_dir);
    for (int i = 0; i < MAX_POINT_LIGHTS; i++) {
        result += calculate_point_light(point_lights[i], norm, frag_pos, view_dir);
    }

    FragColor = vec4(result, 1.0);
}

vec3 calculate_directional_light(DirectionalLight light, vec3 normal, vec3 view_dir) {
    vec3 light_direction = normalize(-light.direction);

    // Diffuse shading
    float diff = max(dot(normal, light_direction), 0.0);

    // specular
    vec3 reflect_direction = reflect(-light_direction, normal);
    float spec = pow(max(dot(view_dir, reflect_direction), 0.0), material.shininess);

    vec3 ambient = light.ambient * vec3(texture(material.diffuse, frag_tex_coord));
    vec3 diffuse = light.diffuse * diff * vec3(texture(material.diffuse, frag_tex_coord));
    vec3 specular = light.specular * spec * vec3(texture(material.specular, frag_tex_coord));

    return ambient + diffuse + specular;
}

vec3 calculate_point_light(PointLight light, vec3 normal, vec3 frag_pos, vec3 view_dir) {
    vec3 light_direction = normalize(light.position - frag_pos);

    // diffuse shading
    float diff = max(dot(normal, light_direction), 0.0);

    // specular shading
    vec3 reflect_dir = reflect(-light_direction, normal);
    float spec = pow(max(dot(view_dir, reflect_dir), 0.0), material.shininess);

    // attenuation
    float distance = length(light.position - frag_pos);
    float attenuation = 1.0 / (light.constant + light.linear * distance + light.quadratic * (distance * distance));

    vec3 ambient = light.ambient * vec3(texture(material.diffuse, frag_tex_coord));
    vec3 diffuse = light.diffuse * diff * vec3(texture(material.diffuse, frag_tex_coord));
    vec3 specular = light.specular * spec * vec3(texture(material.specular, frag_tex_coord));

    ambient *= attenuation;
    diffuse *= attenuation;
    specular *= attenuation;

    return ambient + diffuse + specular;
}
