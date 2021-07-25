// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.




/*

/////D O N ' T  S T E A L  A N Y C O D E S !!!!

///Made by Glin Shady
///You must follow "GRES licence"

/////D O N ' T  S T E A L  A N Y C O D E S !!!!

*/



#include "fragmentVersionSimple.h"

#ifdef GL_FRAGMENT_PRECISION_HIGH
#define Hme highp
#else
#define Hme mediump
#endif

#include "uniformShaderConstants.h"
#include "util.h"

LAYOUT_BINDING(0) uniform sampler2D TEXTURE_0;
LAYOUT_BINDING(1) uniform sampler2D TEXTURE_1;

uniform Hme float TOTAL_REAL_WORLD_TIME;
uniform vec4 FOG_COLOR;
uniform vec2 FOG_CONTROL;

varying vec4 color;
varying vec4 col;
varying highp vec3 p;
varying float fog;
varying vec2 lm;
varying highp vec3 cp;

#include "user/g_setting.h"

/////STOP/////
//DONT STEAL THIS CODE!!!// 
//made by @GLshading

#define vec4_(d,e) vec4(d,e,e,1)
#define saturate(x) clamp(x,0.,1.)

bool rain_factor(){
if(FOG_CONTROL.x > 0.1 && FOG_CONTROL.x < 0.55){
return true;
}else{
return false;
}}

bool dusk_factor(){
if(FOG_COLOR.r*1.0>FOG_COLOR.b){
return true;
}else{
return false;
}}

bool night_factor(){
if(FOG_COLOR.r<0.15 && FOG_COLOR.g<0.15){
return true;
}else{
return false;
}}

Hme float hash_cloud(Hme vec2 p) {Hme vec3 p3 = fract(vec3(p.xyx) * 0.13); p3 += dot(p3, p3.yzx + 6.666); return fract((p3.x + p3.y) * p3.z); }

