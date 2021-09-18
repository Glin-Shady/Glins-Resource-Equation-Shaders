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
		varying vec2 uv0;
		varying vec2 uv1;
	#endif
#endif

varying vec4 color;
varying h1 t;
varying h3 eye;
varying h3 weye;
varying h3 seye;
varying float iswater;
varying float isalpha;

#ifdef FOG
varying vec4 fogColor;
#endif

#include "uniformShaderConstants.h"
#include "util.h"
#include "dont_enter_s.h"

uniform vec2 FOG_CONTROL;
uniform vec4 FOG_COLOR;
uniform float RENDER_DISTANCE;
uniform h1 TOTAL_REAL_WORLD_TIME;


LAYOUT_BINDING(0) uniform sampler2D TEXTURE_0;
LAYOUT_BINDING(1) uniform sampler2D TEXTURE_1;
LAYOUT_BINDING(2) uniform sampler2D TEXTURE_2;

#define tex2(a,b) texture2D(TEXTURE_0,uv0+a,b)
#define tex2a(c) texture2D_AA(TEXTURE_0,uv0+c)


//functions

bool grass(vec4 color){return color.g>(color.b+color.r)/2.0*1.2||color.b>(color.g + color.r)/2.0*1.2||color.g<color.r;}
bool getmaskunderwater(vec2 ft,vec4 fc,vec4 clr,vec2 uv3){return ft.x==0.&&fc.b>fc.r;}
bool getores(vec4 tex,vec4 cl){return 0.<tex.a&&tex.a<.015&&cl.a!=0.;}//toumeido 1%



//https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
highp vec3 mod289(highp vec3 x){return x-floor(x*(1./289.))*289.;}
highp vec2 mod289(highp vec2 x){return x-floor(x*(1./289.))*289.;}
highp vec3 permute(highp vec3 x){return mod289(((x*34.)+1.)*x);}

highp float snoise(highp vec2 v){
const highp vec4 C=vec4(.211324865405187,.366025403784439,-.577350269189626,.024390243902439);
highp vec2 i=floor(v+dot(v,C.yy));
highp vec2 x0=v-i+dot(i,C.xx);
highp vec2 i1=x0.x>x0.y?vec2(1.,0.):vec2(0.,1.);
highp vec4 x12=x0.xyxy+C.xxzz;x12.xy-=i1;i=mod289(i);
highp vec3 p =permute(permute(i.y+vec3(0.,i1.y,1.))+i.x+vec3(0.,i1.x,1.));
highp vec3 m=max(.5-vec3(dot(x0,x0),dot(x12.xy,x12.xy),dot(x12.zw,x12.zw)),0.);
	m=m*m;m=m*m;
highp vec3 x =2.*fract(p*C.www)-1.;
highp vec3 h=abs(x)-.5;
highp vec3 ox=round(x);
highp vec3 a0=x-ox;
	m*=inversesqrt(a0*a0+h*h);
highp vec3 g;
	g.x=a0.x*x0.x+h.x*x0.y;g.yz=a0.yz*x12.xz+h.yz*x12.yw;
	return 130.*dot(m,g);
}



// http://filmicworlds.com/blog/filmic-tonemapping-operators/
vec3 uncharted2Tonemap(const vec3 x) {
	const float A = 0.15;
	const float B = 0.50;
	const float C = 0.10;
	const float D = 0.10;
	const float E = 0.02;
	const float F = 0.30;
	return ((x * (A * x + C * B) + D * E) / (x * (A * x + B) + D * F)) - E / F;
}

vec3 tonemapUncharted2(const vec3 color) {
	const float W = 11.2;
	const float exposureBias = 2.0;
	vec3 curr = uncharted2Tonemap(exposureBias * color);
	vec3 whiteScale = 1.0 / uncharted2Tonemap(vec3(W));
	return curr * whiteScale * 1.8;
}

