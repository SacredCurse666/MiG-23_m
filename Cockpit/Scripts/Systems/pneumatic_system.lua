local dev = GetSelf()
local update_time = 0.05 
make_default_activity(update_time)

local sensor_data = get_base_data()

local main_press_param = get_param_handle("PNEUMO_MAIN_PRESS")
local emer_press_param = get_param_handle("PNEUMO_EMER_PRESS")

-- Константы
local MAX_PRESS = 210.0 
local CHARGE_RATE = 25.0 -- Увеличил скорость зарядки
local BRAKE_CONSUMPTION = 30.0 -- Немного уменьшил расход тормозов
local GEAR_CONSUMPTION = 20.0 -- УМЕНЬШИЛ расход шасси (теперь упадет примерно на 40-60 единиц)

-- Состояние
local main_pressure = 0.0
local emer_pressure = 180.0 

function post_initialize()
    local birth = LockOn_Options.init_conditions.birth_place
    if birth == "AIR_HOT" or birth == "GROUND_HOT" then
        main_pressure = 205.0
    end
end

function update()
    local dt = update_time
    
    -- Получаем RPM
    local rpm = 0
    pcall(function() rpm = sensor_data.getEngineLeftRPM() or 0 end)
    if rpm > 0 and rpm < 1.1 then rpm = rpm * 100 end

    -- 1. Зарядка
    if rpm > 35 then
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

    -- 3. Расход при работе шасси
    local gear_pos = get_aircraft_draw_argument_value(0)
    if gear_pos > 0.05 and gear_pos < 0.95 then
        if main_pressure > 0 then
            -- Теперь расход умеренный, стрелка упадет, но не до конца
            main_pressure = main_pressure - (GEAR_CONSUMPTION * dt)
        end
    end

    -- Ограничители
    if main_pressure > MAX_PRESS then main_pressure = MAX_PRESS end
    if main_pressure < 0 then main_pressure = 0 end

    -- Передача в кабину
    main_press_param:set(main_pressure)
    emer_press_param:set(emer_pressure)
end

function SetCommand(command,value)
end