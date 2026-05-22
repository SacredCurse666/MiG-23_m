-- MiG-23M Oxygen System Logic
local dev = GetSelf()
local update_step = 0.05 -- 20 Hz
make_default_activity(update_step)

dofile(LockOn_Options.script_path.."command_defs.lua")
local sensor_data = get_base_data()

-- Internal state
local oxygen_valve_pos = 0 -- 0: Closed, 1: Open
local oxygen_mode_pos = 0  -- 0: Normal, 1: 100%
local oxygen_pressure = 0
local hypoxia_timer = 0
local breathing_phase = 0

-- Parameter handles for gauges and external access
local h_OXY_OVER_PRESS = get_param_handle("OXY_OVER_PRESS") -- Gauge 2017
local h_OXY_VALVE_POS = get_param_handle("OXY_VALVE_POS")   -- Switch 2018
local h_OXY_MODE_POS = get_param_handle("OXY_MODE_POS")     -- Switch 2019

function post_initialize()
    local birth = LockOn_Options.init_conditions.birth_place
    if birth == "GROUND_HOT" or birth == "AIR_HOT" then
        oxygen_valve_pos = 1
        oxygen_mode_pos = 0
    else
        oxygen_valve_pos = 0
        oxygen_mode_pos = 0
    end
end

function SetCommand(command, value)
    print_message_to_user("OXY DEBUG: Command " .. tostring(command))
    if command == device_commands.OxygenToggle then
        oxygen_valve_pos = 1 - oxygen_valve_pos
        print_message_to_user("OXY: Valve " .. tostring(oxygen_valve_pos))
    elseif command == device_commands.OxygenMode then
        oxygen_mode_pos = 1 - oxygen_mode_pos
        print_message_to_user("OXY: Mode " .. tostring(oxygen_mode_pos))
    end
end

function update()
    local alt = sensor_data.getBarometricAltitude() -- in meters
    
    -- 1. Base Pressure Calculation
    local target_pressure = 0
    if oxygen_valve_pos > 0.5 then
        target_pressure = 0.2 -- Base pressure when system is ON
        
        -- Increase pressure above 8000m
        if alt > 8000 then
            local extra = (alt - 8000) / 12000 -- Max at ~20,000m
            target_pressure = target_pressure + math.min(0.8, extra)
        end
    end
    
    -- 2. Breathing Pulse (Sine wave)
    breathing_phase = breathing_phase + (update_step * 2) -- Period approx 3.14 seconds
    local pulse = math.sin(breathing_phase) * 0.015 -- 1.5% fluctuation
    
    if target_pressure > 0 then
        oxygen_pressure = target_pressure + pulse
    else
        oxygen_pressure = 0
    end
    
    -- Smooth transition for the gauge
    local current_display = h_OXY_OVER_PRESS:get() or 0
    h_OXY_OVER_PRESS:set(current_display + (oxygen_pressure - current_display) * 0.1)
    
    -- 3. Hypoxia Simulation
    if alt > 10000 and oxygen_valve_pos < 0.5 then
        hypoxia_timer = hypoxia_timer + update_step
        if hypoxia_timer > 30 then
            -- Trigger Blackout effect (using DCS internal parameter if supported or common mod method)
            local blackout = math.min(1.0, (hypoxia_timer - 30) / 30)
            set_p(700, blackout) -- 700 is often used for blackout in some templates, but we use a param
            get_param_handle("HYPOXIA_BLACKOUT"):set(blackout)
        end
    else
        hypoxia_timer = math.max(0, hypoxia_timer - update_step * 2)
        get_param_handle("HYPOXIA_BLACKOUT"):set(0)
    end
end
