#version 400 core

in vec2 o_uv; // UV COORDS PASSED BY VERT SHADER

uniform mat4 V;
uniform mat4 P;

uniform int width; // IMAGE WIDTH
uniform int height; // IMAGE HEIGHT
uniform int frameCount; // NUMBER OF SAMPLES
uniform sampler2D accumulatedTex; // TEXTURE CONTAINING THE ACCUMULATED SAMPLES

layout(location = 0) out vec4 totalColor; // THE COLOR TO WRITE TO THE ACCUMULATED TEXTURE
layout(location = 1) out vec4 displayColor; // THE COLOR TO DISPLAY ONSCREEN

const float PI = 3.14159265358979323846264338327950288;
const int MAX_DEPTH = 4;
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
        Sphere(1.0, vec3(1.2, 1.0, 0.0)), 
        Sphere(1.0, vec3(-1.2, 1.0, 0.0)), 
        Sphere(0.4, vec3(-0.1, 0.4, -1.0)), 
        Sphere(1000.0, vec3(0.0, -1000.0, 0.0))
    );

// ARRAY OF LIGHTS
Light m_lights[] = Light[](
        Light(Sphere(0.5, vec3(1.2, 3, -1.0)), vec3(0.7))
        /* Light(Sphere(0.5, vec3(sin(frameCount/10.0), 3, cos(frameCount/10.0))), vec3(0.7)) */
    );

vec3 m_sphereColors[] = vec3[](vec3(0.6, 0.6, 0.6), vec3(0.9, 0.1, 0.1), vec3(0.0, 0.2, 0.5), vec3(0.5));

float m_roughness[] = float[](0.1, 0.6, 0.3, 0.9);

float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453 + frameCount);
}

// GETS A RANDOM UNIFORM VECTOR
vec3 uniformVector(float seed)
{
    float a = 3.141593*rand(vec2(frameCount*78.233, seed));
    float b = 6.283185*rand(vec2(frameCount*10.873, seed));
    return vec3( sin(b)*sin(a), cos(b)*sin(a), cos(a));
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

vec3 getRandomLightPoint(Light light, int iter)
{
    float rng = rand(o_uv + vec2(frameCount+iter, -iter*frameCount));
    return light.area.center + light.area.radius*normalize(uniformVector(rng));
}

vec3 getCosineDirection(float seed, vec3 nor)
{
    // compute basis from normal
    // see http://orbit.dtu.dk/fedora/objects/orbit:113874/datastreams/file_75b66578-222e-4c7d-abdf-f7e255100209/content
    // (link provided by nimitz)
    vec3 tc = vec3( 1.0+nor.z-nor.xy*nor.xy, -nor.x*nor.y)/(1.0+nor.z);
    vec3 uu = vec3( tc.x, tc.z, -nor.x );
    vec3 vv = vec3( tc.z, tc.y, -nor.y );
    
    float u = rand(vec2(frameCount*78.233, seed));
    float v = rand(vec2(frameCount*10.873, seed));
    float a = 6.283185 * v;

    return  sqrt(u)*(cos(a)*uu + sin(a)*vv) + sqrt(1.0-u)*nor;
}

// HARD CODED BRDF
vec3 getBRDFRay(vec3 incident, vec3 normal, int objectIndex)
{
    float rng = rand(vec2(-frameCount,251.0));
    float roughness = m_roughness[objectIndex];
    
    if (mod(rng, 1.0) < roughness)
    {
        return getCosineDirection(rng, normal);
    }
    else
    {
        return normalize(reflect(incident, normal) + roughness*uniformVector(rng)); 
    }
}

vec3 calculateDirectLighting(Ray surfacePoint)
{
    vec3 dcol = vec3(0.0);

    int samples = 5;

    for (int i = 0; i<m_lights.length(); ++i)
    {
        for (int j = 0; j<samples; ++j)
        {
            // get a random point on the light 
            vec3 lightPos = getRandomLightPoint(m_lights[i], j);
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
    }

    return dcol/samples;
}

vec3 calcPixelColor()
{
    vec2 uv = o_uv*2 - 1.0;
    float fov = 60;
    float invWidth = 1.0/float(width);
    float invHeight = 1.0/float(height);
    /* float aspectRatio = width/float(height); */
    /* float angle = tan(PI * 0.5 * fov / 180.0); */
   
    vec2 jitter = vec2(mod(rand(vec2(67.3-frameCount, 103+frameCount)), 1.0) - 0.5, mod(rand(vec2(95*frameCount, 1616-frameCount)), 1.0) - 0.5);
    vec2 jitterAmount = vec2(invWidth, invHeight);

    mat4 MVP = P * V * mat4(1.0);

    vec3 rayOrigin = inverse(V)[3].xyz;
    
    /* vec3 rayDir = normalize(vec3(uv, -1.0) + vec3(jitter * jitterAmount, 0.0)); */
    
    
    vec3 rayDir = vec3(uv, -1.0);

    rayDir = normalize(inverse(V) * vec4(rayDir, 0.0)).xyz;

    /* rayDir = (vec4(rayDir, 0.0) * inverse(V * P)).xyz; */

    /* vec3 rayOrigin = (vec4(1.0, 10.0, 1.0, 1.0) * V * P).xyz; */
    
    
    
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
            totalLight += intensity * vec3(0.2);
            break;
        }
        else // IF WE DID HIT OBJECT
        {
            vec3 pos = ray.origin + dist*ray.direction;
            vec3 norm = getNormal(pos, objectIndex);         
            vec3 reflectedRay = getBRDFRay(ray.direction, norm, objectIndex);
            
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
    /* vec3 outCol = col + texture(accumulatedTex, o_uv).rgb; */
    /* vec3 outCol = mix(texture(accumulatedTex, o_uv).rgb, col, 1.0/float(frameCount)); */
    vec3 outCol = mix(texture(accumulatedTex, o_uv).rgb, col, 1.0/10.0);
    /* vec3 outCol = col; */
    totalColor = vec4(outCol, 1.0);
    /* float mult = float(1.0/frameCount); // REDUCE THE TOTAL SAMPLES TO A DISPLAYABLE RANGE */
    displayColor = vec4(outCol, 1.0);
}

