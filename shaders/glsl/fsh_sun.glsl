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
varying vec4 vs;
varying vec3 ps; 

#endif

#include "uniformShaderConstants.h"
#include "util.h"

LAYOUT_BINDING(0) uniform sampler2D TEXTURE_0;
LAYOUT_BINDING(1) uniform sampler2D TEXTURE_1;

varying Hme vec3 wp;
varying Hme vec3 lpos;

uniform vec4 FOG_COLOR;
uniform vec2 FOG_CONTROL;
uniform float RENDER_DISTANCE;
uniform Hme float TOTAL_REAL_WORLD_TIME;

#include "user/g_setting.h"

float sun(Hme vec3 uv,Hme float blur,Hme float sl){
float light = length(uv);
float cc = smoothstep(sl,sl-blur,light);
return cc;
}

vec3 lensflare(Hme vec2 uv,Hme vec2 pos)
{
    float intensity = 1.5;
    vec2 main = uv-pos;
    vec2 uvd = uv*(length(uv));
    float dist=length(main); dist = pow(dist,.1);
    float f1 = max(0.01-pow(length(uv+1.2*pos),1.9),.0)*7.0;
    float f2 = max(1.0/(1.0+32.0*pow(length(uvd+0.8*pos),2.0)),.0)*00.1;
    float f22 = max(1.0/(1.0+32.0*pow(length(uvd+0.85*pos),2.0)),.0)*00.08;
    float f23 = max(1.0/(1.0+32.0*pow(length(uvd+0.9*pos),2.0)),.0)*00.06;
    vec2 uvx = mix(uv,uvd,-0.5);
    float f4 = max(0.01-pow(length(uvx+0.4*pos),2.4),.0)*6.0;
    float f42 = max(0.01-pow(length(uvx+0.45*pos),2.4),.0)*5.0;
    float f43 = max(0.01-pow(length(uvx+0.5*pos),2.4),.0)*3.0;
    uvx = mix(uv,uvd,-.4);
    float f5 = max(0.01-pow(length(uvx+0.2*pos),5.5),.0)*2.0;
    float f52 = max(0.01-pow(length(uvx+0.4*pos),5.5),.0)*2.0;
    float f53 = max(0.01-pow(length(uvx+0.6*pos),5.5),.0)*2.0;
    uvx = mix(uv,uvd,-0.5);
    float f6 = max(0.01-pow(length(uvx-0.3*pos),1.6),.0)*6.0;
    float f62 = max(0.01-pow(length(uvx-0.325*pos),1.6),.0)*3.0;
    float f63 = max(0.01-pow(length(uvx-0.35*pos),1.6),.0)*5.0;
    vec3 c = vec3(.0);
    c.r+=f2+f4+f5+f6; c.g+=f22+f42+f52+f62; c.b+=f23+f43+f53+f63;
    c = c*1.3 - vec3(length(uvd)*.05);
    return c * intensity;
}

void main()
{
#if !defined(TEXEL_AA) || !defined(TEXEL_AA_FEATURE)
	vec4 powervr = texture2D( TEXTURE_0, uv );
#else
	vec4 powervr = texture2D_AA(TEXTURE_0, uv );
#endif

#ifdef ALPHA_TEST
	if(powervr.a < 0.5)
		discard;
#endif

float wtime = clamp(texture2D(TEXTURE_1, vec2(0,1)).r,0.,1.);
float wet_ =smoothstep(0.5,0.1,FOG_CONTROL.x);
float dayf = smoothstep(0.15,0.2,FOG_COLOR.g);
float dusk=min(smoothstep(.33,.5,wtime),smoothstep(1.,0.6,wtime))*(1.-wet_);
float duskset=clamp((FOG_COLOR.r-0.1)-FOG_COLOR.b,0.,1.);
float nights=smoothstep(1.,0.2,wtime);
float day=(1.-wet_)*(1.-dusk)*(1.-nights);
float day2=(1.-wet_);
vec3 p=wp;
float sunposition=mix(mix(0.12,0.,dusk),0.,nights);
vec3 np=normalize(p);

float n = sun(vec3(p.x,p.y,p.z),0.015,0.01);
float n2 = sun(vec3(p.x,p.y,p.z*0.95),0.01,0.012);
float nn = sun(vec3(p.x,p.y,p.z),0.01,0.013);
float m2 = sun(p.xyz,0.35,0.03);
float m3 = sun(p.xyz,1.,0.25);
float m4 = sun(vec3(p.x,p.y,p.z*0.7),0.8,0.2);
float m4_2 = sun(vec3(p.x,p.y,p.z),0.35,0.15);
float m5 = sun(p.xyz,0.75,0.245);
float m5_2 = sun(vec3(p.x,p.y,p.z),0.3,0.1);

powervr.rgb*=vec3(0);

powervr.rgb+=mix(mix(mix(n2,n,dayf),nn,duskset),m3,wet_);
if(n>=0.){
powervr.rgb+=mix(mix(m4*vec3(1.05),m5_2*vec3(1,0.9,0.7),dayf),m4_2*vec3(1.4,1.2,0.1),duskset);

	#if LENS_FLARE == 1
powervr.rgb+=mix(vec3(0),vec3(1),clamp(lensflare(p.xz*10.,-lpos.xz*.015),0.,1.));
	#endif
}

gl_FragColor = powervr*CURRENT_COLOR;
}
