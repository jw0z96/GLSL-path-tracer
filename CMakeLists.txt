cmake_minimum_required(VERSION 3.0)

set(CMAKE_BUILD_TYPE Debug)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14 -lGL -lGLEW")

project(GLSLRenderer)

add_executable(
    ${PROJECT_NAME}
    src/main.cpp
    src/renderengine.cpp
)

set(INCLUDE_DIR $(GLSLRenderer_SOURCE_DIR)/include)

INCLUDE(FindPkgConfig)

PKG_SEARCH_MODULE(SDL2 REQUIRED sdl2)

INCLUDE_DIRECTORIES(${SDL2_INCLUDE_DIRS} ${INCLUDE_DIR})

TARGET_LINK_LIBRARIES(${PROJECT_NAME} ${SDL2_LIBRARIES} ${OPENGL_LIBRARIES})

