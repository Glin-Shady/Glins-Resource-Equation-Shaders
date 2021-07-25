// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.



/*

/////D O N ' T  S T E A L  A N Y C O D E S !!!!

///Made by Glin Shady
///You must follow "GRES licence"

/////D O N ' T  S T E A L  A N Y C O D E S !!!!

*/



#include "vertexVersionSimple.h"

#include "uniformWorldConstants.h"
#include "uniformPerFrameConstants.h"
#include "uniformShaderConstants.h"

attribute mediump vec4 POSITION;
attribute vec4 COLOR;

varying vec4 color;
varying vec4 col;
varying highp vec3 p;
varying float fog;
varying highp vec3 cp;

const float fogNear = 10.0;

void main()
{
POS4 pos = POSITION;
pos.y -= length(pos.xyz)*0.18;

    gl_Position = WORLDVIEWPROJ * pos;
    p = POSITION.xyz;
    col = CURRENT_COLOR;
    color = COLOR;
    fog = COLOR.r;
    cp.xy = p.xy/(p.z+1.0);
	cp.z = min(1.,p.z);
    
    
}