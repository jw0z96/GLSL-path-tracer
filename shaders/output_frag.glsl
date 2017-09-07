#version 400

in vec2 o_st;
uniform sampler2D input_texture;

out vec4 frag_colour;

vec3 ACESFilm(vec3 x)
{
    float a = 2.51f;
    float b = 0.03f;
    float c = 2.43f;
    float d = 0.59f;
    float e = 0.14f;
    return clamp((x*(a*x+b))/(x*(c*x+d)+e), 0.0, 1.0);
}

void main ()
{
    /* if (o_st.x > 0.5) */
        frag_colour = vec4(ACESFilm(texture(input_texture, o_st).rgb), 1.0);
    /* else */
        /* frag_colour = texture(input_texture, o_st); */
}

