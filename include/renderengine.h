#ifndef RENDERENGINE_H
#define RENDERENGINE_H

#include <string>

class RenderEngine
{
    public:
        // CTOR 
        RenderEngine();
        // DTOR
        ~RenderEngine();
        // DRAWING FUNCTION, GETS CALLED EACH FRAME UPDATE
        void draw();
        // INIT FRAMEBUFFERS AND TEXTURES
        void init(unsigned int width, unsigned int height);

    private:
        // IMAGE WIDTH AND HEIGHT
        unsigned int m_width, m_height;
        // COUNTER FOR THE NUMBER OF SAMPLES
        unsigned int frameCount;
        // FRAMEBUFFER OBJECTS FOR PINGPONGING
        unsigned int pingPongFBO0, pingPongFBO1;
        // TEXTURES TO ACCUMULATE ALL OF THE SAMPLES
        unsigned int pingPongAccumTex0, pingPongAccumTex1;
        // TEXTURE TO DISPLAY, GAMMA CORRECTED
        unsigned int pingPongOutputTex;
        // SCREEN SPACE QUAD VBO
        unsigned int screenSpaceQuadVBO;
        // SCREEN SPACE QUAD UVs
        unsigned int screenSpaceQuadUVs;
        // SCREEN SPACE QUAD VAO
        unsigned int screenSpaceQuadVAO;
        // SHADER PASSED BY ARG
        unsigned int userShader;
        // OUTPUT SHADER
        unsigned int outputShader;

        // COMPILE SHADER PROGRAM FROM VERTEX SHADER & FRAGMENT SHADER
        unsigned int shaderCompile(const char* vertSource, const char* fragSource);
        
        // DRAW TEXTURE ON SCREEN
        void drawToScreen(unsigned int vao, unsigned int texture);

        // FILE TO STRING HELPER
        std::string stringFromFile(const char* pathToFile);
};

#endif // RENDERENGINE_H
