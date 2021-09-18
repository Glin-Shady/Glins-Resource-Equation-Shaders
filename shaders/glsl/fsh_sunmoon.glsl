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


#include "fragmentVersionCentroid.h"

#if __VERSION__ >= 300

#if defined(TEXEL_AA) && defined(TEXEL_AA_FEATURE)
_centroid in highp vec2 uv;
#else
_centroid in vec2 uv;
#endif

#else

varying vec2 uv;

#endif

varying h3 pos;

#include "uniformShaderConstants.h"
#include "util.h"

LAYOUT_BINDING(0) uniform sampler2D TEXTURE_0;
LAYOUT_BINDING(1) uniform sampler2D TEXTURE_1;

uniform vec2 FOG_CONTROL;
uniform vec4 FOG_COLOR;

float shape(h2 p,h1 blur,h1 sl){
float cc=smoothstep(sl,sl-blur,length(p));
return cc;
}

void main()
{

#if !defined(TEXEL_AA) || !defined(TEXEL_AA_FEATURE)
	vec4 alfuse = texture2D( TEXTURE_0, uv );
#else
	vec4 alfuse = texture2D_AA(TEXTURE_0, uv );
#endif
alfuse.rgb*=vec3(0);
float wtime=saturate(texture2D(TEXTURE_1,vec2(0.,1.)).r);
float israin=smoothstep(0.5,0.3,FOG_CONTROL.x);
float isdusk=min(smoothstep(0.4,0.5,wtime),smoothstep(1.,0.7,wtime))*(1.-israin);
float isdusks=saturate((FOG_COLOR.r-0.1)-FOG_COLOR.b);
float isday=smoothstep(.15,.2,FOG_COLOR.g);
float isnight=smoothstep(1.,0.2,wtime);
vec3 eye=pos;
float sunpos=mix(0.08,0.,isdusk);
float fixpos=mix(1.1,1.,isdusk);
//eye.x+=sunpos;
//eye.z*=fixpos;

float day=shape(eye.xz,mix(0.01,0.06,isday),mix(mix(0.04,0.02,isday),0.0,israin));
float dayg=shape(eye.xz,0.4,mix(mix(0.145,0.2,isdusks),0.0,israin) );
float dayg2=shape(eye.xz,0.2,mix(0.1,0.0,israin));

alfuse.rgb+=mix(vec3(0.),mix(mix(vec3(1.,.85,0.4),vec3(3),isday),vec3(1.5,1.2,0.2),isdusks),day);
alfuse.rgb+=dayg;

	gl_FragColor = alfuse;
}
