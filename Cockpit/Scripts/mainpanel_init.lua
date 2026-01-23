shape_name   	   = "MiG-23M_cockpit"
is_EDM			   = true
new_model_format   = true
ambient_light    = {255,255,255}
ambient_color_day_texture    = {72, 100, 160}
ambient_color_night_texture  = {40, 60 ,150}
ambient_color_from_devices   = {50, 50, 40}
ambient_color_from_panels	 = {35, 25, 25}

dusk_border					 = 0.4
draw_pilot					 = false

external_model_canopy_arg	 = 38

use_external_views = false 
--cockpit_local_point = {2.419, 0.818, 0.0}

day_texture_set_value   = 0.0
night_texture_set_value = 0.1

local  aircraft = get_aircraft_type()

local controllers = LoRegisterPanelControls()

mirrors_data = 
{
    center_point 	= {0.6,0.40,0.00},
    width 		 	= 0.3,
    aspect 		 	= 1.7, 
	rotation 	 	= math.rad(-20);
	animation_speed = 2.0;
	near_clip 		= 0.1;
	middle_clip		= 10;
	far_clip		= 60000;
}
-- Код Рустам
mirrors_draw                    = CreateGauge()
mirrors_draw.arg_number    		= 16
mirrors_draw.input   			= {0,1}
mirrors_draw.output   			= {1,0}
mirrors_draw.controller         = controllers.mirrors_draw

Canopy    						= CreateGauge()
Canopy.arg_number 				= 128
Canopy.input   					= {0,1}
Canopy.output  					= {0,0.9}
Canopy.controller 				= controllers.base_gauge_CanopyPos

CanopyLever    						= CreateGauge()
CanopyLever.arg_number 				= 129
CanopyLever.input   				= {0, 0.2, 0.9}
CanopyLever.output  				= {1, 0.5, 0.0}
CanopyLever.controller 				= controllers.base_gauge_CanopyPos

-- Canopy Open Indicator Light
CanopyOpenLight    						= CreateGauge()
CanopyOpenLight.arg_number 				= 1222
CanopyOpenLight.input   				= {0.0, 0.01, 1.0}
CanopyOpenLight.output  				= {0.0, 1.0, 1.0}
CanopyOpenLight.controller 				= controllers.base_gauge_CanopyPos

StickPitch						= CreateGauge()
StickPitch.arg_number			= 2
StickPitch.input				= {-100, 100}
StickPitch.output				= {-1, 1}
StickPitch.controller			= controllers.base_gauge_StickPitchPosition

StickBank						= CreateGauge()
StickBank.arg_number			= 3
StickBank.input					= {-100, 100}
StickBank.output				= {-1, 1}
StickBank.controller			= controllers.base_gauge_StickRollPosition

RudderPedals					= CreateGauge()
RudderPedals.arg_number			= 4
RudderPedals.input				= {-100,100}
RudderPedals.output				= {-1,1}
RudderPedals.controller			= controllers.base_gauge_RudderPosition

Throttle						= CreateGauge()
Throttle.arg_number				= 5
Throttle.input					= {0, 1}
Throttle.output					= {0, 1}
Throttle.controller				= controllers.base_gauge_ThrottleLeftPosition

Landinggearhandle							= CreateGauge()
Landinggearhandle.arg_number				= 8
Landinggearhandle.input						= {0, 1}
Landinggearhandle.output					= {1, 0}
Landinggearhandle.controller				= controllers.base_gauge_LandingGearHandlePos

---------------------------------------------------------------
-- ENGINE
---------------------------------------------------------------

EngineLeftRPM							= CreateGauge()
EngineLeftRPM.arg_number				= 50
EngineLeftRPM.input						= {0.0, 80, 110.0} 
EngineLeftRPM.output					= {0.0, 0.3, 1.0}
EngineLeftRPM.controller				= controllers.base_gauge_EngineLeftRPM

