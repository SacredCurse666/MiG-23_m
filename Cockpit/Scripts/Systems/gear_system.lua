local dev = GetSelf()
print_message_to_user("gear_system load")

dofile(LockOn_Options.common_script_path.."devices_defs.lua")
dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."utils.lua")

if device_commands and device_commands.emer_gear_release then
    print_message_to_user("GearSystem: emer_gear_release ID = " .. tostring(device_commands.emer_gear_release))
else
    print_message_to_user("GearSystem: WARNING - emer_gear_release command NOT FOUND")
end

local update_time_step = 0.01 
make_default_activity(update_time_step)

local sensor_data = get_base_data()

local wing_warning = get_param_handle("WING_WARNING")
wing_warning:set(0)
local des_wing_angle = get_param_handle("DES_WING_ANGLE")

local gear_nose_released = get_param_handle("GEAR_NOSE_RELEASED")
gear_nose_released:set(0)
local gear_nose_retracted = get_param_handle("GEAR_NOSE_RETRACTED")
gear_nose_retracted:set(0)
local gear_right_released = get_param_handle("GEAR_RIGHT_RELEASED")
gear_right_released:set(0)
local gear_right_retracted = get_param_handle("GEAR_RIGHT_RETRACTED")
gear_right_retracted:set(0)
local gear_left_released = get_param_handle("GEAR_LEFT_RELEASED")
gear_left_released:set(0)
local gear_left_retracted = get_param_handle("GEAR_LEFT_RETRACTED")
gear_left_retracted:set(0)
local release_gear = get_param_handle("RELEASE_GEAR")
local release_flaps = get_param_handle("RELEASE_FLAPS")
local gear_flaps_closed = get_param_handle("GEAR_FLAPS_CLOSED")
gear_flaps_closed:set(0)
local timer = 1000

local gear_state_counter
local main_press_param = get_param_handle("PNEUMO_MAIN_PRESS")
local emer_press_param = get_param_handle("PNEUMO_EMER_PRESS")
local gear_emer_active_param = get_param_handle("GEAR_EMER_ACTIVE")
local is_emergency_extension = false

function post_initialize()
local birth = LockOn_Options.init_conditions.birth_place
	if birth == "GROUND_HOT" or birth == "GROUND_COLD" then --проверка состояние самолёта в воздухе или на земле
		print_message_to_user("GROUND")	-- дебаг сообщение
		LANDING_GEAR_STATE = 1			-- Состояние шасси: 0 = скрытие, 1 = выпуск
		LANDING_GEAR_TARGET = 1
		gear_state_counter = 1000
		
		elseif birth=="AIR_HOT" then
			print_message_to_user("AIR")
			LANDING_GEAR_STATE = 0
			LANDING_GEAR_TARGET = 0	
			gear_state_counter = 0
			
	end
	--print_message_to_user("LANDING_GEAR_TARGET = ".. LANDING_GEAR_TARGET .. " LANDING_GEAR_STATE = " .. LANDING_GEAR_STATE .. " " .. gear_state_counter)
end	

local BayDoorOpenCloseTimeSec = 3
local BayDoorOpenCloseIncrement = update_time_step / BayDoorOpenCloseTimeSec

local LANDING_GEAR_UP = 0
local LANDING_GEAR_DOWN = 1

local GearOpenTimeSec = 6	--скорость выпуска шасси													
local GearOpenIncrement = 2 --update_time_step / GearOpenTimeSec --0,01/8
local GearCloseTimeSec = 10 --скорость убирание шасси
local GearCloseIncrement = 5 --update_time_step / GearCloseTimeSec

dev:listen_command(Keys.PlaneGear)
dev:listen_command(Keys.PlaneGearUp)
dev:listen_command(Keys.PlaneGearDown)
dev:listen_command(device_commands.emer_gear_release)

local function rounded(rounded,value)
	if (rounded <(value+0.02) and rounded >(value-0.02))then
		rounded = value
		elseif (rounded >(value-0.02) and rounded <(value+0.02)) then
			rounded = value
	end
	return rounded
end

