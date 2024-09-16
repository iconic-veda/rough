#version 460 core

in vec3 near_point;
in vec3 far_point;

in mat4 frag_view;
in mat4 frag_proj;

out vec4 FragColor;

// Reference: https://asliceofrendering.com/scene%20helper/2020/01/05/InfiniteGrid/

vec4 grid(vec3 frag_pos_3d, float scale) {
    vec2 coord = frag_pos_3d.xz * scale;
    vec2 derivative = fwidth(coord);
    vec2 grid = abs(fract(coord - 0.5) - 0.5) / derivative;
    float line = min(grid.x, grid.y);
    float minimumz = min(derivative.y, 1);
    float minimumx = min(derivative.x, 1);
    vec4 color = vec4(0.2, 0.2, 0.2, 1.0 - min(line, 1.0));
    if (frag_pos_3d.x > -0.1 * minimumx && frag_pos_3d.x < 0.1 * minimumx)
        color.z = 1.0;
    if (frag_pos_3d.z > -0.1 * minimumz && frag_pos_3d.z < 0.1 * minimumz)
        color.x = 1.0;
    return color;
}

float compute_depth(vec3 pos) {
    vec4 clip_space_pos = frag_proj * frag_view * vec4(pos, 1.0);
    return clip_space_pos.z / clip_space_pos.w;
}

float compute_linear_depth(vec3 pos) {
    float far = 100.0;
    float near = 0.1;

    vec4 clip_space_pos = frag_proj * frag_view * vec4(pos, 1.0);
    float clip_space_depth = (clip_space_pos.z / clip_space_pos.w) * 2.0 + 1.0;
    float linear_depth = (2.0 * near * far) / (far + near - clip_space_depth * (far - near));
    return linear_depth / far;
}

void main() {
    float t = -near_point.y / (far_point.y - near_point.y);
    vec3 frag_pos_3d = near_point + t * (far_point - near_point);
    gl_FragDepth = compute_depth(frag_pos_3d);

    float linear_depth = compute_linear_depth(frag_pos_3d);
    float fading = max(0, (0.5 - linear_depth));

    // This add multiple resolutions for the grid
    FragColor = (grid(frag_pos_3d, 10) + grid(frag_pos_3d, 1)) * float(t > 0);
    FragColor.a *= fading;
}
