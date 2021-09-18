#ifndef WELCOME_TO_GRES_SETTINGS
#define WELCOME_TO_GRES_SETTINGS

#include "User/Dont_edit.h"

/*
///////// Welcome To GRES Settings //////////////

you can set the feature on or off and set the value.

on -> The feature is enabled
off -> The feature is disabled

vec3(R,G,B) // You must add a decimal point.

/////////////////////////////////////////////////
*/





////////////// Start Settings /////////////////

// GRES Lights / GRESの光源

#define NormalLightColor vec3(1.9,0.9,0.0) // 基本的な光源の色 / Normaly Light Color

// GRES World coloring / GRESの地形の色

#define DayColor vec3(1.3,1.2,1.1) // 昼間の色 / day Color
#define NightColor vec3(0.2,0.2,0.2) // 夜間の色 / Night Color
#define RainColor vec3(0.8,0.8,0.8) // 雨の色 / Wet Color
#define UnderwaterColor vec3(0.4,0.7,0.9) // 水中の色 / Underwater Color
#define DuskColor vec3(1.1,0.9,0.7) // 夕暮れ・朝方の色 / Sunset,Sunrise Color

// GRES Shadow / GRESの影

#define SHADOW_COLOR vec3(0.35,0.35,0.45) // 影の色 / shadow color

// Water / 水

//１: High
//２: Medium
#define WATER_QUALITY 1 // 水の質感 / Water Quality

#define WATER_SURFACE_CAUSTIC off // 水面の水の波 / water surface caustics

// Underwater / 水中

#define UNDERWATER_CAUSTIC off // 水中での光の差し込み // caustics underwater

// Clouds / 雲

#define CLOUDS off // 雲 / Cloud

// GRES fog / GRESの霧

#define GRES_FOG on // 霧&雨の効果 / Fogs & Wet Effect




//////////// End Settings /////////////////////




#endif