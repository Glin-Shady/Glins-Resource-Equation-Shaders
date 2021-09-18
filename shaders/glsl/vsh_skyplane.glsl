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



#include "vertexVersionSimple.h"

#include "uniformWorldConstants.h"
#include "uniformPerFrameConstants.h"
#include "uniformShaderConstants.h"

attribute mediump vec4 POSITION;
attribute vec4 COLOR;

varying vec4 cc;
varying float cr;
varying h3 eye;

const float fogNear = 0.3;

void main()
{
POS4 pos = POSITION;
pos.y -= length(pos.xyz)*.23;
    gl_Position = WORLDVIEWPROJ * pos;
    cc=CURRENT_COLOR;
    cr=COLOR.r;
    eye=POSITION.xyz;
}