EngineRightRPM							= CreateGauge()
EngineRightRPM.arg_number				= 51
EngineRightRPM.input					= {0.0, 80, 110.0} 
EngineRightRPM.output					= {0.0, 0.3, 1.0}
EngineRightRPM.controller				= controllers.base_gauge_EngineRightRPM


Engine_TEMP							= CreateGauge("parameter")
Engine_TEMP.parameter_name		= "MIG23_EGT"
Engine_TEMP.arg_number				= 20
Engine_TEMP.input					= {300, 600, 900} 
Engine_TEMP.output					= {0.0, 0.5, 1.0}

---------------------------------------------------------------
-- KPP
---------------------------------------------------------------

KPP_roll					= CreateGauge("parameter")
KPP_roll.arg_number			= 35
KPP_roll.input				= {-180, 180} -- в градусах
KPP_roll.output				= {-1, 1}
KPP_roll.parameter_name 	= "KPP_1273K_roll"

KPP_pitch					= CreateGauge("parameter")
KPP_pitch.arg_number		= 34
KPP_pitch.input				= {-80, 80} -- в градусах
KPP_pitch.output			= {-1, 1}
KPP_pitch.parameter_name 	= "KPP_1273K_pitch"

KPP_sideslip				= CreateGauge("parameter")
KPP_sideslip.arg_number		= 33
KPP_sideslip.input			= {-1.0, 1.0}
KPP_sideslip.output			= {-1.0, 1.0}
KPP_sideslip.parameter_name	= "KPP_1273K_sideslip"

---------------------------------------------------------------
-- INSTRUMENTS
---------------------------------------------------------------

IndicatedAirSpeed							= CreateGauge("parameter")
IndicatedAirSpeed.arg_number				= 100
IndicatedAirSpeed.input						= {0.0, 250,  500,  750, 1000}  --m/s
IndicatedAirSpeed.output					= {0.0, 0.25, 0.5, 0.75, 1.0}
IndicatedAirSpeed.parameter_name  			= "AIR_SPD"

IndicatedAirSpeedThousand					= CreateGauge("parameter")
IndicatedAirSpeedThousand.arg_number		= 101
IndicatedAirSpeedThousand.input				= {0,1}  
IndicatedAirSpeedThousand.output			= {0.0, 1.0}
IndicatedAirSpeedThousand.parameter_name  	= "AIR_SPD_THSND"

-----------------------------------------------------------------
-- CLOCK
-----------------------------------------------------------------

ACHS_ClockHour								= CreateGauge("parameter")
ACHS_ClockHour.arg_number					= 151
ACHS_ClockHour.input						= {0, 12}  
ACHS_ClockHour.output						= {0.0, 1.0}
ACHS_ClockHour.parameter_name  				= "ACHS_CH"

ACHS_ClockMin								= CreateGauge("parameter")
ACHS_ClockMin.arg_number					= 152
ACHS_ClockMin.input							= {0,60}  
ACHS_ClockMin.output						= {0.0, 1.0}
ACHS_ClockMin.parameter_name  				= "ACHS_CM"

ACHS_ClockSec								= CreateGauge("parameter")
ACHS_ClockSec.arg_number					= 150
ACHS_ClockSec.input							= {0,60}  
ACHS_ClockSec.output						= {0.0, 1.0}
ACHS_ClockSec.parameter_name  				= "ACHS_CS"

ACHS_TimerHour								= CreateGauge("parameter")
ACHS_TimerHour.arg_number					= 155
ACHS_TimerHour.input						= {0, 12}  
ACHS_TimerHour.output						= {0.0, 1.0}
ACHS_TimerHour.parameter_name  				= "ACHS_T_CH"

ACHS_TimerMin								= CreateGauge("parameter")
ACHS_TimerMin.arg_number					= 154
ACHS_TimerMin.input							= {0,60}  
ACHS_TimerMin.output						= {0.0, 1.0}
ACHS_TimerMin.parameter_name  				= "ACHS_T_CM"

