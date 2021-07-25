// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.



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

#include "vertexVersionCentroidUV.h"

#include "uniformWorldConstants.h"
#include "uniformPerFrameConstants.h"
#include "uniformShaderConstants.h"
#include "uniformRenderChunkConstants.h"

LAYOUT_BINDING(0) uniform sampler2D TEXTURE_0;
LAYOUT_BINDING(1) uniform sampler2D TEXTURE_1;

attribute POS4 POSITION;
attribute vec2 TEXCOORD_0;
varying Hme vec3 wp;
varying Hme vec3 lpos;
varying vec4 vs;
varying vec3 ps;

uniform highp float TOTAL_REAL_WORLD_TIME;
void main()
{
//vec4 rotate = POSITION;
//rotate.xz *= mat2(cos(t*13.8), -sin(t*13.8), sin(t*13.8), cos(t*13.8));
wp = POSITION.xyz;
//float wtime = texture2D(TEXTURE_1, vec2(0,1)).r;
vec4 s_pos=POSITION;
s_pos.xz*=vec2(10,9.5);
s_pos.x-=0.5;
POS4 pos=POSITION;
pos.x-=.2;
lpos = (vec4(pos.xyz*8.0, 3.) * WORLDVIEWPROJ).xyz;
//s_pos.x-=1.4;

    gl_Position = WORLDVIEWPROJ * s_pos;
    
    vs = POSITION * WORLDVIEWPROJ;
ps = POSITION.xyz;

    uv = TEXCOORD_0;
}