vec3 gres_AmbientOcclusion(vec3 tex,vec4 col,float light,float uw,float wet,vec3 n,float ind){
vec3 nc=normalize(col.rgb);
vec3 sc=sqrt(col.rgb);
	if(grass(col)&&col.a!=0.1){
	tex.rgb*=mix(mix(nc,mix(col.rgb,nc,light),max(uw,wet)),mix(nc,vec3(1),light),ind);
	}else{
	tex.rgb*=(col.a==0.1)?col.rgb:mix(mix(mix(vec3(1),mix(sc,vec3(1),light),saturate(max(dot(vec3(1.,-1.,-1.),n),dot(vec3(-1.,-1.,0.),n)))),mix(col.rgb,vec3(1),light),max(uw,wet)),mix(sc,vec3(1),light),ind);
	}
	return tex;
}

float genshadow(const vec2 uv3,float uw,vec3 n,float water,float isd){
float shdplace;
float shadowposition=saturate(max(dot(vec3(.9,-1.,-1.),n),dot(vec3(-.9,-1.,0.),n)));
	shdplace=mix(mix(mix(0.,1.,smoothstep(0.875,0.860,uv3.y)),1.,shadowposition),0.,uw);
	return shdplace;
}

void main()
{
#ifdef BYPASS_PIXEL_SHADER
	gl_FragColor = vec4(0, 0, 0, 0);
	return;
#else 

#if USE_TEXEL_AA
vec4 tex = texture2D_AA(TEXTURE_0, uv0);
#else
vec4 tex = texture2D(TEXTURE_0, uv0);
#endif

float rd=RENDER_DISTANCE;
vec4 fc=FOG_COLOR;
vec2 ft=FOG_CONTROL;
vec4 clr=color;
float getunderwater=getmaskunderwater(ft,fc,clr,uv1)?1.:0.;
float getore=getores(tex,color)?1.:0.;
float getnether=step(0.1,ft.x/ft.y)-step(0.12,ft.x/ft.y);
float israin=smoothstep(0.5,0.3,FOG_CONTROL.x);
israin*=(1.-getunderwater);
float wtime =saturate(texture2D(TEXTURE_1, vec2(0.,1.)).r);
float isnight=smoothstep(1.,0.2,wtime);
float isdusk=min(smoothstep(0.4,0.5,wtime),smoothstep(1.,0.7,wtime))*(1.-israin);
float isdusk2=saturate((fc.r-0.1)-fc.b);
float lightmap=smoothstep(pow(wtime,2.)*pow(uv1.y,2.3),1.,pow(uv1.x,1.8));
float indoor=smoothstep(1.,0.5,uv1.y);
vec3 n=normalize(cross(dFdx(eye),dFdy(eye)));
vec3 compositetex=mix(mix(SHADOW_COLOR,vec3(.3),isnight),vec3(.7),israin);
	
#ifdef SEASONS_FAR
	tex.a = 1.0;
#endif

#if USE_ALPHA_TEST
if(tex.a<
	#ifdef ALPHA_TO_COVERAGE
0.05
	#else
0.5
	#endif
)discard;
#endif

#if defined(BLEND)
	tex.a*=clr.a;
#endif
#if !defined(ALWAYS_LIT)	tex*=texture2D(TEXTURE_1,vec2(lightmap,mix(mix(uv1.y,mix(uv1.y*1.2,0.7,getunderwater),indoor),5.,getore)));
#endif

#ifndef SEASONS
	#if !USE_ALPHA_TEST && !defined(BLEND)
		tex.a = clr.a;
	#endif
	tex.rgb=gres_AmbientOcclusion(tex.rgb,clr,lightmap,getunderwater,israin,n,indoor);
#else
vec2 uv=clr.rg;
	tex.rgb*=mix(vec3(1.0),texture2D(TEXTURE_2,uv).rgb*2.0,clr.b);
	tex.rgb*=clr.aaa;
	tex.a=1.0;
#endif
	
//fog
vec3 underwaterfog=mix(vec3(0.,0.65,0.9)*0.7,vec3(0),isnight);
vec3 wetef=vec3(0.25);
	
	#if GRES_FOG == 1
	tex.rgb+=mix(mix(vec3(0),underwaterfog,smoothstep(0.,rd*2.5,length(-weye*8.))*getunderwater),wetef,smoothstep(0.,rd*1.5,dot(vec3(0.,1.,0.),n)*length(-weye*20.))*israin*(1.-indoor)*(1.-isnight));
	tex.rgb=mix(tex.rgb,mix(mix(vec3(1.),vec3(1.,0.65,0.3),isdusk2),vec3(0.7),israin)*fc.rgb,smoothstep(1.-indoor,rd*mix(1.,1.5,max(isdusk2,israin)),length(-weye.xz*mix(0.,3.,max(isdusk2,israin)))));
	#endif

//worldcoloring

float vpos=length(seye.xy);
	//tex.rgb*=1.05-vpos*.6;
//uncharted
vec3 ambientcolor=mix(mix(mix(mix(mix(mix(mix(NightColor,DayColor,wtime),DuskColor,isdusk),RainColor,israin),UnderwaterColor,getunderwater),compositetex,genshadow(uv1,getunderwater,n,iswater,isdusk2)),vec3(2.),getore),NormalLightColor,pow(lightmap*1.,1.));
	tex.rgb=tonemapUncharted2(ambientcolor*tex.rgb);
	
//underwater caustic
vec3 mp=mod(eye.xyz,16.);
mp.xz*=vec2(1.4,0.6);
float wave=snoise(vec2(t*0.8+mp.x*0.6+mp.x*0.3+mp.z*0.3, t*0.77+mp.z*0.4+mp.x*0.5+mp.z*0.26+mp.x*0.2))+snoise(vec2(t*0.7+mp.x*0.9+mp.x*0.4+mp.z*0.7, t*0.87+mp.z*0.6+mp.x*0.3+mp.z*0.56+mp.x*0.4));
float caus=snoise(weye.xz*wave*.2);
	
	#if UNDERWATER_CAUSTIC == 1
	//if(getunderwater(ft,fc,clr,uv1))
	tex.rgb+=(getmaskunderwater(ft,fc,clr,uv1))?mix(vec3(0),vec3(.02),caus):vec3(0);
	#endif
	
//water

if(iswater>0.5){
vec3 nw=normalize(weye);
float refpos=saturate(1.-smoothstep(0.,rd*0.5,length(-weye.z*12.)))*smoothstep(0.,rd*2.5,length(-weye.x*9.5));
vec3 daywater;
vec3 nightwater;
vec3 duskwater; 
	#if WATER_QUALITY == 1
	
vec3 watercl1=mix(mix(mix(vec3(.325,.65,1.3),vec3(0),isnight),vec3(0.2,0.35,0.5),isdusk2),vec3(0),max(indoor,israin));
vec3 watercl2=mix(mix(mix(vec3(1.),vec3(0.,.2,.6),isnight),vec3(1.,0.75,0.1),isdusk2),vec3(0.1),max(indoor,israin));
float skyrefpos=smoothstep(1.,0.05,dot(vec3(0.,mix(mix(mix(5.,7.5,wtime),5.5,isdusk2),0.,max(indoor,max(getunderwater,israin))),0.2),reflect(nw,n)));
	tex.rgb=mix(tex.rgb,mix(watercl1,watercl2,float(n.y>.9)*skyrefpos),iswater);
	#else
	daywater=vec3(.325,.65,1.3);
	nightwater=vec3(0);
	duskwater=vec3(0.2,0.35,0.5);
vec3 watercl=mix(mix(mix(mix(daywater,nightwater,isnight),duskwater,isdusk),vec3(0),israin),vec3(0,0,0),indoor); 
	tex.rgb=mix(tex.rgb,watercl.rgb,iswater);
	#endif
	tex.a=mix(1.,mix(.45,.7,smoothstep(0.,rd,length(weye*6.0))),iswater);
	
	tex.rgb+=mix(vec3(0),vec3(2.,1.75,0.),refpos*iswater*isdusk2);
	
	//wave
	#if WATER_SURFACE_CAUSTIC == 1
	tex.rgb+=mix(vec3(0),mix(vec3(0),mix(mix(vec3(.05),vec3(.07),isdusk2),vec3(0),israin),caus),iswater*(1.-indoor));
	#endif
}
	
	#ifdef FOG
	#endif

	gl_FragColor=tex;

	
#endif // BYPASS_PIXEL_SHADER
}