ACHS_TimerSwitch							= CreateGauge("parameter")
ACHS_TimerSwitch.arg_number					= 161
ACHS_TimerSwitch.input						= {0.0, 0.5, 1.0}  
ACHS_TimerSwitch.output						= {0.0, 0.5, 1.0}
ACHS_TimerSwitch.parameter_name  			= "ACHS_T_SWITCH"

ACHS_Stopwatch								= CreateGauge("parameter")
ACHS_Stopwatch.arg_number					= 156
ACHS_Stopwatch.input						= {0.0, 30.0}  
ACHS_Stopwatch.output						= {0.0, 1.0}
ACHS_Stopwatch.parameter_name  				= "ACHS_STOPWATCH" 


--[[
TrueAirSpeed								= CreateGauge()
TrueAirSpeed.arg_number						= 100
TrueAirSpeed.input							= {0.0, 5.55, 34.72,  70,  139,  208, 278,  347,  417,  487, 555}  --m/s
TrueAirSpeed.output							= {0.0, 0.04, 0.08, 0.12, 0.25, 0.37, 0.5, 0.62, 0.75, 0.88, 1.0}
TrueAirSpeed.controller						= controllers.base_gauge_TrueAirSpeed
]]


RadarAltitude						= CreateGauge("parameter")
RadarAltitude.parameter_name  	 	= "D_RADAR_ALT"
RadarAltitude.arg_number			= 9
RadarAltitude.input					= {0,   200, 1000, 1500}
RadarAltitude.output				= {0.0, 0.6, 0.85, 1}


LAWS_indexer						= CreateGauge("parameter")
LAWS_indexer.arg_number				= 8
LAWS_indexer.input					= {0,   200, 1000, 1500}
LAWS_indexer.output					= {0.0, 0.6, 0.85, 1}
LAWS_indexer.parameter_name   		= "D_RADAR_IDX"

LAWS_light_gauge					= CreateGauge("parameter")
LAWS_light_gauge.arg_number			= 11
LAWS_light_gauge.input				= { 0.0, 1.0}
LAWS_light_gauge.output				= { 0.0, 1.0}
LAWS_light_gauge.parameter_name   	= "D_RADAR_WARN"

LAWS_OFF						= CreateGauge("parameter")
LAWS_OFF.arg_number				= 7
LAWS_OFF.input					= {0.0, 1.0}
LAWS_OFF.output					= {0.0, 1.0}
LAWS_OFF.parameter_name   		= "D_RADAR_OFF"

-- LAWS_regulator					= CreateGauge("parameter")
-- LAWS_regulator.arg_number		= 10
-- LAWS_regulator.input			= {0, 90, 200, 600, 1500}
-- LAWS_regulator.output			= {-1.0, -0.5, 0.0, 0.5, 1.0}
-- LAWS_regulator.parameter_name   = "D_RADAR_REGULATOR"



--RadarAltitude.controller			 = "D_RADAR_ALT" -- controllers.base_gauge_RadarAltitude     						 -- !!!!!!!!!!

FuelGauge                      		 = CreateGauge("parameter")
FuelGauge.arg_number          		 = 580
FuelGauge.parameter_name      		 = "D_FUEL"
FuelGauge.input               		 = {0.0, 8400.0} 
FuelGauge.output              		 = {0.0, 1.0}											 -- !!!!!!!!!!

ADISlip                          	 = CreateGauge("parameter")
ADISlip.parameter_name           	 = "ADI_SLIP"						 -- !!!!!!!!!!
ADISlip.arg_number               	 = 665
ADISlip.input                    	 = {-1.0, 1.0}
ADISlip.output                   	 = {-1.0, 1.0}

ADITurn                          	 = CreateGauge("parameter")
ADITurn.parameter_name           	 = "ADI_TURN"						 -- !!!!!!!!!!
ADITurn.arg_number               	 = 664
ADITurn.input                    	 = {-1.0, 1.0}
ADITurn.output                   	 = {-1.0, 1.0}

