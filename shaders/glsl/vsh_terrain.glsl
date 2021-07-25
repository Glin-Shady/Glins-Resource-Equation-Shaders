// __multiversion__
//This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.
//GRES 


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

#include "vertexVersionCentroid.h"
#if __VERSION__ >= 300
	#ifndef BYPASS_PIXEL_SHADER
		_centroid out vec2 uv0;
		_centroid out vec2 uv1;
	#endif
#else
	#ifndef BYPASS_PIXEL_SHADER
		out vec2 uv0;
		out vec2 uv1;
	#endif
#endif

#ifndef BYPASS_PIXEL_SHADER
	out vec4 color;
#endif

#ifdef FOG
	out vec4 fogColor;
#endif

out Hme vec3 p;
out Hme vec3 wp;
out Hme vec2 pw;
out Hme vec3 cp;

out float iswaters;
out float rainstrength;
out float sundusk;
out float outdoor;
out float blockid;

#include "uniformWorldConstants.h"
#include "uniformPerFrameConstants.h"
#include "uniformShaderConstants.h"
#include "uniformRenderChunkConstants.h"
#include "user/g_setting.h"

uniform highp float TOTAL_REAL_WORLD_TIME;

attribute POS4 POSITION;
attribute vec4 COLOR;
attribute vec2 TEXCOORD_0;
attribute vec2 TEXCOORD_1;

const float rA = 1.0;
const float rB = 1.0;
const vec3 UNIT_Y = vec3(0,1,0);
const float DIST_DESATURATION = 56.0 / 255.0; //WARNING this value is also hardcoded in the water color, don'tchange //255

highp float hash11(highp float p)
{
	p = fract(p * .1031);
	p *= p + 33.33;
	p *= p + p;
	return fract(p);
}
highp float rand(highp vec3 p){
	highp float x = (p.x+p.y+p.z)/3.0+TOTAL_REAL_WORLD_TIME*1.2;
	return mix(hash11(floor(x)),hash11(ceil(x)),smoothstep(0.0,1.0,fract(x)));
}

bool testunder(){
if(FOG_CONTROL.x==0.&&FOG_COLOR.b>FOG_COLOR.r){
return true;
}else{
return false;
}}

void main()
{

iswaters=0.0;
    POS4 worldPos;
   #ifndef BYPASS_PIXEL_SHADER
    uv0 = TEXCOORD_0;
    uv1 = TEXCOORD_1;
	color = COLOR;
#endif

#ifdef AS_ENTITY_RENDERER
		POS4 pos = WORLDVIEWPROJ * POSITION;
		worldPos = pos;
#else
    worldPos.xyz = (POSITION.xyz * CHUNK_ORIGIN_AND_SCALE.w) + CHUNK_ORIGIN_AND_SCALE.xyz;
    worldPos.w = 1.0;


    // Transform to view space before projection instead of all at once to avoid floating point errors
    // Not required for entities because they are already offset by camera translation before rendering
    // World position here is calculated above and can get huge
    POS4 pos = WORLDVIEW * worldPos;
    pos = PROJ * pos;

#endif
gl_Position = pos;
    p = POSITION.xyz;
    wp = worldPos.xyz;
	pw = pos.xy/(pos.z+1.0);
	cp.xy = pos.xy/(pos.z+1.0);
	cp.z = min(1.,pos.z);
	
	float rain=smoothstep(0.5,0.1,FOG_CONTROL.x)*uv1.y;
	rainstrength=rain;
	sundusk=clamp((FOG_COLOR.r-0.1)-FOG_COLOR.b,0.,1.);
	outdoor=smoothstep(.5,1.,uv1.y);
	blockid=step(fract(p.y),0.5);
highp float t=TOTAL_REAL_WORLD_TIME;
highp float wave=mix(0.06,0.18,rain);
	vec3 mp=mod(p.xyz,16.);
#ifndef SEASONS
if(color.a>.05&&color.a<.95){
gl_Position.y+=sin(t*2.5+mp.x+mp.y+mp.x)*0.05;
iswaters=1.;
}
#endif
#if PLANT_WAVES == 1
#if defined(ALPHA_TEST)&&!defined(SEASONS)
if(uv1.x<0.95&&color.a==0.||color.g>color.r||uv0.y>uv0.x){gl_Position.x+=(sin(t*2.5+mp.x+mp.z+mp.y)*wave*rand(mp))*uv1.y;
iswaters=0.;}
#endif
#endif

#if UNDERWATER_WAVES == 1
if(testunder())gl_Position.x +=mix(cos(t*3.0+mp.x+mp.y+mp.x)*sin(mp.z)*0.05,cos(t*4.+mp.x+mp.y+mp.x)*1.8*sin(mp.z)*0.6,smoothstep(0.,RENDER_DISTANCE*1.,length(-wp*2.5)));
#endif

#if defined(FOG) || defined(BLEND)
	#ifdef FANCY
		vec3 relPos = -worldPos.xyz;
		float cameraDepth = length(relPos);
	#else
		float cameraDepth = pos.y;
	#endif
#endif

#ifdef BLEND
	if(color.a>.05&&color.a<.95){
		#ifdef FANCY  /////enhance water
				//iswaters=1.0;
			float cameraDist = cameraDepth / FAR_CHUNKS_DISTANCE;
			color = COLOR;
		#else
			vec4 surfColor = vec4(color.rgb, 1.0);
			color = surfColor;
				
			vec3 relPos = -worldPos.xyz;
			float camDist = length(relPos);
			float cameraDist = camDist / FAR_CHUNKS_DISTANCE;
		#endif //FANCY
		 float alphaFadeOut = clamp(cameraDist, 0., 1.0);
		color.a = mix(color.a, 1.0, alphaFadeOut);
	}
#endif

//made by @GLshading

#ifndef BYPASS_PIXEL_SHADER
	#ifndef FOG
		// If the FOG_COLOR isn't used, the reflection on NVN fails to compute the correct size of the constant buffer as the uniform will also be gone from the reflection data
		color.rgb += FOG_COLOR.rgb * 0.000001;
	#endif
#endif
}
