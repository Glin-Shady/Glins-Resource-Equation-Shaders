#define off 0 //dont change
#define OFF 0 //dont change
#define on 1 //dont change
#define ON 1 //dont change


/*== Start Customize ==*/

/*--

 Features turn on/off
 
--*/

/*
Enable feature -> on
Disable feature -> off

Dont forget "decimal point"
*/

//-- Water

#define WATER_SURFACE_CAUSTIC on
#define SUN_REFLECTION on //sun reflection when it's sunset or sunrise
#define UNDERWATER_CAUSTIC on //underwater caustic
#define CLOUD_REFLECTION off  //cloud reflection


//-- waving plant and water and underwater

#define PLANT_WAVES on  //Plants wave
#define UNDERWATER_WAVES on //underwater wave

//-- shadow

#define BLOCK_SHADOW on //block shadow

#define shadow_size_start 0.875 //must be start > end
#define shadow_size_end 0.860 //must be start > end

#define shadow_color_R 0.45
#define shadow_color_G 0.45
#define shadow_color_B 0.75

//-- sky

#define CLOUD on

#define CLOUD_TYPE 1
//１　heavy cloud
//２　simple cloud

#define LENS_FLARE on

//-- fog

#define FOGS on

//-- world coloring

#define WORLD_COLORING on

// smaller value is brightness.

//-- Lightning

#define ENABLE_TORCH_LIGHTNING on

#define NORMAL_TORCH_R 2.2
#define NORMAL_TORCH_G 0.4
#define NORMAL_TORCH_B 0.0

//3D effects

#define BUMPMAP off
#define resolution 16.0 //16-32-64
#define height_bump 250.0

//-- other

#define VIGNETTE on

#define B_GLOWING_ORES on

/*== End Customize ==*/




/*---------------------------------------*/

/*
DONT ENTER TO BELOW
*/