WingAngleIndicator                   = CreateGauge("parameter")
WingAngleIndicator.parameter_name    = "WING_ANGLE_INDICATOR"						 -- !!!!!!!!!!
WingAngleIndicator.arg_number        = 451
WingAngleIndicator.input             = {0,1000}
WingAngleIndicator.output            = {0.0, 1.0}

DesiredWingAngle                   	 = CreateGauge("parameter")
DesiredWingAngle.parameter_name  	 = "DES_WING_ANGLE"					 -- !!!!!!!!!!
DesiredWingAngle.arg_number        	 = 452
DesiredWingAngle.input             	 = {0, 1000}
DesiredWingAngle.output            	 = {0.0, 1.0}

AngleMaxLimMah                   	 = CreateGauge("parameter")
AngleMaxLimMah.parameter_name  	     = "ANGLE_MAX_LIM_MAH"					 -- !!!!!!!!!!
AngleMaxLimMah.arg_number        	 = 453
AngleMaxLimMah.input             	 = {0, 1000}
AngleMaxLimMah.output            	 = {0.0, 1.0}

AngleMaxLimSpeed					 = CreateGauge("parameter")
AngleMaxLimSpeed.parameter_name  	 = "ANGLE_MAX_LIM_SPEED"					 -- !!!!!!!!!!
AngleMaxLimSpeed.arg_number        	 = 454
AngleMaxLimSpeed.input             	 = {0, 1000}
AngleMaxLimSpeed.output            	 = {0.0, 1.0}

FuelWarning					 		 = CreateGauge("parameter")
FuelWarning.parameter_name  		 = "FUEL_WARNING"					 -- !!!!!!!!!!
FuelWarning.arg_number        		 = 460
FuelWarning.input             		 = {0, 1}
FuelWarning.output            		 = {0.0, 1.0}

Altimeter							 = CreateGauge("parameter")
Altimeter.parameter_name    		 = "D_ALT_NEEDLE"
Altimeter.arg_number				 = 12
Altimeter.input						 = {0.0, 1000.0}
Altimeter.output					 = {0.0, 1.0}

MachNumber							 = CreateGauge()
MachNumber.arg_number				 = 110
MachNumber.input					 = {0,3}
MachNumber.output					 = {0.0, 1.0}
MachNumber.controller				 = controllers.base_gauge_MachNumber

TrueAirSpeed						 = CreateGauge()
TrueAirSpeed.arg_number				 = 111
TrueAirSpeed.input					 = {0, 1700}
TrueAirSpeed.output					 = {0.0, 1.0}
TrueAirSpeed.controller				 = controllers.base_gauge_TrueAirSpeed



TEST_PARAM_GAUGE      			  = CreateGauge("parameter")
TEST_PARAM_GAUGE.parameter_name   = "TEST"
TEST_PARAM_GAUGE.arg_number    	  = 113
TEST_PARAM_GAUGE.input    		  = {0,100} 
TEST_PARAM_GAUGE.output    		  = {0,1}

EngineLeftTemp		  			  = CreateGauge()
EngineLeftTemp.arg_number		  = 70
EngineLeftTemp.input			  = {0, 1000}
EngineLeftTemp.output			  = {0.0, 1.0}
EngineLeftTemp.controller		  = controllers.base_gauge_EngineLeftTemperatureBeforeTurbine

EngineRightTemp		  			  = CreateGauge()
EngineRightTemp.arg_number		  = 71
EngineRightTemp.input			  = {0, 1000}
EngineRightTemp.output			  = {0.0, 1.0}
EngineRightTemp.controller		  = controllers.base_gauge_EngineRightTemperatureBeforeTurbine

