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

#include "fragmentVersionSimple.h"

#include "uniformShaderConstants.h"

uniform h1 TOTAL_REAL_WORLD_TIME;

varying vec4 color;

void main()
{
vec4 tex;
//tex=vec4(0);
h1 t=mod(TOTAL_REAL_WORLD_TIME,1024.);

	tex=vec4(1.4);
	gl_FragColor=CURRENT_COLOR*tex;
}