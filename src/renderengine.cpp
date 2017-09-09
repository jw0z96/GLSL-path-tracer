#include <GL/glew.h>
#include <glm/gtc/type_ptr.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <vector>
#include <iostream>
#include <fstream>

#include "renderengine.h"

// CTOR
RenderEngine::RenderEngine()
{
}

// DTOR
RenderEngine::~RenderEngine()
{
    glDeleteFramebuffers(1, &pingPongFBO0);
    glDeleteFramebuffers(1, &pingPongFBO0);
}

// INIT FRAMEBUFFERS AND TEXTURES
void RenderEngine::init(unsigned int width, unsigned int height, std::string fileName)
{
    m_width = width; 
    m_height = height;
    frameCount = 1;

    glewInit();

    std::vector<GLfloat> texData(m_width * m_height * 4, 0);

    // GENERATE FRAMEBUFFER OBJECTS AND TEXTURES
    glGenFramebuffers(1, &pingPongFBO0);
    glBindFramebuffer(GL_FRAMEBUFFER, pingPongFBO0);
    glEnable(GL_TEXTURE_2D);

    glGenTextures(1, &pingPongAccumTex0);
    glBindTexture(GL_TEXTURE_2D, pingPongAccumTex0);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F, m_width, m_height, 0, GL_RGBA, GL_FLOAT, texData.data());
    glFramebufferTexture2D( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, pingPongAccumTex0, 0);

    glGenTextures(1, &pingPongOutputTex);
    glBindTexture(GL_TEXTURE_2D, pingPongOutputTex);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F, m_width, m_height, 0, GL_RGBA, GL_FLOAT, texData.data());
    glFramebufferTexture2D( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT1, GL_TEXTURE_2D, pingPongOutputTex, 0);

    GLenum pingPong0_drawBuffs[] = {GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1};
    glDrawBuffers(2, pingPong0_drawBuffs);
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE)
    {
        std::cout<<"pingPongFBO0 initialised correctly\n";
    }

    glGenFramebuffers(1, &pingPongFBO1);
    glBindFramebuffer(GL_FRAMEBUFFER, pingPongFBO1);
    glEnable(GL_TEXTURE_2D);

    glGenTextures(1, &pingPongAccumTex1);
    glBindTexture(GL_TEXTURE_2D, pingPongAccumTex1);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F, m_width, m_height, 0, GL_RGBA, GL_FLOAT, texData.data());
    glFramebufferTexture2D( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, pingPongAccumTex1, 0);

    glGenTextures(1, &pingPongOutputTex);
    glBindTexture(GL_TEXTURE_2D, pingPongOutputTex);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F, m_width, m_height, 0, GL_RGBA, GL_FLOAT, texData.data());
    glFramebufferTexture2D( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT1, GL_TEXTURE_2D, pingPongOutputTex, 0);

    GLenum pingPong1_drawBuffs[] = {GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1};
    glDrawBuffers(2, pingPong0_drawBuffs);
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE)
    {
        std::cout<<"pingPongFBO1 initialised correctly\n";
    }
    
    // UNBIND FBO
    glBindFramebuffer(GL_FRAMEBUFFER, 0);

    // SCREEN SPACE QUAD ATTRIBS
    float screenSpaceQuadPosArray[] = {
        -1.0, -1.0,
        1.0, -1.0,
        1.0, 1.0,
        1.0, 1.0,
        -1.0, 1.0,
        -1.0, -1.0
    };
    
    float screenSpaceQuadUVArray[] = {
        0.0, 0.0,
        1.0, 0.0,
        1.0, 1.0,
        1.0, 1.0,
        0.0, 1.0,
        0.0, 0.0
    };

    glGenBuffers(1, &screenSpaceQuadVBO);
    glBindBuffer(GL_ARRAY_BUFFER, screenSpaceQuadVBO);
    glBufferData(GL_ARRAY_BUFFER, 12 * sizeof(float), &screenSpaceQuadPosArray, GL_STATIC_DRAW);
    glGenBuffers(1, &screenSpaceQuadUVs);
    glBindBuffer(GL_ARRAY_BUFFER, screenSpaceQuadUVs);
    glBufferData(GL_ARRAY_BUFFER, 12 * sizeof(float), &screenSpaceQuadUVArray, GL_STATIC_DRAW);
    glGenVertexArrays(1, &screenSpaceQuadVAO);
    glBindVertexArray(screenSpaceQuadVAO);
    glBindBuffer(GL_ARRAY_BUFFER, screenSpaceQuadVBO);
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, screenSpaceQuadUVs);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(1);

    // SHADER SETUP
    userShader  = shaderCompile("shaders/pt_vert.glsl", fileName.c_str());
    outputShader = shaderCompile("shaders/output_vert.glsl", "shaders/output_frag.glsl");
}

