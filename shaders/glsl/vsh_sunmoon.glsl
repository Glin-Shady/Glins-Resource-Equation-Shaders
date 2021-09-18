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


#include "vertexVersionCentroidUV.h"

#include "uniformWorldConstants.h"

attribute POS4 POSITION;
attribute vec2 TEXCOORD_0;

varying h3 pos;

void main()
{
pos=POSITION.xyz;


    gl_Position = WORLDVIEWPROJ * (POSITION.xyzw*vec4(4.,1.,4.,1.));

    uv = TEXCOORD_0;
}