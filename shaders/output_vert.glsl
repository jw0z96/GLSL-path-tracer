#version 400

layout(location = 0) in vec2 vpos;
layout(location = 1) in vec2 st;

out vec2 o_st;

void main()
{
    o_st = st;
    gl_Position = vec4(vpos, -0.2, 1.0);
}