// DRAWING FUNCTION
void RenderEngine::draw()
{
    glUseProgram(userShader);

    glm::vec3 pos = glm::vec3(
            3.0 * sin((float)frameCount/100.0f), 
            2.0f, 
            3.0 * cos((float)frameCount/100.0f)
            );
    glm::vec3 target = glm::vec3(0.0f, 0.0f, 0.0f);
    glm::vec3 up = glm::vec3(0.0f, 1.0f, 0.0f);
    glm::mat4 m_V = glm::lookAt(pos, target, up);

    glm::mat4 m_P = glm::perspective(35.0f, (float)m_width / (float)m_height, 0.1f, 1000.0f);

    glUniformMatrix4fv(glGetUniformLocation(userShader, "V"), 1, false, glm::value_ptr(m_V));
    glUniformMatrix4fv(glGetUniformLocation(userShader, "P"), 1, false, glm::value_ptr(m_P));
 
    glm::mat4 i_V = glm::inverse(m_V);

/*     std::cout<<"----\n"; */
/*     for (int i = 0; i<4; ++i) */
/*     { */
/*         for (int j = 0; j<4; ++j) */
/*         { */
/*             std::cout<<i_V[j][i]<<", "; */
/*         } */
/*         std::cout<<"\n"; */
/*     } */
    
    if(frameCount%2 == 0)
    {
        glBindFramebuffer(GL_FRAMEBUFFER, pingPongFBO0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);        
        glViewport(0, 0, m_width, m_height);
            
        glUniform1i(glGetUniformLocation(userShader, "width"), m_width);
        glUniform1i(glGetUniformLocation(userShader, "height"), m_height);
        glUniform1i(glGetUniformLocation(userShader, "frameCount"), frameCount);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture (GL_TEXTURE_2D, pingPongAccumTex1);
        glUniform1i(glGetUniformLocation(userShader,"accumulatedTex"), 0);
        glDrawArrays(GL_TRIANGLES, 0, 6);
    } 
    else
    {
        glBindFramebuffer(GL_FRAMEBUFFER, pingPongFBO1);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glViewport(0, 0, m_width, m_height);
        
        glUniform1i(glGetUniformLocation(userShader, "width"), m_width);
        glUniform1i(glGetUniformLocation(userShader, "height"), m_height);
        glUniform1i(glGetUniformLocation(userShader, "frameCount"), frameCount);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, pingPongAccumTex0);
        glUniform1i(glGetUniformLocation(userShader,"accumulatedTex"), 0);
        glDrawArrays(GL_TRIANGLES, 0, 6);
    }

    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    drawToScreen(screenSpaceQuadVAO, pingPongOutputTex);

    frameCount++;
    /* std::cout<<"frameCount: "<<frameCount<<"\n"; */
}

unsigned int RenderEngine::shaderCompile(const char* vertSource, const char* fragSource)
{
    int vertStatus = -1;
    int fragStatus = -1;
    
    unsigned int vertShader = glCreateShader(GL_VERTEX_SHADER);
    std::string vertSourceString = stringFromFile(vertSource);
    const GLchar* vertSourceStringGL = vertSourceString.c_str();
    glShaderSource(vertShader, 1, &vertSourceStringGL, NULL);
    glCompileShader(vertShader);
    glGetShaderiv(vertShader, GL_COMPILE_STATUS, &vertStatus);
    if(vertStatus != GL_TRUE)
    {
        int length;
        char buffer[1000];
        glGetShaderInfoLog(vertShader, sizeof(buffer), &length, buffer);
        printf("Vertex Shader ID:%i OpenGL Shader Compile Error at %s", vertShader, buffer);
        printf("Vertex Shader ID:%i OpenGL Shader Compile Error at %s", vertShader, buffer);
    }

    unsigned int fragShader = glCreateShader(GL_FRAGMENT_SHADER);
    std::string fragSourceString = stringFromFile(fragSource);
    const GLchar* fragSourceStringGL = fragSourceString.c_str();
    glShaderSource(fragShader, 1, &fragSourceStringGL, NULL);
    glCompileShader(fragShader);
    glGetShaderiv(fragShader, GL_COMPILE_STATUS, &fragStatus);
    if(fragStatus != GL_TRUE)
    {
        int length;
        char buffer[1000];
        glGetShaderInfoLog(fragShader, sizeof(buffer), &length, buffer);
        printf("Fragment Shader ID:%i OpenGL Shader Compile Error at %s\\n", fragShader, buffer);
        printf("Fragmemt Shader ID:%i OpenGL Shader Compile Error at %s\\n", fragShader, buffer);
        
    }

    unsigned int program = glCreateProgram();
    glAttachShader(program, fragShader);
    glAttachShader(program, vertShader);
    glLinkProgram(program);
    glDeleteShader(vertShader);
    glDeleteShader(fragShader);

    return program;  
}

void RenderEngine::drawToScreen(unsigned int vao, unsigned int texture)
{
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    glUseProgram(outputShader);
    glUniform1i(glGetUniformLocation(outputShader, "input_texture"), 0);
    glBindVertexArray(vao);
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

std::string RenderEngine::stringFromFile(const GLchar* pathToFile)
{
    std::string content;
    std::ifstream fileStream(pathToFile, std::ios::in);

    if(!fileStream.is_open()) {
        std::cerr << "Could not read file " << pathToFile << ". File does not exist." << std::endl;
        return "";
    }

    std::string line = "";
    while(!fileStream.eof()) {
        std::getline(fileStream, line);
        content.append(line + "\n");
    }

    fileStream.close();
    /* std::cout << "'" << content << "'" << std::endl; */
    return content;
}