--[[
EngineLeftFuel		  			  = CreateGauge()
EngineLeftFuel.arg_number		  = 70
EngineLeftFuel.input			  = {0, 1000}
EngineLeftFuel.output			  = {0.0, 1.0}
EngineLeftFuel.controller		  = controllers.base_gauge_EngineLeftFuelConsumption

EngineRightFuel		  			  = CreateGauge()
EngineRightFuel.arg_number		  = 71
EngineRightFuel.input			  = {0, 1000}
EngineRightFuel.output			  = {0.0, 1.0}
EngineRightFuel.controller		  = controllers.base_gauge_EngineRightFuelConsumption
]]

AoA								  = CreateGauge()
AoA.arg_number					  = 130
AoA.input						  = {-0.174, 0.698}
AoA.output						  = {-0.25, 1.0}
AoA.controller					  = controllers.base_gauge_AngleOfAttack
--[[
Ny							  	  = CreateGauge()
Ny.arg_number					  = 130
Ny.input						  = {-0.174, 0.698}
Ny.output						  = {-0.25, 1.0}
Ny.controller					  = controllers.base_gauge_AngleOfAttack
]]


AttGyroStbyPitch                = CreateGauge()
AttGyroStbyPitch.arg_number     = 660
AttGyroStbyPitch.input          = {-1.39, 1.39}
AttGyroStbyPitch.output         = {-1.0, 1.0}
AttGyroStbyPitch.controller		= controllers.base_gauge_Pitch


AttGyroStbyRoll                = CreateGauge()
AttGyroStbyRoll.arg_number     = 661
AttGyroStbyRoll.input          = {-6.28, 6.28}
AttGyroStbyRoll.output         = {-1.0, 1.0}
AttGyroStbyRoll.controller	   = controllers.base_gauge_Roll


Ball_Slide_AVH					= CreateGauge()
Ball_Slide_AVH.arg_number		= 670
Ball_Slide_AVH.input			= {-1, 1}
Ball_Slide_AVH.output 			= {-1.0, 1.0}
Ball_Slide_AVH.controller		= controllers.base_gauge_AngleOfSlide

VerticalVelocity				= CreateGauge("parameter")
VerticalVelocity.arg_number		= 140
VerticalVelocity.input			= {-200,  -100,   -50,   -20,   -10,   0,   10,   20,   50,  100, 200} -- !!!!!!!!!!!!!!!!!!!!
VerticalVelocity.output			= {-1.0, -0.70, -0.50, -0.44, -0.22, 0.0, 0.22, 0.44, 0.50, 0.70, 1.0}
VerticalVelocity.parameter_name = "VVI"

RollVelocity         	    	= CreateGauge()
RollVelocity.arg_number     	= 662
RollVelocity.input          	= {-3.14/90, 3.14/90}
RollVelocity.output         	= {1.0, -1.0}
RollVelocity.controller	   		= controllers.base_gauge_RateOfYaw

MagneticHeading					= CreateGauge()
MagneticHeading.arg_number 		= 350
MagneticHeading.input 			= {0, 6.28319}
MagneticHeading.output 			= {-1.0, 1.0}
MagneticHeading.controller		= controllers.base_gauge_MagneticHeading


BDHI_Heading                        = CreateGauge("parameter")
BDHI_Heading.parameter_name         = "BDHI_HDG"
BDHI_Heading.arg_number             = 350
BDHI_Heading.input                  = {0.0, 360.0}
BDHI_Heading.output                 = {-1.0, 1.0}

BDHI_Needle1                        = CreateGauge("parameter")
BDHI_Needle1.parameter_name         = "BDHI_NEEDLE1"
BDHI_Needle1.arg_number             = 781
BDHI_Needle1.input                  = {0.0, 360.0}
BDHI_Needle1.output                 = {0.0, 1.0}

BDHI_Needle2                        = CreateGauge("parameter")
BDHI_Needle2.parameter_name         = "BDHI_NEEDLE2"
BDHI_Needle2.arg_number             = 782
BDHI_Needle2.input                  = {0.0, 360.0}
BDHI_Needle2.output                 = {0.0, 1.0}

