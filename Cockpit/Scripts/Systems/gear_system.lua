local dev = GetSelf()

dofile(LockOn_Options.common_script_path.."devices_defs.lua")
dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/hydraulic_system_api.lua")
dofile(LockOn_Options.script_path.."utils.lua")

local update_time_step = 0.01 
make_default_activity(update_time_step)

local sensor_data = get_base_data()

local wing_warning = get_param_handle("WING_WARNING")
local des_wing_angle = get_param_handle("DES_WING_ANGLE")

local gear_nose_released = get_param_handle("GEAR_NOSE_RELEASED")
local gear_nose_retracted = get_param_handle("GEAR_NOSE_RETRACTED")
local gear_right_released = get_param_handle("GEAR_RIGHT_RELEASED")
local gear_right_retracted = get_param_handle("GEAR_RIGHT_RETRACTED")
local gear_left_released = get_param_handle("GEAR_LEFT_RELEASED")
local gear_left_retracted = get_param_handle("GEAR_LEFT_RETRACTED")
local release_gear = get_param_handle("RELEASE_GEAR")
local release_flaps = get_param_handle("RELEASE_FLAPS")
local gear_flaps_closed = get_param_handle("GEAR_FLAPS_CLOSED")

local gear_emer_active_param = get_param_handle("GEAR_EMER_ACTIVE")
local gear_pos_param = get_param_handle("GEAR_POS")
local is_emergency_extension = false

-- State Variables
local LANDING_GEAR_STATE = 0
local LANDING_GEAR_TARGET = 0

function post_initialize()
    local birth = LockOn_Options.init_conditions.birth_place
    if birth == "GROUND_HOT" or birth == "GROUND_COLD" then
        LANDING_GEAR_STATE = 1
        LANDING_GEAR_TARGET = 1
    else
        LANDING_GEAR_STATE = 0
        LANDING_GEAR_TARGET = 0	
    end
end	

dofile(LockOn_Options.script_path.."Systems/pneumatic_system_api.lua")

local GearOpenBaseIncrement = 2 / 1000
local GearCloseBaseIncrement = 5 / 1000

local GEAR_EMER_CONSUMPTION = 20.0 -- Large amount of air for a one-time push

dev:listen_command(Keys.PlaneGear)
dev:listen_command(Keys.PlaneGearUp)
dev:listen_command(Keys.PlaneGearDown)
dev:listen_command(device_commands.emer_gear_release)

local function rounded(val, target)
    if math.abs(val - target) < 0.01 then
        return target
    end
    return val
end

function SetCommand(command, value)
    if command == Keys.PlaneGear then
        LANDING_GEAR_TARGET = 1 - LANDING_GEAR_TARGET
    elseif command == Keys.PlaneGearUp then 
        LANDING_GEAR_TARGET = 0	
    elseif command == Keys.PlaneGearDown then
        LANDING_GEAR_TARGET = 1
    elseif command == device_commands.emer_gear_release then
        if value ~= 0 and not is_emergency_extension then
            if is_pneumo_emer_ok() then
                is_emergency_extension = true
                LANDING_GEAR_TARGET = 1
                consume_emer_air(GEAR_EMER_CONSUMPTION)
            end
        elseif value == 0 then
            is_emergency_extension = false
        end
    end
end

function update()
    local pressure = get_hyd1_pressure()
    local can_move_gear = get_hyd_utility_ok()
    
    -- Множитель скорости от давления (от 50 до 200 кг/см2)
    local speed_mult = math.max(0, math.min(1.0, (pressure - 50) / 150))

    if is_emergency_extension then
        LANDING_GEAR_TARGET = 1
        can_move_gear = true
        speed_mult = 1.0 -- Аварийный выпуск (пневматика) всегда на полной скорости
    end
    
    gear_emer_active_param:set(is_emergency_extension and 1 or 0)

    -- Движение
    if can_move_gear or is_emergency_extension then
        if LANDING_GEAR_STATE > LANDING_GEAR_TARGET then
            LANDING_GEAR_STATE = rounded(LANDING_GEAR_STATE - GearCloseBaseIncrement * speed_mult, LANDING_GEAR_TARGET)
        elseif LANDING_GEAR_STATE < LANDING_GEAR_TARGET then
            LANDING_GEAR_STATE = rounded(LANDING_GEAR_STATE + GearOpenBaseIncrement * speed_mult, LANDING_GEAR_TARGET)
        end
    end
    
    -- Visual Args
    set_aircraft_draw_argument_value(0, LANDING_GEAR_STATE)
    set_aircraft_draw_argument_value(3, LANDING_GEAR_STATE)
    set_aircraft_draw_argument_value(5, LANDING_GEAR_STATE)
    
    gear_pos_param:set(LANDING_GEAR_STATE)

    -- Indicators
    local is_down = (LANDING_GEAR_STATE == 1)
    local is_up = (LANDING_GEAR_STATE == 0)
    gear_nose_released:set(is_down and 1 or 0)
    gear_right_released:set(is_down and 1 or 0)
    gear_left_released:set(is_down and 1 or 0)
    gear_nose_retracted:set(is_up and 1 or 0)
    gear_right_retracted:set(is_up and 1 or 0)
    gear_left_retracted:set(is_up and 1 or 0)

    -- Warning
    local engine_power = sensor_data.getEngineLeftRPM()
    local altitude_meters = sensor_data.getRadarAltitude()
    local flap_position = get_aircraft_draw_argument_value(9)

    if LANDING_GEAR_STATE ~= 0 and flap_position < 0.5 then
        release_flaps:set(1)
    else
        release_flaps:set(0)
    end

    if LANDING_GEAR_STATE ~= 1 and ((altitude_meters < 350 and engine_power < 60) or 
       (flap_position ~= 1 and altitude_meters < 250 and engine_power < 90)) then
        release_gear:set(1)
    else
        release_gear:set(0)
    end

    gear_flaps_closed:set((is_up and LANDING_GEAR_TARGET == 0) and 1 or 0)

    if LANDING_GEAR_STATE == 1 and des_wing_angle:get() ~= 0 then
        wing_warning:set(1)
    else
        wing_warning:set(0)
    end
end

need_to_be_closed = false
