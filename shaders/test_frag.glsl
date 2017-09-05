#version 400 core

in vec2 o_uv; // UV COORDS PASSED BY VERT SHADER

uniform int width; // IMAGE WIDTH
uniform int height; // IMAGE HEIGHT
uniform int frameCount; // NUMBER OF SAMPLES
uniform sampler2D accumulatedTex; // TEXTURE CONTAINING THE ACCUMULATED SAMPLES

layout(location = 0) out vec4 totalColor; // THE COLOR TO WRITE TO THE ACCUMULATED TEXTURE
layout(location = 1) out vec4 displayColor; // THE COLOR TO DISPLAY ONSCREEN

const float PI = 3.14159265358979323846264338327950288;
const int MAX_DEPTH = 5;
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

struct Light
{
    Sphere area;
    vec3 intensity;
};

// ARRAY OF SPHERES (OUR GEOMETRY)
Sphere m_spheres[] = Sphere[](
        Sphere(1.0, vec3(0.0, 1.0, 0.0)), 
        Sphere(0.5, vec3(0.0, 2.0, 0.0)), 
        Sphere(100.0, vec3(0.0, -100.0, 0.0))
    );

// ARRAY OF LIGHTS
Light m_lights[] = Light[](
        Light(Sphere(10.0, vec3(2.0, 5.0, -2.0)), vec3(2.0)),
        Light(Sphere(10.0, vec3(-2.0, 5.0, -2.0)), vec3(0.5, 0.0, 0.0))
    );

vec3 m_sphereColors[] = vec3[](vec3(0.6, 0.3, 0.0), vec3(0.4, 0.4, 0.4), vec3(0.2));

float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

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

vec3 getObjectColor(vec3 pos, int objectIndex)
{
    return m_sphereColors[objectIndex];
}

vec3 getNormal(vec3 pos, int objectIndex)
{
    return normalize(pos - m_spheres[objectIndex].center);
}

vec3 getBackgroundColor(Ray ray)
{
    return mix(vec3(0.0, 0.0, 0.1), vec3(0.8, 0.8, 0.9), (ray.direction.y+1.0)/2.0);
}

vec3 getRandomLightPoint(Light light)
{
    float rng = rand(o_uv + vec2(frameCount));
    float r = mod(rng, light.area.radius);
    float l = mod(rng, 2.0*PI);
    float h = mod(rng, PI) - (PI/2.0);
    return light.area.center + vec3(r*cos(l)*cos(h), r*sin(h), r*sin(l)*cos(h));
}

vec3 calculateDirectLighting(Ray surfacePoint)
{
    vec3 dcol = vec3(0.0);

    for (int i = 0; i<m_lights.length(); ++i)
    {
        // get a random point on the light 
        vec3 lightPos = getRandomLightPoint(m_lights[i]);
        /* vec3 lightPos = m_lights[i].area.center; */

        vec3 lightVector = normalize(lightPos - surfacePoint.origin);
        vec2 shadowInfo = intersectScene(Ray(surfacePoint.origin, lightVector));

        if (shadowInfo.y < 0.0) // IF WE HIT 
        {
            // N DOT L LIGHTING
            dcol += m_lights[i].intensity * vec3(max(0.0, dot(surfacePoint.direction, lightVector)));
        }
        else 
        {
            dcol += vec3(0.0);
        }
    }

    return dcol;
}

vec3 calcPixelColor()
{
    vec2 uv = o_uv*2 - 1.0;
    float fov = 60;
    /* float invWidth = 1.0/float(width); */
    /* float invHeight = 1.0/float(height); */
    /* float aspectRatio = width/float(height); */
    /* float angle = tan(PI * 0.5 * fov / 180.0); */
   
    vec3 rayOrigin = vec3(0.0, 1.0, -3.0);
    vec3 rayDir = normalize(vec3(uv, 1.0));
    Ray ray = Ray(rayOrigin, rayDir);

    vec3 totalLight = vec3(0.0); // THE TOTAL LIGHT GATHERED
    vec3 intensity = vec3(1.0); // LIGHT INTENSITY, DECREASED WITH EACH SURFACE HIT

    for (int depth = 0; depth < MAX_DEPTH; ++depth)
    {
        vec2 worldInfo = intersectScene(ray);
        float dist = worldInfo.x;
        int objectIndex = int(worldInfo.y);

        if (objectIndex < 0) // IF WE DIDNT HIT OBJECT
        {
            intensity *= getBackgroundColor(ray);
            totalLight += intensity * vec3(0.0);
            break;
        }
        else // IF WE DID HIT OBJECT
        {
            vec3 pos = ray.origin + dist*ray.direction;
            vec3 norm = getNormal(pos, objectIndex);         
            vec3 reflectedRay = reflect(ray.direction, norm);
            vec3 scol = getObjectColor(pos, objectIndex);
            vec3 directLight = calculateDirectLighting(Ray(pos, norm));

            ray.direction = reflectedRay;
            ray.origin = pos;

            intensity *= scol; //*directLight;
            totalLight += intensity * directLight;
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