BDHI_DME_Flag                       = CreateGauge("parameter")
BDHI_DME_Flag.parameter_name        = "BDHI_DME_FLAG"
BDHI_DME_Flag.arg_number            = 357
BDHI_DME_Flag.input                 = {0, 1.0}
BDHI_DME_Flag.output                = {0, 1.0}

BDHI_DME_Xxx                        = CreateGauge("parameter")
BDHI_DME_Xxx.parameter_name         = "BDHI_DME_Xxx"
BDHI_DME_Xxx.arg_number             = 356
BDHI_DME_Xxx.input                  = {0, 1.0}
BDHI_DME_Xxx.output                 = {0, 1.00}

BDHI_DME_xXx                        = CreateGauge("parameter")
BDHI_DME_xXx.parameter_name         = "BDHI_DME_xXx"
BDHI_DME_xXx.arg_number             = 355
BDHI_DME_xXx.input                  = {0, 1.0}
BDHI_DME_xXx.output                 = {0, 1.00}

BDHI_DME_xxX                        = CreateGauge("parameter")
BDHI_DME_xxX.parameter_name         = "BDHI_DME_xxX"
BDHI_DME_xxX.arg_number             = 354
BDHI_DME_xxX.input                  = {0, 1.0}
BDHI_DME_xxX.output                 = {0, 1.00}

FLAP_IND							= CreateGauge("parameter")
FLAP_IND.parameter_name				= "FLAP_IND"
FLAP_IND.arg_number					= 555
FLAP_IND.input						= {0,1}
FLAP_IND.output						= {0,1}


-----------------------------------------------------------------
-- GEAR INDICATION
-----------------------------------------------------------------

GearNoseRELEASED					 	 	 = CreateGauge("parameter")
GearNoseRELEASED.parameter_name  		  	 = "GEAR_NOSE_RELEASED"					 -- !!!!!!!!!!
GearNoseRELEASED.arg_number        		 = 25
GearNoseRELEASED.input             		 = {0, 1}
GearNoseRELEASED.output            		 = {0.0, 1.0}

GearNoseRETRACTED					 	 = CreateGauge("parameter")
GearNoseRETRACTED.parameter_name  		 = "GEAR_NOSE_RETRACTED"					 -- !!!!!!!!!!
GearNoseRETRACTED.arg_number        		 = 28
GearNoseRETRACTED.input             		 = {0, 1}
GearNoseRETRACTED.output            		 = {0.0, 1.0}

GearRightRELEASED					 		 = CreateGauge("parameter")
GearRightRELEASED.parameter_name  		 = "GEAR_RIGHT_RELEASED"					 -- !!!!!!!!!!
GearRightRELEASED.arg_number        		 = 26
GearRightRELEASED.input             		 = {0, 1}
GearRightRELEASED.output            		 = {0.0, 1.0}

GearRightRETRACTED					 	 = CreateGauge("parameter")
GearRightRETRACTED.parameter_name  		 = "GEAR_RIGHT_RETRACTED"					 -- !!!!!!!!!!
GearRightRETRACTED.arg_number        	 = 29
GearRightRETRACTED.input             	 = {0, 1}
GearRightRETRACTED.output            	 = {0.0, 1.0}

GearLeftRELEASED					 		 = CreateGauge("parameter")
GearLeftRELEASED.parameter_name  			 = "GEAR_LEFT_RELEASED"					 -- !!!!!!!!!!
GearLeftRELEASED.arg_number        		 = 27
GearLeftRELEASED.input             		 = {0, 1}
GearLeftRELEASED.output            		 = {0.0, 1.0}

