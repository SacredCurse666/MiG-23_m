dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/hydraulic_system_api.lua")
dofile(LockOn_Options.script_path.."utils.lua")

local dev = GetSelf()
local update_time_step = 0.02 
make_default_activity(update_time_step)

local sensor_data = get_base_data()

-- Состояние систем
local pressure1 = 0 -- ГС1 (Основная)
local pressure2 = 0 -- ГС2 (Бустерная)

local last_p1_output = 0
local last_p2_output = 0

-- Константы
local NOMINAL_PRESSURE = 210
local MAX_PRESSURE     = 235
local PUMP_POWER       = 1.5   
local LEAK_RATE        = 0.005 -- Значительно уменьшено для реализма
local HYD_OK_PRESSURE  = 100

-- Предыдущие состояния
local last_gear_pos = 0
local last_flap_pos = 0
local last_wing_pos = 0
local last_speedbrake_pos = 0
local last_pitch  = 0
local last_roll   = 0
local last_rudder = 0

-- Параметры
local gear_param = get_param_handle("GEAR_POS")
local flap_param = get_param_handle("FLAP_IND")
local wing_param = get_param_handle("WING_ANGLE_INDICATOR")
local speedbrake_param = get_param_handle("SPEEDBRAKE_POS")
local gear_emer_active_param = get_param_handle("GEAR_EMER_ACTIVE")

function update()
    local rpm = sensor_data.getEngineLeftRPM()
    if rpm < 1.1 then rpm = rpm * 100 end 
    
    local pump_eff = 0
    if rpm > 25 then 
        pump_eff = math.min(1.0, (rpm - 25) / 30)
    end
    
    local pump_gain = pump_eff * PUMP_POWER

    -------------------------------------------------------
    -- ГС1: ОСНОВНАЯ СИСТЕМА
    -------------------------------------------------------
    local gear_pos = gear_param:get() or 0
    local flap_pos = flap_param:get() or 0
    local wing_pos = wing_param:get() or 0
    local sb_pos   = speedbrake_param:get() or 0
    local gear_emer_active = gear_emer_active_param:get() > 0.5
    
    -- Расчет расхода ГС1
    local gear_consumption = 0
    if not gear_emer_active then
        -- Гидравлика тратится только если НЕ включен аварийный (пневмо) выпуск
        gear_consumption = math.abs(gear_pos - last_gear_pos) * 45.0
    end

    local consumption1 = gear_consumption +
                         (math.abs(flap_pos - last_flap_pos) * 25.0) +
                         (math.abs(wing_pos - last_wing_pos) * 35.0) +
                         (math.abs(sb_pos - last_speedbrake_pos) * 20.0)
    
    consumption1 = math.min(consumption1, 10.0)
                         
    last_gear_pos = gear_pos
    last_flap_pos = flap_pos
    last_wing_pos = wing_pos
    last_speedbrake_pos = sb_pos
    
    local p1_gain = (pressure1 < NOMINAL_PRESSURE) and pump_gain or 0
    pressure1 = math.max(0, math.min(MAX_PRESSURE, pressure1 + p1_gain - consumption1 - LEAK_RATE))

    -------------------------------------------------------
    -- ГС2: БУСТЕРНАЯ СИСТЕМА
    -------------------------------------------------------
    local cur_pitch  = sensor_data.getStickPitchPosition() / 100
    local cur_roll   = sensor_data.getStickRollPosition() / 100
    local cur_rudder = sensor_data.getRudderPosition() / 100
    
    local movement = math.abs(cur_pitch - last_pitch) + 
                     math.abs(cur_roll - last_roll) + 
                     math.abs(cur_rudder - last_rudder)
    
    local consumption2 = movement * 10.0
    
    last_pitch  = cur_pitch
    last_roll   = cur_roll
    last_rudder = cur_rudder
    
    local p2_gain = (pressure2 < NOMINAL_PRESSURE) and pump_gain or 0
    
    local velocity = sensor_data.getIndicatedAirSpeed() * 3.6
    local in_air = sensor_data.getRadarAltitude() > 5
    
    if in_air and velocity > 350 and rpm < 25 then
        if pressure2 < 150 then
            p2_gain = math.max(p2_gain, 0.5) 
        end
    end
    
    pressure2 = math.max(0, math.min(MAX_PRESSURE, pressure2 + p2_gain - consumption2 - LEAK_RATE))

    -------------------------------------------------------
    -- ВЫВОД
    -------------------------------------------------------
    last_p1_output = last_p1_output + (pressure1 - last_p1_output) * 0.1
    last_p2_output = last_p2_output + (pressure2 - last_p2_output) * 0.1
    
    hyd1_pressure:set(last_p1_output)
    hyd2_pressure:set(last_p2_output)
    
    hyd_utility_ok:set(pressure1 >= HYD_OK_PRESSURE and 1 or 0)
    hyd_flight_control_ok:set(pressure2 >= HYD_OK_PRESSURE and 1 or 0)
end

function post_initialize()
    local rpm = sensor_data.getEngineLeftRPM()
    if rpm < 1.1 then rpm = rpm * 100 end
    
    if rpm > 40 then
        pressure1 = NOMINAL_PRESSURE
        pressure2 = NOMINAL_PRESSURE
    else
        pressure1 = 0
        pressure2 = 0
    end
    last_p1_output = pressure1
    last_p2_output = pressure2
end

need_to_be_closed = false
