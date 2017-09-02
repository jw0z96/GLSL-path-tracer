#include <SDL2/SDL.h>
#include <GL/glew.h>
#include <iostream>

#include "renderengine.h"

const int width = 512;
const int height = 512;

int main (int argc, char * arg[])
{
    // initialise SDL
    if (SDL_Init(SDL_INIT_EVERYTHING) < 0)
    {
        std::cout<<"SDL failed to initialize\n";
        return EXIT_FAILURE;
    }
    std::cout<<"SDL initialized\n";
    
    SDL_Window* window = SDL_CreateWindow(
        "GLSL Renderer", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, width, height, SDL_WINDOW_SHOWN | SDL_WINDOW_OPENGL
    );
    SDL_SetWindowPosition(window, 50, 50);
    
    SDL_GLContext gl_context = SDL_GL_CreateContext(window);
    if (!gl_context)
    {
        std::cout<<"there was an error creating the GL context\n";
    }

    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE );
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 4);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);

    SDL_DisplayMode current;
    SDL_GL_SetSwapInterval(1);
    SDL_GL_MakeCurrent(window, gl_context);
    SDL_GetWindowDisplayMode(window, &current);
    
    std::cout<<"OpenGL VERSION: "<<glGetString(GL_VERSION)<<"\n";
    std::cout<<"OpenGL RENDERER: "<<glGetString(GL_RENDERER)<<"\n";
    std::cout<<"GLSL VERSION: "<<glGetString(GL_SHADING_LANGUAGE_VERSION)<<"\n";
    std::cout<<"OpenGL VENDOR: "<<glGetString(GL_VENDOR)<<"\n";

    // sdl event variable
    SDL_Event event;

    // rendering manager object
    RenderEngine engine;
    engine.init(width, height);

    // exit flag
    bool quit = false;

    while (!quit)
    {
        while (SDL_PollEvent(&event))
        {
            if (event.type == SDL_KEYDOWN && event.key.keysym.sym == SDLK_ESCAPE)
            {
                quit = true;
            }
        }
        engine.draw();
        SDL_GL_SwapWindow(window);
        /* SDL_Delay(100); */
    }

    return EXIT_SUCCESS;
}

