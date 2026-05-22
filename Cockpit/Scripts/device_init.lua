--mount_vfs_model_path(LockOn_Options.script_path.."../Resources/Model/Shape")
mount_vfs_texture_archives("Bazar/Textures/AvionicsCommon")

dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.common_script_path.."tools.lua")

--	items in <...> are optional
--
-- MainPanel = {"NAME_OF_CLASS",
--				"INIT_SCRIPT_FILE",
--				<{devices.LINKED_DEVICE1, devices.LINKED_DEVICE2, ...},>
--			   }

--MainPanel = {"ccMainPanel",
--			 LockOn_Options.script_path.."mainpanel_init.lua",
--				{{"engine_system",devices.ENGINE_SYSTEM}},
 --           }
 

layoutGeometry = {}
			
MainPanel = {"ccMainPanel",LockOn_Options.script_path.."mainpanel_init.lua"}
			 
-- Avionics devices initialization example
--	items in <...> are optional
--
-- creators[DEVICE_ID] = {"NAME_OF_CONTROLLER_CLASS",
--						  <"CONTROLLER_SCRIPT_FILE",>
--						  <{devices.LINKED_DEVICE1, devices.LINKED_DEVICE2, ...},>
--						  <"INPUT_COMMANDS_SCRIPT_FILE",>
--						  <{{"NAME_OF_INDICATOR_CLASS", "INDICATOR_SCRIPT_FILE"}, ...}>
--						 }
creators    = {}
creators[devices.PNEUMATIC_SYSTEM]= {"avLuaDevice", LockOn_Options.script_path.."Systems/pneumatic_system.lua"}
creators[devices.TEST]			  = {"avLuaDevice"		    ,LockOn_Options.script_path.."test_device.lua"}
creators[devices.WEAPON_SYSTEM]	  = {"avSimpleWeaponSystem"  ,LockOn_Options.script_path.."Systems/weapon_system.lua"}
--!!!!creators[devices.CLOCK]			  = {"avAChS_1"			    ,LockOn_Options.script_path.."Systems/radarwarn.lua"}
creators[devices.ADI]			  = {"avBaseIKP"			    ,LockOn_Options.script_path.."adi.lua"}
creators[devices.ELECTRIC_SYSTEM] = {"avSimpleElectricSystem",LockOn_Options.script_path.."Systems/electric_system.lua"}
creators[devices.HYDRAULIC_SYSTEM]= {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/hydraulic_system.lua"}
creators[devices.ENGINE]          = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/engine.lua"}
creators[devices.EXTANIM]         = {"avLuaDevice"           ,LockOn_Options.script_path.."externalanimations.lua"}
creators[devices.GEAR_SYSTEM]     = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/gear_system.lua"}
creators[devices.RADARWARN]       = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/radarwarn.lua"}                   -- !!!!!!!!!!
creators[devices.D_FUEL]          = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/fuel_system.lua"}
creators[devices.WING]          = {"avLuaDevice"           ,LockOn_Options.script_path.."wing.lua"}                   -- !!!!!!!!!!
--creators[devices.D_RADAR_IDX]     = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/radarwarn.lua"} 
creators[devices.AVIONICS]        = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/avionics.lua"}
creators[devices.FLAP_SYSTEM]        = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/flap_system.lua"}
creators[devices.CANOPY]          = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/canopy.lua"}
creators[devices.SPEEDBRAKE]        = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/speedbrake.lua"}
creators[devices.LIGHT_PANEL]     = {"avLuaDevice", LockOn_Options.script_path.."Systems/light_panel.lua"}  
creators[devices.EGT_SYSTEM]      = {"avLuaDevice"           ,LockOn_Options.script_path.."Systems/EGT_System.lua"}  
creators[devices.BAILOUT]         = {"avLuaDevice", LockOn_Options.script_path.."Systems/bailout.lua"}
creators[devices.BRAKES]          = {"avLuaDevice", LockOn_Options.script_path.."Systems/brakes.lua"}
creators[devices.OXYGEN_SYSTEM]   = {"avLuaDevice", LockOn_Options.script_path.."Systems/oxygen_system.lua"}
--RADAROFF creators[devices.RADAR]			 = {"avSimpleRadar"			,LockOn_Options.script_path.."RADAR/Device/init.lua"}

-- Indicators
indicators = {}
indicators[#indicators + 1] = {"ccIndicator" ,LockOn_Options.script_path.."HUD/Indicator/init.lua"  ,nil,{{"PNT-HUD-CENTER","PNT-HUD-DOWN","PNT-HUD-RIGHT"},{sx_l = 0,sy_l = 0,sz_l = 0,sh = 0,sw = 0}}} --HUD
--RADAROFF indicators[#indicators + 1] = {"ccIndicator",LockOn_Options.script_path.."RADAR/Indicator/init.lua",--init script
--RADAROFF   nil,--id of parent device
--RADAROFF   {	
--RADAROFF 	{}, -- initial geometry anchor , triple of connector names 
--RADAROFF 	{sx_l =  0,  -- center position correction in meters (forward , backward)
--RADAROFF 	 sy_l =  0,  -- center position correction in meters (up , down)
--RADAROFF 	 sz_l =  0,  -- center position correction in meters (left , right)
--RADAROFF 	 sh   =  0,  -- half height correction 
--RADAROFF 	 sw   =  0,  -- half width correction 
--RADAROFF 	 rz_l =  0,  -- rotation corrections  
--RADAROFF 	 rx_l =  0,
--RADAROFF 	 ry_l =  0}
--RADAROFF   }
--RADAROFF } --RADAR

			 