GearLeftRETRACTED					 	 = CreateGauge("parameter")
GearLeftRETRACTED.parameter_name  		 = "GEAR_LEFT_RETRACTED"					 -- !!!!!!!!!!
GearLeftRETRACTED.arg_number        		 = 30
GearLeftRETRACTED.input             		 = {0, 1}
GearLeftRETRACTED.output            		 = {0.0, 1.0}

ReleaseGear					 		 = CreateGauge("parameter")
ReleaseGear.parameter_name  		 = "RELEASE_GEAR"					 -- !!!!!!!!!!
ReleaseGear.arg_number       	 	 = 32
ReleaseGear.input            	 	 = {0, 1}
ReleaseGear.output           	 	 = {0.0, 1.0}

ReleaseFlaps					 	 = CreateGauge("parameter")
ReleaseFlaps.parameter_name  		 = "RELEASE_FLAPS"					 -- !!!!!!!!!!
ReleaseFlaps.arg_number       	 	 = 31
ReleaseFlaps.input            	 	 = {0, 1}
ReleaseFlaps.output           	 	 = {0.0, 1.0}

GearFlapsClosed					 	 = CreateGauge("parameter")
GearFlapsClosed.parameter_name  	 = "GEAR_FLAPS_CLOSED"					 -- !!!!!!!!!!
GearFlapsClosed.arg_number       	 = 33
GearFlapsClosed.input            	 = {0, 1}
GearFlapsClosed.output           	 = {0.0, 1.0}


-----------------------------------------------------------------
-- LIGHTS PANEL
-----------------------------------------------------------------

EnginePowerMax							= CreateGauge("parameter")
EnginePowerMax.arg_number				= 464
EnginePowerMax.input					= {0.0, 1.0} 
EnginePowerMax.output					= {0.0, 1.0}
EnginePowerMax.parameter_name  			= "ENG_POWER_MAX"

EnginePowerAfterburn					= CreateGauge("parameter")
EnginePowerAfterburn.arg_number			= 465
EnginePowerAfterburn.input				= {0.0, 1.0} 
EnginePowerAfterburn.output				= {0.0, 1.0} 
EnginePowerAfterburn.parameter_name  	= "ENG_POWER_AFTERBURN"

WingWarning							 = CreateGauge("parameter")
WingWarning.parameter_name  		 = "WING_WARNING"					 -- !!!!!!!!!!
WingWarning.arg_number        		 = 466
WingWarning.input             		 = {0.0, 1.0}
WingWarning.output            		 = {0.0, 1.0}

FuelWarning					 		 = CreateGauge("parameter")
FuelWarning.parameter_name  		 = "FUEL_WARNING"					 
FuelWarning.arg_number        		 = 460
FuelWarning.input             		 = {0, 1}
FuelWarning.output            		 = {0.0, 1.0}

TrimRollKnob					 	 = CreateGauge("parameter")
TrimRollKnob.parameter_name  		 = "ROLL_TRIM_KNOB"					 -- !!!!!!!!!!
TrimRollKnob.arg_number        		 = 500
TrimRollKnob.input             		 = {-1, 1}
TrimRollKnob.output            		 = {-1.0, 1.0}

TrimPitchKnob				 		 = CreateGauge("parameter")
TrimPitchKnob.parameter_name  		 = "PITCH_TRIM_KNOB"					 -- !!!!!!!!!!
TrimPitchKnob.arg_number        	 = 501
TrimPitchKnob.input             	 = {-1, 1}
TrimPitchKnob.output            	 = {-1.0, 1.0}

TrimRudderKnob					 	 = CreateGauge("parameter")
TrimRudderKnob.parameter_name  		 = "RUDDER_TRIM_KNOB"					 -- !!!!!!!!!!
TrimRudderKnob.arg_number        	 = 503
TrimRudderKnob.input             	 = {-1, 1}
TrimRudderKnob.output            	 = {-1.0, 1.0}

TrimPitch					 		 = CreateGauge("parameter")
TrimPitch.parameter_name  			 = "TRIM_PITCH_GAUGE"					 -- !!!!!!!!!!
TrimPitch.arg_number        		 = 463
TrimPitch.input             		 = {0, 1}
TrimPitch.output            		 = {0.0, 1.0}

