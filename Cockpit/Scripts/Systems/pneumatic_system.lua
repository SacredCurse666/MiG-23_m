local dev = GetSelf()
local update_time = 0.05 
make_default_activity(update_time)

local sensor_data = get_base_data()

local main_press_param = get_param_handle("PNEUMO_MAIN_PRESS")
local emer_press_param = get_param_handle("PNEUMO_EMER_PRESS")

-- Константы
local MAX_PRESS = 210.0 
local CHARGE_RATE = 25.0 -- Увеличил скорость зарядки
local BRAKE_CONSUMPTION = 30.0 -- Расход тормозов (остается по времени)

local GEAR_TOTAL_LOSS = 14.7 -- 7% от 210
local CANOPY_TOTAL_LOSS = 14.7 -- 7% от 210

-- Состояние
local main_pressure = 0.0
local emer_pressure = 180.0 

local prev_gear_pos = 0
local prev_canopy_pos = 0

function post_initialize()
    local birth = LockOn_Options.init_conditions.birth_place
    if birth == "AIR_HOT" or birth == "GROUND_HOT" then
        main_pressure = 205.0
        prev_gear_pos = get_aircraft_draw_argument_value(0)
        prev_canopy_pos = get_aircraft_draw_argument_value(38)
    elseif birth == "GROUND_COLD" then
        prev_gear_pos = 1.0 -- Шасси выпущены
        prev_canopy_pos = 0.9 -- Фонарь открыт
    end
end

function update()
    local dt = update_time
    
    -- Получаем RPM
    local rpm = 0
    pcall(function() rpm = sensor_data.getEngineLeftRPM() or 0 end)
    if rpm > 0 and rpm < 1.1 then rpm = rpm * 100 end

    -- 1. Зарядка (только на земле)
    local on_ground = (sensor_data.getWOW_LeftMainLandingGear() > 0) or (sensor_data.getWOW_RightMainLandingGear() > 0)
    if rpm > 35 and on_ground then
        local charge_coeff = (rpm - 35) / 65
        if main_pressure < MAX_PRESS then
            main_pressure = main_pressure + (CHARGE_RATE * charge_coeff * dt)
        end
    end

    -- 2. Расход тормозов
    local brake_val = 0
    pcall(function() 
        brake_val = math.max(sensor_data.getLeftMainLandingGearBrake() or 0, 
                             sensor_data.getRightMainLandingGearBrake() or 0)
    end)
    
    if brake_val > 0.1 and main_pressure > 0 then
        main_pressure = main_pressure - (BRAKE_CONSUMPTION * brake_val * dt)
    end

    -- 3. Расход при работе шасси (по дельте анимации)
    local gear_pos = get_aircraft_draw_argument_value(0)
    local gear_delta = math.abs(gear_pos - prev_gear_pos)
    if gear_delta > 0 and main_pressure > 0 then
        -- 1.0 изменения аргумента = GEAR_TOTAL_LOSS (14.7 единиц)
        main_pressure = main_pressure - (gear_delta * GEAR_TOTAL_LOSS)
    end
    prev_gear_pos = gear_pos

    -- 4. Расход при движении фонаря (по дельте анимации)
    local canopy_pos = get_aircraft_draw_argument_value(38)
    local canopy_delta = math.abs(canopy_pos - prev_canopy_pos)
    if canopy_delta > 0 and main_pressure > 0 then
        -- 0.9 изменения аргумента = CANOPY_TOTAL_LOSS (14.7 единиц)
        -- Следовательно, множитель = 14.7 / 0.9 = 16.333
        main_pressure = main_pressure - (canopy_delta * (CANOPY_TOTAL_LOSS / 0.9))
    end
    prev_canopy_pos = canopy_pos

    -- Ограничители
    if main_pressure > MAX_PRESS then main_pressure = MAX_PRESS end
    if main_pressure < 0 then main_pressure = 0 end

    -- Передача в кабину
    main_press_param:set(main_pressure)
    emer_press_param:set(emer_pressure)
end

function SetCommand(command,value)
end