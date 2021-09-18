// __multiversion__

/*

/////D O N ' T  S T E A L  A N Y C O D E S !!!!

///Made by Glin Shady
///You must follow "GRES licence"

/////D O N ' T  S T E A L  A N Y C O D E S !!!!

*/



#ifdef GL_FRAGMENT_PRECISION_HIGH
#define Hme highp
#else
#define Hme mediump
#endif

#define h1 Hme float
#define h2 Hme vec2
#define h3 Hme vec3
#define h4 Hme vec4

#define saturate(x) clamp(x,0.,1.)


#include "vertexVersionCentroid.h"
#if __VERSION__ >= 300
	#ifndef BYPASS_PIXEL_SHADER
		_centroid out vec2 uv0;
		_centroid out vec2 uv1;
	#endif
#else
	#ifndef BYPASS_PIXEL_SHADER
		varying vec2 uv0;
		varying vec2 uv1;
	#endif
#endif

#ifndef BYPASS_PIXEL_SHADER
	varying vec4 color;
	varying h1 t;
	varying h3 eye;
	varying h3 weye;
	varying h3 seye;
	varying float iswater;
	varying float isalpha;
#endif

#ifdef FOG
	varying vec4 fogColor;
#endif

#include "uniformWorldConstants.h"
#include "uniformPerFrameConstants.h"
#include "uniformShaderConstants.h"
#include "uniformRenderChunkConstants.h"

attribute POS4 POSITION;
attribute vec4 COLOR;
attribute vec2 TEXCOORD_0;
attribute vec2 TEXCOORD_1;

uniform highp float TOTAL_REAL_WORLD_TIME;

const float rA = 1.0;
const float rB = 1.0;
const vec3 UNIT_Y = vec3(0,1,0);
const float DIST_DESATURATION = 56.0 / 255.0; //WARNING this value is also hardcoded in the water color, don'tchange

void main()
{

#ifndef BYPASS_PIXEL_SHADER
    uv0 = TEXCOORD_0;
    uv1 = TEXCOORD_1;
	color = COLOR;
#endif

    POS4 worldPos;
    iswater=0.0;
    
    POS3 p=POSITION.xyz;
	POS3 mp=mod(p,16.);
	t=mod(TOTAL_REAL_WORLD_TIME,1024.);
	
bool getwater = (color.a < .95&&color.a>.05);
    
    #ifdef ALLOW_FADE
p.y+=-64.*saturate(RENDER_CHUNK_FOG_ALPHA);
	#endif
#ifdef AS_ENTITY_RENDERER
		POS4 pos = WORLDVIEWPROJ * p;
		worldPos = pos;
#else
    worldPos.xyz = (p.xyz * CHUNK_ORIGIN_AND_SCALE.w) + CHUNK_ORIGIN_AND_SCALE.xyz;
    worldPos.w = 1.0;

    // Transform to view space before projection instead of all at once to avoid floating point errors
    // Not required for entities because they are already offset by camera translation before rendering
    // World position here is calculated above and can get huge
    
    if(getwater==true){
    worldPos.y-=sin(t*5.3+mp.x*1.3+mp.y+mp.z*1.4)*.08*uv1.y;
    }
    if(color.a==0.){
    worldPos.x+=sin(t*1.1+mp.x+mp.y+mp.z)*.03*uv1.y;
    }
    POS4 pos = WORLDVIEW * worldPos;
    pos = PROJ * pos;
#endif
    gl_Position = pos;
    eye=POSITION.xyz;
    weye=worldPos.xyz;
	seye.xy=pos.xy/(pos.z+1.);
	seye.z=pos.z;
    
#if defined(ALPHA_TEST)
iswater=0.0;
isalpha=1.;
#else
isalpha=0.;
#endif

///// find distance from the camera

#if defined(FOG) || defined(BLEND)
	#ifdef FANCY
		vec3 relPos = -worldPos.xyz;
		float cameraDepth = length(relPos);
	#else
		float cameraDepth = pos.z;
	#endif
#endif

#ifdef FOG
	float len = cameraDepth / RENDER_DISTANCE;
	#ifdef ALLOW_FADE
		len += RENDER_CHUNK_FOG_ALPHA;
	#endif

    fogColor.rgb = FOG_COLOR.rgb;
	fogColor.a = saturate((len - FOG_CONTROL.x) / (FOG_CONTROL.y - FOG_CONTROL.x));
#endif

///// blended layer (mostly water) magic
#if defined(BLEND)&&!defined(ALPHA_TEST)
	//Mega hack: only things that become opaque are allowed to have vertex-driven transparency in the Blended layer...
	//to fix this we'd need to find more space for a flag in the vertex format. color.a is the only unused part
	if(getwater==true) {
			float cameraDist = cameraDepth / FAR_CHUNKS_DISTANCE;
			color = COLOR;
			iswater=1.0;
			isalpha=0.;
		float alphaFadeOut = saturate(cameraDist);
		color.a = mix(color.a, 1.0, alphaFadeOut);
	}
#endif

#ifndef BYPASS_PIXEL_SHADER
	#ifndef FOG
		// If the FOG_COLOR isn't used, the reflection on NVN fails to compute the correct size of the constant buffer as the uniform will also be gone from the reflection data
		color.rgb += FOG_COLOR.rgb * 0.000001;
	#endif
#endif
}
