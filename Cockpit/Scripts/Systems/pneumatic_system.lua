-- MiG-23M Pneumatic System
local dev = GetSelf()
local update_step = 0.02
make_default_activity(update_step)

dofile(LockOn_Options.script_path.."command_defs.lua")

local sensor_data = get_base_data()

-- Commands
dev:listen_command(Keys.BrakesOn)
dev:listen_command(Keys.BrakesOff)
dev:listen_command(device_commands.pneumo_brake_lever)

-- Internal state variables (kg/cm2)
local main_tank_val = 0 
local emer_tank_val = 0
local line_main_press_val = 0
local line_emer_press_val = 0
local brake_l_press_val = 0
local brake_r_press_val = 0

-- Input Tracking
local brake_mouse_state = 0
local brake_key_state = 0

-- Handles for mainpanel_init.lua
local h_PNEUMO_MAIN_PRESS = get_param_handle("PNEUMO_MAIN_PRESS")
local h_PNEUMO_EMER_PRESS = get_param_handle("PNEUMO_EMER_PRESS")
local h_PNEUMO_LINE_MAIN = get_param_handle("PNEUMO_LINE_MAIN")
local h_PNEUMO_LINE_EMER = get_param_handle("PNEUMO_LINE_EMER")
local h_PNEUMO_BRAKE_L = get_param_handle("PNEUMO_BRAKE_L")
local h_PNEUMO_BRAKE_R = get_param_handle("PNEUMO_BRAKE_R")

-- Common parameter for brakes
local h_WHEEL_BRAKE_ACTIVE = get_param_handle("WHEEL_BRAKE_ACTIVE")
local h_BRAKE_LEVER_ANIM = get_param_handle("BRAKE_LEVER_ANIM")

-- Consumption handles for API
local h_PNEUMO_MAIN_CONSUMPTION = get_param_handle("PNEUMO_MAIN_CONSUMPTION")
local h_PNEUMO_EMER_CONSUMPTION = get_param_handle("PNEUMO_EMER_CONSUMPTION")

function post_initialize()
    -- Absolute Zero for Cold Start
    local birth = LockOn_Options.init_conditions.birth_place
    if birth == "GROUND_COLD" then
        main_tank_val = 0  
        emer_tank_val = 0
    else
        main_tank_val = 200 
        emer_tank_val = 220
    end

    h_PNEUMO_MAIN_PRESS:set(main_tank_val)
    h_PNEUMO_EMER_PRESS:set(emer_tank_val)
    
    line_main_press_val = math.min(13.5, main_tank_val)
    line_emer_press_val = math.min(14.0, emer_tank_val)
    
    h_PNEUMO_LINE_MAIN:set(line_main_press_val)
    h_PNEUMO_LINE_EMER:set(line_emer_press_val)
    
    h_PNEUMO_BRAKE_L:set(0)
    h_PNEUMO_BRAKE_R:set(0)
    
    h_WHEEL_BRAKE_ACTIVE:set(0)
    h_BRAKE_LEVER_ANIM:set(0)
end

function SetCommand(command, value)
    if command == Keys.BrakesOn then
        brake_key_state = 1
        dispatch_action(nil, 74, 1) -- Физика ВКЛ
    elseif command == Keys.BrakesOff then
        brake_key_state = 0
        dispatch_action(nil, 75, 1) -- Физика ВЫКЛ
    elseif command == device_commands.pneumo_brake_lever then
        brake_mouse_state = value
        if value > 0 then
            dispatch_action(nil, 74, 1)
        else
            dispatch_action(nil, 75, 1)
        end
    end
end

function update()
    -- 1. Get Inputs
    local rpm = 0
    if sensor_data.getEngineLeftRPM then 
        rpm = sensor_data.getEngineLeftRPM() or 0 
    end
    if rpm > 0 and rpm <= 1.1 then rpm = rpm * 100 end
    
    -- Combine keyboard, mouse and sensor (axis)
    local sensor_brake = 0
    if sensor_data.getLeftWheelBrake then
        sensor_brake = sensor_data.getLeftWheelBrake() or 0
        if sensor_brake > 1.1 then sensor_brake = sensor_brake / 100 end
    end
    
    local brake_lever = math.max(brake_key_state, brake_mouse_state, sensor_brake)
    brake_lever = math.max(0, math.min(1.0, brake_lever))
    
    h_WHEEL_BRAKE_ACTIVE:set(brake_lever > 0.05 and 1 or 0)
    
    local rudder = 0
    if sensor_data.getRudderPosition then
        rudder = sensor_data.getRudderPosition() or 0
    end
    if math.abs(rudder) > 1.1 then rudder = rudder / 100 end
    rudder = math.max(-1.0, math.min(1.0, rudder))
    
    -- 2. Air Consumption & Charging
    local consumption_main = (h_PNEUMO_MAIN_CONSUMPTION:get() or 0)
    
    -- Charging
    if rpm > 40 then 
        local charge = 0.25 * (rpm / 100)
        main_tank_val = math.min(240, main_tank_val + charge)
        emer_tank_val = math.min(240, emer_tank_val + charge * 0.5)
    end
    
    -- Consumption
    if brake_lever > 0.05 then
        consumption_main = consumption_main + 0.04 * brake_lever
    end
    
    main_tank_val = math.max(0, main_tank_val - consumption_main)
    h_PNEUMO_MAIN_CONSUMPTION:set(0)
    
    -- 3. Regulated Manifold Pressure (0-16 gauge)
    local target_line_main = math.min(13.5, main_tank_val)
    local target_line_emer = math.min(14.0, emer_tank_val)
    
    -- 4. Brake Implementation (0-12 gauge)
    local factor_l = math.max(0, math.min(1.0, 1.0 - rudder))
    local factor_r = math.max(0, math.min(1.0, 1.0 + rudder))
    
    local target_brake_l = target_line_main * 0.83 * brake_lever * factor_l
    local target_brake_r = target_line_main * 0.83 * brake_lever * factor_r
    
    -- 5. Smoothing
    local f = 0.2
    line_main_press_val = line_main_press_val + (target_line_main - line_main_press_val) * f
    line_emer_press_val = line_emer_press_val + (target_line_emer - line_emer_press_val) * f
    brake_l_press_val = brake_l_press_val + (target_brake_l - brake_l_press_val) * f
    brake_r_press_val = brake_r_press_val + (target_brake_r - brake_r_press_val) * f
    
    -- 6. Final Outputs
    h_PNEUMO_MAIN_PRESS:set(main_tank_val)
    h_PNEUMO_EMER_PRESS:set(emer_tank_val)
    h_PNEUMO_LINE_MAIN:set(line_main_press_val)
    h_PNEUMO_LINE_EMER:set(line_emer_press_val)
    h_PNEUMO_BRAKE_L:set(brake_l_press_val)
    h_PNEUMO_BRAKE_R:set(brake_r_press_val)

    -- Sync Brake Lever Animation (2004) - Now stable!
    h_BRAKE_LEVER_ANIM:set(brake_lever)
end
