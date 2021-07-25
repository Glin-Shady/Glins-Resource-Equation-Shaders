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

#define vec4_(d,e) vec4(d,e,e,1)

#include "uniformShaderConstants.h"
#include "util.h"

LAYOUT_BINDING(0) uniform sampler2D TEXTURE_0;
LAYOUT_BINDING(1) uniform sampler2D TEXTURE_1;

varying highp vec3 p;
varying float fog;
varying vec4 gls;

uniform Hme float TOTAL_REAL_WORLD_TIME;
uniform vec4 FOG_COLOR;
uniform vec2 FOG_CONTROL;
uniform float RENDER_DISTANCE;

bool night_factor(){
if(FOG_COLOR.r<0.15 && FOG_COLOR.g<0.15){
return true;
}else{
return false;
}}


void main(){
Hme float t=TOTAL_REAL_WORLD_TIME;
vec4 fc = FOG_COLOR;
float rd=RENDER_DISTANCE;
float wet_ =smoothstep(0.5,0.4,FOG_CONTROL.x);
float wtime = clamp(texture2D(TEXTURE_1, vec2(0,1)).r,0.,1.);
float night_f=smoothstep(1.,0.2,wtime);
float day_f = smoothstep(0.15,0.2,fc.g);
float dusk_f=min(smoothstep(0.3,0.5,wtime),smoothstep(1.,0.8,wtime))*(1.-wet_)*float(!(night_factor()));

//vec4 powervr=CURRENT_COLOR;
vec4 powervr=vec4(0);

vec3 cube_pos=normalize(vec3(p.x,p.y-.128,p.z));
vec3 cube_poss=normalize(vec3(p.x,p.y,p.z));
vec3 cube_up=normalize(vec3(p.x,-p.y+.1,p.z));
float cubes=clamp(cube_pos.y,0.,0.4);

vec4 day=vec4(0.,0.2,0.8,0.5)*2.5;
vec4 night=vec4(.1,.2,.26,1.4);
vec4 dusks=vec4(1.,0.65,0.1,1.)*1.5;
vec4 wetcolor=vec4(.1,.2,.26,1.4);

powervr=mix(powervr,mix(mix(mix(night,day,day_f),dusks,dusk_f*(1.-wet_)),wetcolor,wet_),cubes);

	gl_FragColor =powervr;
}
