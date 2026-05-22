dofile(LockOn_Options.script_path.."clickable_defs.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.script_path.."sounds.lua")
--dofile(LockOn_Options.common_script_path..'localizer.lua')

local gettext = require("i_18n")
_ = gettext.translate

elements = {}

--THESE SOUNDS ARE DEFINED BY /Cockpit/Scripts/sounds.lua

elements["PNT_10"] = default_axis_limited("Warning altimetr", devices.RADARWARN, device_commands.warn_alt, 10, 0.0, 0.1, false, true, {0,1})

elements["PNT_20"] = default_button("Flap cleared", devices.FLAP_SYSTEM, device_commands.BtnFlapsCleared, 20)
elements["PNT_20"].stop_action = nil
elements["PNT_21"] = default_button("Flap takeoff", devices.FLAP_SYSTEM, device_commands.BtnFlapsTakeOff,21)
elements["PNT_21"].stop_action = nil
elements["PNT_22"] = default_button("Flap landing", devices.FLAP_SYSTEM, device_commands.BtnFlapsLanding,22)
elements["PNT_22"].stop_action = nil
elements["PNT_23"] = default_button("Flap off", devices.FLAP_SYSTEM, device_commands.BtnFlapsOff, 23, 1,1)
elements["PNT_28"] = default_2_position_tumb("Canopy Lever", devices.CANOPY, Keys.Canopy, 28)

elements["PNT_158"] = default_button_axis("Winding crown", devices.RADARWARN, device_commands.warn_crown_push, device_commands.warn_crown_twist,158,157)
elements["PNT_158"].class = {class_type.TUMB, class_type.LEV}
elements["PNT_158"].relative = {false,false}
elements["PNT_158"].arg_lim = {{0, 1}, {0, 1}}

elements["PNT_160"] = default_button_axis("Clock", devices.RADARWARN, device_commands.starter_push, device_commands.starter_twist,160,159)
elements["PNT_160"].class = {class_type.TUMB, class_type.TUMB}
elements["PNT_160"].relative = {false,false}
elements["PNT_160"].arg_value = {{0, 1}, {0, 1}}
elements["PNT_160"].arg_lim = {{0, 1}, {0, 0.5}}

elements["PNT_450"] =  multiposition_switch_limited("Wing Angle", devices.WING, device_commands.wing_angle, 450, 5, 0.25, false, 0.0)

elements["PNT_40"] = default_2_position_tumb("Speedbrake", devices.SPEEDBRAKE, device_commands.speedbrake, 40)

elements["PNT_BRAKE_LEVER"] = default_button("Wheel Brake Lever", devices.PNEUMATIC_SYSTEM, device_commands.pneumo_brake_lever, -1)

-- electirc\engine
elements["PNT_BAT_EXT"] = multiposition_switch_limited("Питание: Борт - Выкл - Аэрод", devices.ELECTRIC_SYSTEM, device_commands.BatteryExtSwitch, 165, 3, 1, false, -1.0)
elements["PNT_DC_GEN"] = default_2_position_tumb("Генератор постоянного тока", devices.ELECTRIC_SYSTEM, device_commands.GeneratorDCSwitch, 166)
elements["PNT_AC_GEN"] = default_2_position_tumb("Генератор переменного тока", devices.ELECTRIC_SYSTEM, device_commands.GeneratorACSwitch, 167)

-- Топливные насосы
elements["PNT_PUMP_TANK1"] = default_2_position_tumb("Насос бака 1", devices.D_FUEL, device_commands.FuelPump_Tank1, 2008)
elements["PNT_PUMP_TANK3"] = default_2_position_tumb("Насос бака 3", devices.D_FUEL, device_commands.FuelPump_Tank3, 2009)
elements["PNT_PUMP_EXPI"] = default_2_position_tumb("Расходный насос I", devices.D_FUEL, device_commands.FuelPump_ExpI, 2010)
elements["PNT_PUMP_EXPII"] = default_2_position_tumb("Расходный насос II", devices.D_FUEL, device_commands.FuelPump_ExpII, 2011)

-- ECM panel
elements["PNT_503"] = default_2_position_tumb("Audio ALQ Switch", devices.RADARWARN, device_commands.ecm_apr25_audio, 503, TOGGLECLICK_LEFT_MID)
elements["PNT_504"] = default_2_position_tumb("APR-25 Switch", devices.RADARWARN, device_commands.ecm_apr25_off, 504, TOGGLECLICK_LEFT_MID)
elements["PNT_501"] = default_2_position_tumb("APR-27 Switch", devices.RADARWARN, device_commands.ecm_apr27_off, 501, TOGGLECLICK_LEFT_MID)
elements["PNT_507"] = default_button("APR-27 Test", devices.RADARWARN, device_commands.ecm_systest_upper, 507)
elements["PNT_510"] = default_button("APR-27 Light", devices.RADARWARN, device_commands.ecm_systest_lower, 510)
elements["PNT_506"] = default_axis_limited("PRF Volume", devices.RADARWARN, device_commands.ecm_msl_alert_axis_inner, 506, 0.0, 0.3, false, false, {-0.9,0.9} )
elements["PNT_505"] = default_axis_limited("Missile Alert Volume", devices.RADARWARN, device_commands.ecm_msl_alert_axis_outer, 505, 0.0, 0.3, false, false, {-0.9,0.9} )
elements["PNT_502"] = multiposition_switch_limited("AN/APR-25 Function Selector Switch", devices.RADARWARN, device_commands.ecm_selector_knob, 502, 4, 0.33, false, 0.0, KNOBCLICK_MID_FWD, 5)

-- AIR CONDITIONING PANEL
elements["PNT_1251"] = default_2_position_tumb("Cabin Pressure Switch", devices.ELECTRIC_SYSTEM, device_commands.cabin_pressure , 224, TOGGLECLICK_LEFT_MID)
elements["PNT_225"] = default_3_position_tumb("Windshield Defrost Switch", devices.ELECTRIC_SYSTEM, device_commands.windshield_defrost , 225, nil, nil, TOGGLECLICK_MID_FWD)
elements["PNT_226"] = default_axis_limited("Cabin Temperature Knob", devices.ELECTRIC_SYSTEM, device_commands.cabin_temp , 226, 0.0, 0.3, false, false, {0,1} )

-- EJECTION SEAT
elements["PNT_128"] = default_2_position_tumb("Ejection Handle", devices.CANOPY, device_commands.jettison_canopy, 998)
elements["PNT_997"] = default_2_position_tumb("Ejection Handle", devices.BAILOUT ,device_commands.CPT_secondary_ejection_handle, 997)

-- Engine Start Sequence
elements["flip_case_start_enigne"] = default_2_position_tumb("Крышка кнопки запуска", devices.ENGINE, device_commands.StartCover, 2012)
elements["start_engine"] = default_button("Кнопка запуска двигателя", devices.ENGINE, device_commands.StartButton, 2013)
elements["start_pto"] = default_2_position_tumb("Запуск ПТО", devices.ENGINE, device_commands.StartPTO, 2014)
elements["PNT_989"] = default_3_position_tumb("Агрегат запуск: Прокрутка - ВЫКЛ - Запуск", devices.ENGINE, device_commands.StartMode, 989)
elements["PNT_THROTTLE_LOCK"] = default_button("Защелка РУД", devices.ENGINE, device_commands.ThrottleLock, 2015)
elements["PNT_THROTTLE_LOCK"].connector = "THROTTLE_POS"

elements["PNT_OXYGEN_VALVE"] = default_2_position_tumb("Кислородный кран (ОТКР/ЗАКР)", devices.AVIONICS, device_commands.OxygenToggle, 2018)
elements["PNT_OXYGEN_VALVE"].connector = "PNT_OXY_VALVE" 

elements["PNT_OXYGEN_PILOT_SWITCH"] = default_2_position_tumb("Кислород летчика (ВКЛ/ВЫКЛ)", devices.AVIONICS, device_commands.OxygenMode, 2019)
elements["PNT_OXYGEN_PILOT_SWITCH"].connector = "PNT_OXY_PILOT"

return elements
