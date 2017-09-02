#version 400 core

in vec2 o_st;

uniform int width;
uniform int height;
uniform int frame_count;
uniform vec3 cam_pos;
uniform sampler2D accumulated;

layout(location = 0) out vec4 gc_color;
layout(location = 1) out vec4 t_color;

float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main()
{
    vec3 col = vec3(min(frame_count/100.0, 1.0), min((frame_count-100)/200.0, 1.0), 1.0); 
    //vec3 col = vec3(rand(vec2(frame_count)*o_st), rand(vec2(frame_count)+o_st), rand(-frame_count*o_st));
    vec3 outCol = col + texture(accumulated, o_st).rgb;
    float mult = float(1.0/frame_count);
    t_color = vec4(outCol*mult, 1.0);
    gc_color = vec4(outCol, 1.0);
}

