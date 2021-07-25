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

#define h1 Hme float
#define h2 Hme vec2
#define h3 Hme vec3
#define h4 Hme vec4

#include "fragmentVersionCentroid.h"
#if __VERSION__ >= 300
#ifndef BYPASS_PIXEL_SHADER
#if defined(TEXEL_AA) && defined(TEXEL_AA_FEATURE)
_centroid in highp vec2 uv0;
_centroid in highp vec2 uv1;
	#else
_centroid in vec2 uv0;
_centroid in vec2 uv1;
#endif
#endif
#else
#ifndef BYPASS_PIXEL_SHADER
￼in vec2 uv0;
in vec2 uv1;
#endif
#endif

in vec4 color;
in h3 p;
in h3 wp;
in h2 pw;
in h3 cp;

in float iswaters;
in float rainstrength;
in float sundusk;
in float outdoor;
in float blockid;

#ifdef FOG
in vec4 fogColor;
#endif

#include "uniformShaderConstants.h"
#include "util.h"

uniform vec2 FOG_CONTROL;
uniform vec4 FOG_COLOR;
uniform float RENDER_DISTANCE;
uniform h1 TOTAL_REAL_WORLD_TIME;

LAYOUT_BINDING(0) uniform sampler2D TEXTURE_0;
LAYOUT_BINDING(1) uniform sampler2D TEXTURE_1;
LAYOUT_BINDING(2) uniform sampler2D TEXTURE_2;

#include "user/g_setting.h"
#include "equation/g_functions.glsl"

