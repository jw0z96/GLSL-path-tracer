#version 400

in vec2 o_st;
uniform sampler2D input_texture;

out vec4 frag_colour;

void main ()
{
    frag_colour = texture(input_texture, o_st);
}

