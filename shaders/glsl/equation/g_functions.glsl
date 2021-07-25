/*

	Functions Files
	
	Credit :
Value Noise : https://www.shadertoy.com/view/4dS3Wd
Simplex Noise : https://github.com/ashima/webgl-noise/blob/master/src/noise2D.glsl
Simplex Noise : https://www.shadertoy.com/view/Msf3WH
uchimura tonemap : https://www.slideshare.net/nikuque/hdr-theory-and-practicce-jp

*/

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

#include "user/g_setting.h"
#include "util.h"

#define saturate(x) clamp(x,0.,1.)
#define sr shadow_color_R
#define sg shadow_color_G
#define sb shadow_color_B
#define tr NORMAL_TORCH_R
#define tg NORMAL_TORCH_G
#define tb NORMAL_TORCH_B
#define tex2(a,b) texture2D(TEXTURE_0,uv0+a,b)
#define tex2a(c) texture2D_AA(TEXTURE_0,uv0+c)


//- Noise

h1 hash_cloud(h2 p) {h3 p3 = fract(vec3(p.xyx) * 0.13); p3 += dot(p3, p3.yzx + 6.666); return fract((p3.x + p3.y) * p3.z); }

h1 cloudnoise(h2 x) {
    h2 i = floor(x);
    h2 f = fract(x);

	// Four corners in 2D of a tile
	h1 a = hash_cloud(i);
    h1 b = hash_cloud(i + vec2(1.0, 0.0));
    h1 c = hash_cloud(i + vec2(0.0, 1.0));
    h1 d = hash_cloud(i + vec2(1.0, 1.0));

    // Simple 2D lerp using smoothstep envelope between the values.
	// return vec3(mix(mix(a, b, smoothstep(0.0, 1.0, f.x)),
	//			mix(c, d, smoothstep(0.0, 1.0, f.x)),
	//			smoothstep(0.0, 1.0, f.y)));

	// Same code, with the clamps in smoothstep and common subexpressions
	// optimized away.
    h2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

h3 mod289(h3 x){return x-floor(x*(1./289.))*289.;}
h2 mod289(h2 x){return x-floor(x*(1./289.))*289.;}
h3 permute2(h3 x){return mod289(((x*34.)+1.)*x);}
h1 gnoise(h2 v){const h4 C=vec4(.211324865405187,.366025403784439,-.577350269189626,.024390243902439);h2 i=floor(v+dot(v,C.yy));h2 x0=v-i+dot(i,C.xx);h2 i1=x0.x>x0.y?vec2(1.,0.):vec2(0.,1.);h4 x12=x0.xyxy+C.xxzz;x12.xy-=i1;i=mod289(i);h3 p =permute2(permute2(i.y+vec3(0.,i1.y,1.))+i.x+vec3(0.,i1.x,1.));h3 m=max(.5-vec3(dot(x0,x0),dot(x12.xy,x12.xy),dot(x12.zw,x12.zw)),0.);m=m*m;m=m*m;h3 x =2.*fract(p*C.www)-1.;h3 h=abs(x)-.5;h3 ox=round(x);h3 a0=x-ox;m*=inversesqrt(a0*a0+h*h);h3 g;g.x=a0.x*x0.x+h.x*x0.y;g.yz=a0.yz*x12.xz+h.yz*x12.yw;return 170.*dot(m,g);}


h1 gcl(h2 x,int octaves,h1 t) {
	h1 v = 0.0;
	h1 a = 0.45;
	h2 shift = vec2(100);
	// Rotate to reduce axial bias
    mat2 rot = mat2(cos(1.), sin(1.), -sin(0.6), cos(0.6));
	for (int i = 0; i < octaves; ++i) {
		v += a * abs(cloudnoise(x));
		x = rot*x*2.5+shift;
		//x.y+=float(i+1);
		x.x+=t*0.005*float(i+2);
		a *= 0.5;
	}
	return smoothstep(0.25,0.55,v);
}


//- Terrain functions (of fragment)

bool getend(vec4 fc){return fc.r > fc.g && fc.b > fc.g && fc.b > fc.r && fc.r < 0.05 && fc.b < 0.05 && fc.g < 0.05;}
bool getunder(vec2 ft,vec4 fc,vec4 clr){return ft.x==0.&&fc.b>fc.r;}
bool getores(vec4 tex){return 0.<tex.a&&tex.a<.015;}//toumeido 1%
bool getmetal(vec4 tex){return tex.a<0.3&&tex.a>.05;}//toumeido 20%
bool grass(vec4 color){return color.g>(color.b+color.r)/2.0*1.2||color.b>(color.g + color.r)/2.0*1.2||color.g<color.r;}

// Based on Filmic Tonemapping Operators http://filmicgames.com/archives/75
vec3 tonemapFilmic(const vec3 color) {
	vec3 x = max(vec3(0.0), color - 0.004);
	return (x * (6.2 * x + 0.5)) / (x * (6.2 * x + 1.7) + 0.06);
}

vec3 uncharted2Tonemap(vec3 x) {
  float A = 0.15;
  float B = 0.50;
  float C = 0.10;
  float D = 0.20;
  float E = 0.02;
  float F = 0.30*5.;
  float W = 11.2;
  return ((x * (A * x + C * B) + D * E) / (x * (A * x + B) + D * F)) - E / F;
}

vec3 uncharted2(vec3 color) {
  const float W = 3.0;
  float exposureBias = 3.0;
  vec3 curr = uncharted2Tonemap(exposureBias * color);
  vec3 whiteScale = 1.0 / uncharted2Tonemap(vec3(W));
  return curr * whiteScale;
}

float shadowpos(const vec2 uv2,vec3 n,float b){
float shdpos;
shdpos=mix(mix(0.,0.7,dot(n,vec3(0.,1.,1.))*mix(smoothstep(0.895,0.875,uv2.y),smoothstep(0.875,0.865,uv2.y),b)),0.7,max(dot(n,vec3(1.,-1.,-1.)),dot(n,vec3(-1.,-1.,-1.))));
//shdpos=mix(1.,0.,b);
	return shdpos;
}

vec3 genshadow(vec3 eq,vec3 b,float rain,float dusk,float waterf,float ll,const vec2 uv2,float bp){
vec3 d=vec3(1.);
vec3 shdclr=vec3(sr,sg,sb);
float indoor=smoothstep(0.885,0.875,uv2.y);
	//eq.rgb*=mix(mix(d,shdclr,saturate(dot(b,vec3(0.,1.,1.)))*indoor),d,ll)*mix(mix(shdclr,mix(d,vec3(2.,1.2,0.3),dusk*(1.-rain)),saturate(dot(b,vec3(0.,mix(1.,0.3,dusk*(1.-rain)),1.)))),d,ll);
	
	eq.rgb*=mix(mix(d,shdclr,shadowpos(uv2,b,bp)),d,ll);
	return eq;
}

vec3 water_wave(vec3 ww,h3 wp,h3 p,h1 t){
float wa_wave = sin(cloudnoise(vec2(t*2.3+p.x*1.3+p.x+p.z*2.3, t*1.87+p.z+p.x*1.3+p.z*0.86+p.x*2.2)))+sin(cloudnoise(vec2(t*2.9+p.x*1.3+p.x+p.z*2.3, t*2.1+p.z+p.x*1.3+p.z*0.86+p.x*2.2)))
+sin(cloudnoise(vec2(t*1.3+p.x*1.3+p.x+p.z*2.3, t*0.87+p.z+p.x*1.3+p.z*0.86+p.x*2.2)))
+tan(cloudnoise(vec2(t*3.3+p.y*1.3+p.x+p.z*2.3, t*2.87+p.z+p.x*1.3+p.y*0.86+p.x*2.2)));
ww.rgb+=mix(vec3(0),vec3(0,0.05,0.08),wa_wave);
//ww.rgb+=cloudnoise(wp.xz*0.5*saturate(wa_wave))*0.42;
return ww;
}

vec3 reflectsun(vec3 eq,float rd,h3 wp,float waterf,float dusk,float nights,vec4 tex,vec3 b){
	eq.rgb+=mix(vec3(0),saturate(wp.z*2.5/rd*2.)*vec3(2,1.75,0.1)*saturate(-wp.x*2.5/rd*0.5),dusk)*mix(vec3(0),saturate(wp.z*2.5/rd*0.5)*vec3(2,1.75,0.1)*saturate(wp.x*2.5/rd*1.5),dusk);
	return eq;
}

#if USE_TEXEL_AA
h4 pathtracing_aa(h4 ggrs_asdfgh,float rainf,float waterf){
h4 path=ggrs_asdfgh*0.1;
path+=tex2a(0.0000002*height_bump);path*=tex2a(0.000012);path+=tex2a(0.000063);path-=tex2a(0.000075);path-=tex2a(0.000068);path-=tex2a(0.0000699);path*=tex2a(0.000052);

	ggrs_asdfgh.rgb+=mix(mix(path.rgb,vec3(0),waterf),vec3(0),rainf);
	return ggrs_asdfgh;
}
#else
h4 normalbump_ggrs(h4 eq,float rainf,float waterf,vec3 nm){
h4 path=vec4(dot(eq.rgb,nm));
h1 height=0.00000001;
path+=tex2(0.0000002*height_bump,height*2.);path*=tex2(0.000012,height);
path+=(getmetal(eq))?tex2(0.00063,height*2.):tex2(0.00013,height);

path-=tex2(0.000075,height);path-=tex2(0.000068,height);path-=tex2(0.0000699,height);path*=tex2(0.000052,height);

	eq.rgb+=mix(mix(path.rgb,vec3(0),waterf),vec3(0),rainf);
return eq;
}
#endif

