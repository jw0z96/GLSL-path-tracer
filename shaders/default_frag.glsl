#version 400 core

in vec2 o_uv; // UV COORDS PASSED BY VERT SHADER

uniform int width; // IMAGE WIDTH
uniform int height; // IMAGE HEIGHT
uniform int frameCount; // NUMBER OF SAMPLES
uniform sampler2D accumulatedTex; // TEXTURE CONTAINING THE ACCUMULATED SAMPLES

layout(location = 0) out vec4 totalColor; // THE COLOR TO WRITE TO THE ACCUMULATED TEXTURE
layout(location = 1) out vec4 displayColor; // THE COLOR TO DISPLAY ONSCREEN

void main()
{
    vec2 circleCenter = vec2(sin(frameCount/10.0), cos(frameCount/10.0))*0.5 + 0.5;
    vec2 uv = o_uv - circleCenter;
    float circle_radius = 0.2;
    float border = 0.01;

    vec3 col = vec3(0.0); // THIS IS THE COLOR VARIABLE TO MANIPULATE

    float dist =  sqrt(dot(uv, uv));
    if ( (dist > (circle_radius+border)) || (dist < (circle_radius-border)) )
        col = vec3(0.0);
    else
        col = vec3(frameCount/10.0) * vec3(o_uv,0.0);

    vec3 outCol = col + texture(accumulatedTex, o_uv).rgb;
    totalColor = vec4(outCol, 1.0);
    
    float mult = float(1.0/frameCount); // REDUCE THE TOTAL SAMPLES TO A DISPLAYABLE RANGE
    displayColor = vec4(outCol*mult, 1.0);
}