Hme float cloudnoise(Hme vec2 x) {
    Hme vec2 i = floor(x);
    Hme vec2 f = fract(x);

	// Four corners in 2D of a tile
	Hme float a = hash_cloud(i);
    Hme float b = hash_cloud(i + vec2(1.0, 0.0));
    Hme float c = hash_cloud(i + vec2(0.0, 1.0));
    Hme float d = hash_cloud(i + vec2(1.0, 1.0));

    // Simple 2D lerp using smoothstep envelope between the values.
	// return vec3(mix(mix(a, b, smoothstep(0.0, 1.0, f.x)),
	//			mix(c, d, smoothstep(0.0, 1.0, f.x)),
	//			smoothstep(0.0, 1.0, f.y)));

	// Same code, with the clamps in smoothstep and common subexpressions
	// optimized away.
    Hme vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

Hme vec3 mod289(highp vec3 x){return x-floor(x*(1./289.))*289.;}
Hme vec2 mod289(highp vec2 x){return x-floor(x*(1./289.))*289.;}
Hme vec3 permute2(highp vec3 x){return mod289(((x*34.)+1.)*x);}
Hme float gnoise(highp vec2 v){const highp vec4 C=vec4(.211324865405187,.366025403784439,-.577350269189626,.024390243902439);highp vec2 i=floor(v+dot(v,C.yy));highp vec2 x0=v-i+dot(i,C.xx);highp vec2 i1=x0.x>x0.y?vec2(1.,0.):vec2(0.,1.);highp vec4 x12=x0.xyxy+C.xxzz;x12.xy-=i1;i=mod289(i);highp vec3 p =permute2(permute2(i.y+vec3(0.,i1.y,1.))+i.x+vec3(0.,i1.x,1.));highp vec3 m=max(.5-vec3(dot(x0,x0),dot(x12.xy,x12.xy),dot(x12.zw,x12.zw)),0.);m=m*m;m=m*m;highp vec3 x =2.*fract(p*C.www)-1.;highp vec3 h=abs(x)-.5;highp vec3 ox=round(x);highp vec3 a0=x-ox;m*=inversesqrt(a0*a0+h*h);highp vec3 g;g.x=a0.x*x0.x+h.x*x0.y;g.yz=a0.yz*x12.xz+h.yz*x12.yw;return 170.*dot(m,g);}

Hme float clnoise(Hme vec2 x,int octaves,Hme float t) {
	Hme float v = 0.0;
	Hme float a = 0.45;
	Hme vec2 shift = vec2(1.);
	// Rotate to reduce axial bias
    mat2 rot = mat2(cos(1.), sin(1.), -sin(0.6), cos(0.6));
	for (int i = 0; i < octaves; ++i) {
		v += a * cloudnoise(x);
		x = rot * x * 2.5 + shift;
		a *= 0.35;
		x.x+=t*0.01+float(i);
	}
	return v;
}

Hme float gfbm(Hme vec2 x,int octaves,Hme float t) {
	Hme float v = 0.0;
	Hme float a = 0.45;
	Hme vec2 shift = vec2(1000);
	// Rotate to reduce axial bias
    mat2 rot = mat2(tan(1.), sin(0.4), -sin(1.), cos(0.5));
	for (int i = 0; i < octaves; ++i) {
		v += a * abs(cloudnoise(x));
		x = rot*x*2.5+shift;
		//x.y+=float(i+1);
		//x.x+=t*0.1*float(i);
		a *= 0.5;
	}
	return v;
}

void main(){

//matrials

vec4 equations = col; //trSk
vec4 fc = FOG_COLOR; //trF
Hme float t = mod(TOTAL_REAL_WORLD_TIME,3600.);
float wtime = clamp(texture2D(TEXTURE_1, vec2(0,1)).r,0.,1.);
float duskset=clamp((FOG_COLOR.r-0.1)-FOG_COLOR.b,0.,1.);
float wet_ =smoothstep(0.5,0.3,FOG_CONTROL.x);
float night_f=pow(wtime,2.);
float day_f = smoothstep(0.15,0.2,fc.g);
float dusk_f=clamp(smoothstep((1.-wet_)*pow(wtime,2.),1.,min(smoothstep(0.4,0.5,wtime),smoothstep(1.,0.7,wtime))),0.,1.);
 
//sky col
//best color is "vec4(.14,.2,.26,0.)" //0.2,0.6,0.75,1//vec4(.1,.35,.55,1)//vec4(.04,.3,.6,0.)

//vec4 day = mix(mix(vec4(.14,.2,.26,1.),vec4(.14,.2,.26,1.),length(p.xz*1.1)*1.25),vec4(1.,0.7,0.6,1),length(p.xz*1.2)*1.2);

//vec4 day=mix(vec4(0.,0.2,0.8,1.),vec4(1.1,1.,0.9,1.),length(p.xz*1.4)*1.6);

vec4 day = mix(mix(vec4(.1,.2,.26,1),vec4(0,.2,.8,1)*1.45,length(p.xz*1.2)*1.25),vec4(0.8,0.9,1.1,1),length(p.xz)*1.2);
vec4 rain = mix(vec4(0.3),vec4(0.2),length(p.xz)*1.3); //sunrise-sunset
vec4 dark = mix(vec4(0.1,0.1,0.1,1.0),vec4(0.,0.1,0.3,1.)*1.2,length(p.xz)*1.5); //night
vec4 dusk = mix(vec4(.1,.2,.36,1.),vec4(2.,1.05,0,1),length(p.xz*0.9)*0.9); //dusk

vec4 skcl=mix(mix(mix(dark,day,day_f),rain,wet_),dusk,dusk_f*(1.-wet_));

equations=skcl;
	
	#if CLOUD == 1
vec4 nightcl=vec4(0.25,0.25,0.4,0.2);vec4 daycl=vec4(0.99,0.94,0.93,1);vec4 raincl=vec4(0.75);vec4 duskcl=vec4(0.3,0.2,0.05,1.);
vec4 clc=mix(mix(mix(nightcl,daycl,day_f),duskcl,dusk_f*(1.-wet_)),raincl,wet_);

float sharp;
float sharpf;
#if CLOUD_TYPE == 1
sharp=smoothstep(0.43,0.5,clnoise(t*0.005+p.xz*7.4,6,t));
sharpf=smoothstep(0.43,0.7,clnoise(t*0.005+p.xz*6.8,3,t));
if(sharp>0.)clc*=mix(1.1,0.7,sharpf);
vec4 fragcloud=mix(equations,clc,sharp);
#else
sharp=smoothstep(0.45,0.75,gfbm(t*0.01+p.xz*6.,4,t));
vec4 fragcloud=mix(equations,clc,sharp);
#endif
equations=fragcloud;
	#endif

gl_FragColor = mix(equations,fc,fog);
	//gl_FragColor = vec4(0); //Equation Shader
}