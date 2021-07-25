// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.



/*

/////D O N ' T  S T E A L  A N Y C O D E S !!!!

///Made by Glin Shady
///You must follow "GRES licence"

/////D O N ' T  S T E A L  A N Y C O D E S !!!!

*/




#include "vertexVersionCentroidUV.h"

#include "uniformWorldConstants.h"

attribute POS4 POSITION;
attribute vec2 TEXCOORD_0;

varying highp vec3 p;
varying float fog;
varying vec4 gls;

void main()
{

POS4 psp = POSITION;
//psp.xz*=vec2(5,5);
//psp.xz-=length(psp.y)*0.5;
POS4 psp2=POSITION*vec4(5,1,5,1);
POS4 pos = POSITION;
pos.y -= 0.04;


    gl_Position = WORLDVIEWPROJ*POSITION;
p=POSITION.xyz;
    uv = TEXCOORD_0;
}