dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."utils.lua")

local dev = GetSelf()
local update_time_step = 0.05
make_default_activity(update_time_step)

local sensor_data = get_base_data()

local hydraulic_pressure = get_param_handle("BUSTER_HYDRO_PRESS")
-- WMA filter: factor 0.02 (slower, smoother), initial value 0
local pressure_filter = WMA(0.02, 0)

function update()
    local rpm = sensor_data.getEngineLeftRPM() -- Returns RPM in percentage (0-100+)
    local target_pressure = 0

    -- Logic: Pressure builds up as RPM increases
    if rpm > 40 then
        -- Normal operating pressure ~210 kgf/cm^2
        -- Add slight variation based on RPM
        target_pressure = 210 + (rpm - 40) * 0.1 
        
        -- Cap max pressure
        if target_pressure > 230 then target_pressure = 230 end
    elseif rpm > 5 then
        -- Ramp up from 5% to 40% RPM
        target_pressure = (rpm - 5) / 35 * 210
    else
        target_pressure = 0
    end

    -- Add slight random fluctuation if pressurized
    if target_pressure > 50 then
       target_pressure = target_pressure + (math.random() - 0.5) * 1.5
    end
    
    -- Simulate pressure drop when Gear is moving (arg 0 is between 0 and 1)
    local gear_pos = get_aircraft_draw_argument_value(0)
    if gear_pos > 0.01 and gear_pos < 0.99 then
         -- Drop pressure by ~50 kgf/cm^2 under load
         -- Add more vibration/noise when under load
         target_pressure = target_pressure - 50 + (math.random() - 0.5) * 5.0
    end

    hydraulic_pressure:set(pressure_filter:get_WMA(target_pressure))
end

function post_initialize()
    hydraulic_pressure:set(0)
end

need_to_be_closed = false
