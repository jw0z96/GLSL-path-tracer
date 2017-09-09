#version 400 core

in vec2 o_uv; // UV COORDS PASSED BY VERT SHADER

uniform int width; // IMAGE WIDTH
uniform int height; // IMAGE HEIGHT
uniform int frameCount; // NUMBER OF SAMPLES
uniform sampler2D accumulatedTex; // TEXTURE CONTAINING THE ACCUMULATED SAMPLES

layout(location = 0) out vec4 totalColor; // THE COLOR TO WRITE TO THE ACCUMULATED TEXTURE
layout(location = 1) out vec4 displayColor; // THE COLOR TO DISPLAY ONSCREEN

float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main()
{
    vec3 col = vec3(
        clamp(rand(o_uv+vec2(frameCount)), 0.0, 1.0),
        clamp(rand(10.0*o_uv-vec2(frameCount)), 0.0, 1.0),
        clamp(rand(2.0*o_uv*vec2(-frameCount)), 0.0, 1.0)
        ); // THIS IS THE COLOR VARIABLE TO MANIPULATE
    
    vec3 outCol = mix(texture(accumulatedTex, o_uv).rgb, col, 1.0/float(frameCount));
    totalColor = vec4(outCol, 1.0);
    displayColor = vec4(outCol, 1.0);
}