function SetCommand(command, value)
    if command == Keys.PlaneGear then
        LANDING_GEAR_TARGET = 1 - LANDING_GEAR_TARGET
    elseif command == Keys.PlaneGearUp then 
		LANDING_GEAR_TARGET = 0	
		gear_state_counter = 0
	elseif command == Keys.PlaneGearDown then
		LANDING_GEAR_TARGET = 1
		gear_state_counter = 1000
    elseif command == device_commands.emer_gear_release then
        if value ~= 0 then
            print_message_to_user("EMERGENCY GEAR RELEASE ACTIVE")
            is_emergency_extension = true
            LANDING_GEAR_TARGET = 1
        else
            is_emergency_extension = false
        end
    end
end
-- function f_gear_nose_retracted(value)
-- 		gear_nose_retracted:set(value)
-- end
-- function f_gear_right_retracted(value)
-- 		gear_right_retracted:set(value)
-- end
-- function f_gear_left_retracted(value)
-- 		gear_left_retracted:set(value)
-- end
function update()

	local current_pressure = main_press_param:get()
    local emer_pressure = emer_press_param:get()
	local can_move_gear = current_pressure > 20

    if is_emergency_extension then
        LANDING_GEAR_TARGET = 1
        if emer_pressure > 20 then
            can_move_gear = true
        end
    end
    
    gear_emer_active_param:set(is_emergency_extension and 1 or 0)

	--print_message_to_user("LANDING_GEAR_TARGET = ".. LANDING_GEAR_TARGET .. " LANDING_GEAR_STATE = " .. LANDING_GEAR_STATE)
	if (LANDING_GEAR_STATE == 0) then
		gear_nose_retracted:set(1)
		gear_right_retracted:set(1)
		gear_left_retracted:set(1)
		else
			gear_nose_retracted:set(0)
			gear_right_retracted:set(0)
			gear_left_retracted:set(0)
	end	

	if LANDING_GEAR_STATE > LANDING_GEAR_TARGET and can_move_gear then
		LANDING_GEAR_STATE = LANDING_GEAR_STATE - GearCloseIncrement/1000
		LANDING_GEAR_STATE = rounded(LANDING_GEAR_STATE,LANDING_GEAR_TARGET)
		--print_message_to_user( " > LANDING_GEAR_STATE = " .. LANDING_GEAR_STATE)
	end

	if LANDING_GEAR_STATE < LANDING_GEAR_TARGET and can_move_gear then
		LANDING_GEAR_STATE = LANDING_GEAR_STATE + GearOpenIncrement/1000
		LANDING_GEAR_STATE = rounded(LANDING_GEAR_STATE,LANDING_GEAR_TARGET)
		--print_message_to_user( " < LANDING_GEAR_STATE = " .. LANDING_GEAR_STATE)

	end
	
	set_aircraft_draw_argument_value(0, LANDING_GEAR_STATE)
	set_aircraft_draw_argument_value(3, LANDING_GEAR_STATE)
	set_aircraft_draw_argument_value(5, LANDING_GEAR_STATE)

	-------------------------------------------------------
		
	if (LANDING_GEAR_STATE == 1 and LANDING_GEAR_TARGET == 1 ) then
		gear_nose_released:set(1)
		gear_right_released:set(1)
		gear_left_released:set(1)
		else
		gear_nose_released:set(0)
		gear_right_released:set(0)
		gear_left_released:set(0)
	end 

	local engine_power = sensor_data.getEngineLeftRPM()
	local altitude_meters = sensor_data.getRadarAltitude()

	local  flap_position = get_aircraft_draw_argument_value(9)
	--print_message_to_user("gear_position = ".. gear_position .. " engine_power = ".. engine_power .. " altitude_meters = ".. altitude_meters)

if LANDING_GEAR_STATE ~= 0 and flap_position <0.5 then
	release_flaps:set(1)
else
	release_flaps:set(0)
end

	if  LANDING_GEAR_STATE ~= 1 and altitude_meters<350 and engine_power < 60 then
		release_gear:set(1)
	elseif LANDING_GEAR_STATE ~= 1 and flap_position ~=1 and altitude_meters<250 and engine_power < 90 then
		release_gear:set(1)
	else
		release_gear:set(0)
	end

	if LANDING_GEAR_STATE == 0 and LANDING_GEAR_TARGET == 0 then
		gear_flaps_closed:set(1)
	else
		gear_flaps_closed:set(0)
	end	

	if (LANDING_GEAR_STATE == 1 and des_wing_angle:get() ~=0) then
		wing_warning:set(1)
		else
			wing_warning:set(0)
	end

end

need_to_be_closed = false


-- local zakr
-- get_aircraft_draw_argument_value(9, zakr)