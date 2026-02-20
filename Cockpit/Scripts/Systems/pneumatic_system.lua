-- MiG-23M Pneumatic System - Stable Version
local dev = GetSelf()
make_default_activity(0.02) -- 50 Hz

local sensor_data = get_base_data()

-- Use global handles to ensure they persist
local p_main_press = get_param_handle("PNEUMO_MAIN_PRESS")
local p_emer_press = get_param_handle("PNEUMO_EMER_PRESS")
local p_brake_l    = get_param_handle("PNEUMO_BRAKE_L")
local p_brake_r    = get_param_handle("PNEUMO_BRAKE_R")

-- State variables (persistent in this Lua state)
local main_val = 0
local emer_val = 240

function post_initialize()
    main_val = 0
    emer_val = 240
    p_main_press:set(main_val)
    p_emer_press:set(emer_val)
    print_message_to_user("PNEUMATIC SYSTEM: ONLINE")
end

function SetCommand(command, value)
    -- Handle brake commands if they come through
end

function update()
    -- 1. Get Engine RPM
    local rpm = 0
    if sensor_data.getEngineLeftRPM then
        rpm = sensor_data.getEngineLeftRPM()
        if rpm < 1.1 then rpm = rpm * 100 end
    end

    -- 2. Charging Logic
    if rpm > 40 then
        main_val = math.min(240, main_val + 0.1)
    end

    -- 3. Simple Brake Simulation (Direct Polling)
    local brake_l_input = 0
    local brake_r_input = 0
    
    if sensor_data.getLeftWheelBrake then
        brake_l_input = sensor_data.getLeftWheelBrake()
    end
    if sensor_data.getRightWheelBrake then
        brake_r_input = sensor_data.getRightWheelBrake()
    end

    -- Apply brake pressure based on main tank
    local target_l = math.min(10, main_val * brake_l_input)
    local target_r = math.min(10, main_val * brake_r_input)

    -- Smooth needles
    local cur_l = p_brake_l:get() or 0
    local cur_r = p_brake_r:get() or 0
    p_brake_l:set(cur_l + (target_l - cur_l) * 0.2)
    p_brake_r:set(cur_r + (target_r - cur_r) * 0.2)

    -- 4. Consumption and Leaks
    local main_cons = get_param_handle("PNEUMO_MAIN_CONSUMPTION"):get() or 0
    local emer_cons = get_param_handle("PNEUMO_EMER_CONSUMPTION"):get() or 0
    
    -- Subtract consumption and reset handles
    main_val = math.max(0, main_val - main_cons - 0.001) 
    emer_val = math.max(0, emer_val - emer_cons - 0.0005)
    
    get_param_handle("PNEUMO_MAIN_CONSUMPTION"):set(0)
    get_param_handle("PNEUMO_EMER_CONSUMPTION"):set(0)

    -- 5. Update Gauges
    p_main_press:set(main_val)
    p_emer_press:set(emer_val)
end

need_to_be_closed = false
