// __multiversion__

/*

/////D O N ' T  S T E A L  A N Y C O D E S !!!!

///Made by Glin Shady
///You must follow "GRES licence"

///value noise & fbm "https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83"

/////D O N ' T  S T E A L  A N Y C O D E S !!!!

*/


#include "fragmentVersionSimple.h"

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

#include "uniformShaderConstants.h"

LAYOUT_BINDING(0) uniform sampler2D TEXTURE_0;
LAYOUT_BINDING(1) uniform sampler2D TEXTURE_1;

uniform h1 TOTAL_REAL_WORLD_TIME;
uniform vec4 FOG_COLOR;
uniform vec2 FOG_CONTROL;

varying vec4 cc;
varying float cr;
varying h3 eye;

h1 hash(h1 n) { return fract(sin(n) * 1e4); }
h1 hash(h2 p) { return fract(1e4 * sin(17.0 * p.x + p.y * 0.1) * (0.1 + abs(sin(p.y * 13.0 + p.x)))); }

h1 noise(h2 x) {
	h2 i = floor(x);
	h2 f = fract(x);

	// Four corners in 2D of a tile
	h1 a = hash(i);
	h1 b = hash(i + vec2(1.0, 0.0));
	h1 c = hash(i + vec2(0.0, 1.0));
	h1 d = hash(i + vec2(1.0, 1.0));

	// Simple 2D lerp using smoothstep envelope between the values.
	// return vec3(mix(mix(a, b, smoothstep(0.0, 1.0, f.x)),
	//			mix(c, d, smoothstep(0.0, 1.0, f.x)),
	//			smoothstep(0.0, 1.0, f.y)));

	// Same code, with the clamps in smoothstep and common subexpressions
	// optimized away.
	h2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

h1 fbm(h2 x,int octave) {
	h1 v = 0.0;
	h1 a = 0.4;
	h2 shift = vec2(1000);
	// Rotate to reduce axial bias
    mat2 rot = mat2(cos(1.), sin(1.), -sin(0.5), cos(.5));
	for (int i = 0; i < octave; ++i) {
		v += a * noise(x);
		x = rot * x * 2.5 + shift;
		a *= 0.5;
	}
	return v;
}

void main()
{
vec4 sky=cc;
vec4 fc=FOG_COLOR;
h1 t=mod(TOTAL_REAL_WORLD_TIME,1024.);
float wtime=saturate(texture2D(TEXTURE_1, vec2(0,1)).r);
float israin=smoothstep(0.5,0.3,FOG_CONTROL.x);
float isday=smoothstep(.15,.2,fc.g);
float isdusk=min(smoothstep(0.4,0.5,wtime),smoothstep(1.,0.7,wtime))*(1.-israin);
float isdusk2=saturate((fc.r-0.1)-fc.b);


//vec4 day=mix(mix(vec4(.1,.2,.26,1),vec4(0,.2,.8,1)*1.45,length(eye.xz*1.2)*1.25),vec4(1.),length(eye.xz*1.2)*1.15);

//vec4 day=mix(mix(vec4(0.,0.1,0.2,1.),vec4(0.,0.2,0.8,1.)*1.4,length(eye.xz*1.2)*1.2),vec4(1.),length(eye.xz));

//vec4 day=mix(mix(vec4(0.1),vec4(0.,0.3,0.8,1.),length(eye.xz*2.)*1.2),vec4(1),length(eye.xz*1.5));

vec4 day=mix(mix(vec4(0.2),vec4(0.,0.3,0.8,1.),length(eye.xz*6.)),vec4(1.),smoothstep(.05,.8,cr));
vec4 dusk = mix(vec4(0.,.2,.7,1.),vec4(2.,1.55,0,1),length(eye.xz*1.5));
vec4 rain = mix(mix(vec4(0.3),vec4(0.1),smoothstep(1.,0.2,wtime)),vec4(0.15),length(eye.xz)*1.3);
vec4 night = mix(vec4(0.1,0.1,0.1,1.0),vec4(0.,0.1,0.5,1.),length(eye.xz)*1.2);



sky=mix(mix(mix(night,day,isday),dusk,isdusk2),rain,israin);

	gl_FragColor=mix(sky,fc,cr);
}