void main()
{
#ifdef BYPASS_PIXEL_SHADER
	gl_FragColor = vec4(1);
	return;
#else 

float rd=RENDER_DISTANCE;
vec4 fc=FOG_COLOR;
vec2 ft=FOG_CONTROL;

h1 t =mod(TOTAL_REAL_WORLD_TIME,3600.);
float wtime = saturate(texture2D(TEXTURE_1, vec2(0,1)).r);
float nightf=smoothstep(1.,0.2,wtime);
float dusk=saturate(smoothstep(uv1.y*(1.-rainstrength)*nightf,1.,min(smoothstep(0.4,0.5,wtime),smoothstep(1.,0.7,wtime))));
float lightmap=smoothstep(pow(wtime,2.)*(1.-rainstrength)*pow(uv1.y,2.),1.,pow(uv1.x,2.5));
vec3 n=normalize(cross(dFdx(p),dFdy(p)));
vec3 mp=mod(p.xyz,16.);

#if USE_TEXEL_AA
vec4 algorithm=texture2D_AA(TEXTURE_0, uv0);
vec4 tex=texture2D_AA(TEXTURE_0, uv0);
#else
vec4 algorithm=textureGrad(TEXTURE_0, uv0,dFdx(uv0*0.5),dFdy(uv0*0.5));
vec4 tex=texture2D(TEXTURE_0,uv0);
#endif

float getnether=step(0.1,ft.x/ft.y)-step(0.12,ft.x/ft.y);
float getun=getunder(ft,fc,color)?1.:0.;
float getgrass=grass(color)?1.:0.;
float geto=getores(tex)?1.:0.;
float getm=getmetal(tex)?1.:0.;
float gete=getend(color)?1.:0.;

#ifdef ALPHA_TEST
if(algorithm.a<
	#ifdef ALPHA_TO_COVERAGE
	.05
	#else
	.5
	#endif
)discard;
#endif
#if defined(BLEND)
	algorithm.a *= color.a;
#endif
#if BUMPMAP == 1
vec3 rsl;
rsl=mix(mix(mix(vec3(0),vec3(0.2),float(resolution==16.0)),vec3(0.4),float(resolution==32.0)),vec3(0.9),float(resolution==64.0));
#if !defined(BLEND)&&!defined(ALPHA_TEST)
#if USE_TEXEL_AA
algorithm.rgb+=mix(vec3(0.),mix(mix(rsl,vec3(0.4),dusk),vec3(0.),smoothstep(1.,0.5,uv1.y)),clamp(pathtracing_aa(tex,rainstrength,iswaters).rgb,vec3(0.),rsl));
#else
algorithm.rgb+=mix(vec3(0.),mix(mix(rsl,vec3(0.4),dusk),vec3(0.),smoothstep(1.,0.5,uv1.y)),clamp(normalbump_ggrs(tex,rainstrength,iswaters,n).rgb,vec3(0.),rsl));
#endif
#endif
#endif

#if !defined(ALWAYS_LIT)
vec4 tex1=texture2D(TEXTURE_1,uv1);
tex1.rgb*=pow(tex1.rgb,1.-vec3(1.3));
algorithm*=mix(vec4(1),tex1,outdoor);

algorithm*=texture2D(TEXTURE_1,vec2(lightmap*0.9,mix(uv1.y,3.,max(geto,getun))));
#endif

#if !defined(SEASONS)
	#if !USE_ALPHA_TEST && !defined(BLEND)
		algorithm.a = color.a;
	#endif
if(grass(color)&&color.a!=0.1){
algorithm.rgb*=normalize(color.rgb);
}else{
algorithm.rgb*=(color.a==0.1)?color.rgb:sqrt(color.rgb);}
#else
     vec2 uv = color.xy;
	algorithm.rgb *= mix(vec3(1.0,1.0,1.0), texture2D(TEXTURE_2, uv).rgb*2.0, color.b);
	algorithm.rgb *= color.aaa;
	algorithm.a = 1.0;	
#endif
	#if BUMPMAP == 1
vec3 rsl2;
rsl2=mix(mix(mix(vec3(0.),vec3(0.3),float(resolution==16.0)),vec3(0.65),float(resolution==32.0)),vec3(0.9),float(resolution==64.0));
#if !defined(BLEND)&&!defined(ALPHA_TEST)
#if USE_TEXEL_AA
algorithm.rgb+=mix(vec3(0.),mix(mix(rsl2,vec3(0.6),dusk),vec3(0.),smoothstep(1.,0.5,uv1.y)),clamp(pathtracing_aa(tex,rainstrength,iswaters).rgb,vec3(0),rsl));
#else
algorithm.rgb+=mix(vec3(0.),mix(mix(rsl2,vec3(0.6),dusk),vec3(0.),smoothstep(1.,0.5,uv1.y)),clamp(normalbump_ggrs(tex,rainstrength,iswaters,n).rgb,vec3(0),rsl));
#endif
#endif
	#endif
	#if BLOCK_SHADOW == 1
algorithm.rgb=genshadow(algorithm.rgb,n,rainstrength,dusk,iswaters,lightmap,uv1,getnether);
	#endif
	
	#if B_GLOWING_ORES == 1
#if !defined(ALPHA_TEST)&&!defined(BLEND)&&!defined(SEASONS)
algorithm*=mix(vec4(1),mix(vec4(5.),vec4(1.),pow(wtime,2.)*pow(uv1.y,5.)),geto);
#endif
	#endif
	
	#if VIGNETTE == 1
float scr=1.-max(.0,max(.0,length(cp.xy))-0.65); 
	algorithm.rgb*=scr;
	#endif
	#if ENABLE_TORCH_LIGHTNING == 1
vec3 lightbase=mix(mix(mix(vec3(tr,tg,tb)*2.0,vec3(-0.2,0.6,1.7),gete),vec3(0.,0.6,1.7)*1.05,getun),vec3(tr,tg,tb)*0.9,getnether);
//algorithm.rgb+=tex.rgb*(lightbase*1.05)*pow(lightmap*1.1,2.);//illumination end
algorithm.rgb+=tex.rgb*(lightbase*1.05)*pow(lightmap*1.1,3.);
	#endif
	#if WORLD_COLORING == 1
vec3 oclr=vec3(2.,1.7,1.);vec3 wetcol=vec3(0.5);vec3 endcl=vec3(.8,.9,1.4);vec3 hellcl=vec3(2,1.4,1.);
vec3 wclr=mix(mix(mix(mix(oclr.rgb,
wetcol.rgb,rainstrength),hellcl,getnether),endcl.rgb,gete),vec3(0.7,1.5,1.8),getun);
	algorithm.rgb=tonemapFilmic(algorithm.rgb*(uncharted2(algorithm.rgb*wclr)));
	
	#endif
	#if UNDERWATER_CAUSTIC == 1
#ifdef FANCY
	float unwave=gnoise(t*0.7+mp.xz*.7+mp.x*.4+mp.z*.5+mp.y*.8);
	algorithm.rgb+=mix(vec3(0.),vec3(.05),unwave*getun);
#endif
	#endif
if(iswaters>0.5){
algorithm.rgb*=vec3(0);
	algorithm.rgb+=mix(vec3(0.02),mix(vec3(0.2,0.7,0.9),vec3(0.02),max(nightf,rainstrength)),outdoor);
algorithm.a*=mix(1.,
#ifdef FANCY
0.8,
#else
0.6,
#endif
smoothstep(max(rd,2.5),1.,length(wp.xz*6.)));
	#if SUN_REFLECTION == 1
algorithm.rgb=reflectsun(algorithm.rgb,rd,wp,iswaters,sundusk,nightf,tex,n);
	#endif
	#if WATER_SURFACE_CAUSTIC == 1
algorithm.rgb=water_wave(algorithm.rgb,wp,mp,t,n);
	#endif
	#if CLOUD_REFLECTION == 1
algorithm=watercloud(algorithm,wp,t,p,iswaters,uv1);
	#endif
}
	#if FOGS == 1
	
vec3 fogclr=fc.rgb*mix(mix(mix(mix(vec3(1.,1.05,1.1),vec3(0.7),rainstrength),vec3(1.),getnether),vec3(0.9,0.7,0.6),dusk),vec3(0.2,0.85,0.9),getun);
float fogdis=mix(mix(mix(mix(mix(0.6,5.5,rainstrength),3.,getun),0.8,dusk),0.,getnether),0.,nightf);

algorithm.rgb=mix(algorithm.rgb,fogclr.rgb,smoothstep(0.,max(rd,2.),length(-wp*fogdis)));
	#endif
gl_FragColor=algorithm; //Equation Shader
#endif
}
