#version 460 core

in vec2 fragTexCoord;
out vec4 FragColor;

uniform sampler2D texture_diffuse;

void main()
{
    FragColor = texture(texture_diffuse, fragTexCoord);
}
