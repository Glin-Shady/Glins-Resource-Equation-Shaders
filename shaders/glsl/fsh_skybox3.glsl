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

varying h3 eye;

#include "uniformShaderConstants.h"
#include "util.h"
#include "dont_enter_l.h"

LAYOUT_BINDING(0) uniform sampler2D TEXTURE_0;
LAYOUT_BINDING(0) uniform sampler2D TEXTURE_1;

uniform vec4 FOG_COLOR;
uniform vec2 FOG_CONTROL;
uniform h1 TOTAL_REAL_WORLD_TIME;

//https://www.shadertoy.com/view/4dS3Wd
highp float hash(highp vec2 p) {highp vec3 p3 = fract(vec3(p.xyx) * 0.13); p3 += dot(p3, p3.yzx + 6.666); return fract((p3.x + p3.y) * p3.z); }

highp float cloudnoise(highp vec2 x) {
    highp vec2 i = floor(x);
    highp vec2 f = fract(x);

	// Four corners in 2D of a tile
	highp float a = hash(i);
    highp float b = hash(i + vec2(1.0, 0.0));
    highp float c = hash(i + vec2(0.0, 1.0));
    highp float d = hash(i + vec2(1.0, 1.0));

    // Simple 2D lerp using smoothstep envelope between the values.
	// return vec3(mix(mix(a, b, smoothstep(0.0, 1.0, f.x)),
	//			mix(c, d, smoothstep(0.0, 1.0, f.x)),
	//			smoothstep(0.0, 1.0, f.y)));

	// Same code, with the clamps in smoothstep and common subexpressions
	// optimized away.
    highp vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

h1 fbm(highp vec2 x,int octaves) {
	highp float v = 0.0;
	highp float a = 0.5;
	highp vec2 shift = vec2(1.);
	// Rotate to reduce axial bias
    mat2 rot = mat2(cos(1.), sin(1.), -sin(0.6), cos(0.6));
	for (int i = 0; i < octaves; ++i) {
		v += a * cloudnoise(x);
		x =TOTAL_REAL_WORLD_TIME*0.03+x*rot*2.5+shift;
		a *= 0.35;
	}
	return v;
}

void main()
{
vec4 tex;
vec2 ft=FOG_CONTROL;
vec4 fc=FOG_COLOR;
vec3 cubepos=normalize(vec3(eye.x,eye.y-.13,eye.z));
float isday=smoothstep(.15,.2,fc.g);
float israin=smoothstep(.5,.3,ft.x);
float isdusk2=saturate((fc.r-0.1)-fc.b);
float wtime=saturate(texture2D(TEXTURE_1, vec2(0,1)).r);
float isdusk=min(smoothstep(0.3,0.5,wtime),smoothstep(1.,0.8,wtime))*(1.-israin)*(1.-isday);
vec3 p=eye;
p.xyz/=(p.y-.13);
h1 t=mod(TOTAL_REAL_WORLD_TIME,1024.);


vec3 allcolor=mix(mix(vec3(0.),vec3(.1,.26,.56),isday),mix(vec3(0.75,0.75,0.75),vec3(0.),smoothstep(1.,0.2,wtime)),israin);

float cloudpos=min(1.,smoothstep(0.1,0.885,p.y));
float cloud=smoothstep(mix(0.36,0.1,israin),0.7,fbm(t*0.01+vec2(p.x*2.,p.z*0.9),6));
float cloud2=smoothstep(mix(0.36,0.1,israin),0.75,fbm(t*0.01+vec2(p.x*1.3,p.z*0.6),3));
vec3 cday=mix(mix(mix(vec3(0.3,0.3,0.5),vec3(1.1,1.,1.),isday),vec3(0.4,0.2,0.2),isdusk2),mix(vec3(0.3),vec3(0.2),smoothstep(1.,0.2,wtime)),israin);

//if(cloud>0.)cday*=mix(1.,0.7,cloud2);




////high

if(eye.y-.13<0.){
	#if CLOUDS == 1
	tex=vec4(cday,1.);
	tex.a=mix(0.,tex.a,cloudpos*cloud);
	#endif
}else{
	tex=vec4(allcolor,1.);
	tex.a=mix(0.,tex.a,smoothstep(0.,0.4,cubepos.y));
}

//tex=mix(mix(tex,vec4(cday,1.),cloud*cloudpos*(1.-unzn)),vec4(allcolor.rgb,1.),cubepos.y);





////low
//tex=mix(vec4(0),vec4(allcolor,1.),cubepos.y);



	gl_FragColor = tex;
}