TrimRoll					 		 = CreateGauge("parameter")
TrimRoll.parameter_name  			 = "TRIM_ROLL_GAUGE"					 -- !!!!!!!!!!
TrimRoll.arg_number        			 = 462
TrimRoll.input             			 = {0, 1}
TrimRoll.output            			 = {0.0,1.0}

TrimRudder					 		 = CreateGauge("parameter")
TrimRudder.parameter_name  		 	 = "TRIM_RUBBER_GAUGE"					 -- !!!!!!!!!!
TrimRudder.arg_number        		 = 461
TrimRudder.input             		 = {0, 1}
TrimRudder.output            		 = {0.0,1.0}
--[[
Ny_acc							  = CreateGauge()
Ny_acc.arg_number				  = 81
Ny_acc.input					  = {-2, 11}
Ny_acc.output					  = {}
Ny_acc.controller				  = controllers.base_gauge_VerticalAcceleration
]]

-----------------------------------------------------------------
-- HYDRAULIC SYSTEM
-----------------------------------------------------------------

BusterHydroPressGauge                  = CreateGauge("parameter")
BusterHydroPressGauge.parameter_name   = "BUSTER_HYDRO_PRESS"
BusterHydroPressGauge.arg_number       = 123 -- Updated to user's argument ID
BusterHydroPressGauge.input            = {0.0, 300.0} -- Scale from 0 to 300 kgf/cm^2
BusterHydroPressGauge.output           = {0.0, 1.0}   -- Animation range (0 = 0 bar, 1 = 300 bar)

need_to_be_closed = true -- close lua state after initialization 



--[[ available functions 

 --base_gauge_RadarAltitude
 --base_gauge_BarometricAltitude
 --base_gauge_AngleOfAttack
 --base_gauge_AngleOfSlide
 --base_gauge_VerticalVelocity
 --base_gauge_TrueAirSpeed
 --base_gauge_IndicatedAirSpeed
 --base_gauge_MachNumber
 --base_gauge_VerticalAcceleration --Ny
 --base_gauge_HorizontalAcceleration --Nx
 --base_gauge_LateralAcceleration --Nz
 --base_gauge_RateOfRoll
 --base_gauge_RateOfYaw
 --base_gauge_RateOfPitch
 --base_gauge_Roll
 --base_gauge_MagneticHeading
 --base_gauge_Pitch
 --base_gauge_Heading
 --base_gauge_EngineLeftFuelConsumption
 --base_gauge_EngineRightFuelConsumption
 --base_gauge_EngineLeftTemperatureBeforeTurbine
 --base_gauge_EngineRightTemperatureBeforeTurbine
 --base_gauge_EngineLeftRPM
 --base_gauge_EngineRightRPM
 --base_gauge_WOW_RightMainLandingGear
 --base_gauge_WOW_LeftMainLandingGear
 --base_gauge_WOW_NoseLandingGear
 --base_gauge_RightMainLandingGearDown
 --base_gauge_LeftMainLandingGearDown
 --base_gauge_NoseLandingGearDown
 --base_gauge_RightMainLandingGearUp
 --base_gauge_LeftMainLandingGearUp
 --base_gauge_NoseLandingGearUp
 --base_gauge_LandingGearHandlePos
 --base_gauge_StickRollPosition
 --base_gauge_StickPitchPosition
 --base_gauge_RudderPosition
 --base_gauge_ThrottleLeftPosition
 --base_gauge_ThrottleRightPosition
 --base_gauge_HelicopterCollective
 --base_gauge_HelicopterCorrection
 --base_gauge_CanopyPos
 --base_gauge_CanopyState
 --base_gauge_FlapsRetracted
 --base_gauge_SpeedBrakePos
 --base_gauge_FlapsPos
]]