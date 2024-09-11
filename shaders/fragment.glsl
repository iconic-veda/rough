#version 460 core

in vec3 ourColor;
out vec4 FragColor;

void main()
{
    // FragColor = vec4(1.0, 1.0, 0.0, 1.0);
    FragColor = vec4(ourColor, 1.0);
}
