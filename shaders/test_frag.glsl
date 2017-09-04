#version 400 core

in vec2 o_uv; // UV COORDS PASSED BY VERT SHADER

uniform int width; // IMAGE WIDTH
uniform int height; // IMAGE HEIGHT
uniform int frameCount; // NUMBER OF SAMPLES
uniform sampler2D accumulatedTex; // TEXTURE CONTAINING THE ACCUMULATED SAMPLES

layout(location = 0) out vec4 totalColor; // THE COLOR TO WRITE TO THE ACCUMULATED TEXTURE
layout(location = 1) out vec4 displayColor; // THE COLOR TO DISPLAY ONSCREEN

const float PI = 3.14159265358979323846264338327950288;
const int MAX_DEPTH = 3;
const float MAX_DRAW_DIST = 100000.0;

struct Ray
{
    vec3 origin, direction;
};

struct Sphere
{
    float radius;
    vec3 center;
};

Sphere m_spheres[2] = Sphere[](Sphere(1.0, vec3(0.0)), Sphere(1.0, vec3(0.0, 2.0, 0.0)));

float intersectSphere(Ray ray, Sphere sphere)
{
    vec3 rc = ray.origin-sphere.center;
    float c = dot(rc, rc) - (sphere.radius*sphere.radius);
    float b = dot(ray.direction, rc);
    float d = b*b - c;
    float t = -b - sqrt(abs(d));
    float st = step(0.0, min(t,d));
    return mix(-1.0, t, st);
}

// INTERSECT THE SCENE, RETURNS DISTANCE & OBJECT INDEX
vec2 intersectScene(Ray ray)
{
    float dist = MAX_DRAW_DIST;
    int hitObject = -1; //RETURN -1 IF NO HIT

    for (int i=0; i<m_spheres.length(); ++i)
    {
        float currentDist = intersectSphere(ray, m_spheres[i]);
        if (currentDist > 0.0 && currentDist < dist)
        {
            dist = currentDist;
            hitObject = i;
        }
    }

    return vec2(dist, float(hitObject));
}

vec3 calcPixelColor()
{
    vec2 uv = o_uv*2 - 1.0;
    float fov = 60;
    /* float invWidth = 1.0/float(width); */
    /* float invHeight = 1.0/float(height); */
    /* float aspectRatio = width/float(height); */
    /* float angle = tan(PI * 0.5 * fov / 180.0); */
   
    vec3 rayOrigin = vec3(0.0, 0.0, -2.0);
    vec3 rayDir = normalize(vec3(uv, 1.0));
    Ray ray = Ray(rayOrigin, rayDir);

    vec3 totalLight = vec3(0.0);
    vec3 factorLight = vec3(1.0);

    for (int depth = 0; depth < MAX_DEPTH; ++depth)
    {
        vec2 worldInfo = intersectScene(ray);
        float dist = worldInfo.x;
        int objectIndex = int(worldInfo.y);

        if (objectIndex >= 0) // IF WE HIT AN OBJECT
        {
            totalLight += vec3(dist/5);
        }
        else // IF WE HIT THE BACKGROUND
        {

        }
    }
    
    return totalLight;
}

void main()
{
    vec3 col = calcPixelColor(); // THIS IS THE COLOR VARIABLE TO MANIPULATE
    vec3 outCol = col + texture(accumulatedTex, o_uv).rgb;
    totalColor = vec4(outCol, 1.0);
    float mult = float(1.0/frameCount); // REDUCE THE TOTAL SAMPLES TO A DISPLAYABLE RANGE
    displayColor = vec4(outCol*mult, 1.0);
}

