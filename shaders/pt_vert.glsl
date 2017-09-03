#version 400

layout(location = 0)in vec2 vpos;
layout(location = 1)in vec2 uv;

smooth out vec2 o_uv;

void main()
{
    o_uv = uv;
    gl_Position = vec4(vpos, 0.0, 1.0);
}

