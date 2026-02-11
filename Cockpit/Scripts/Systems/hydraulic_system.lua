dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."utils.lua")

local dev = GetSelf()
local update_time_step = 0.02 -- Высокая частота для плавной симуляции
make_default_activity(update_time_step)

local sensor_data = get_base_data()

-- Ссылка на параметр для кабины
local booster_press_param = get_param_handle("BOOSTER_HYDRO_PRESS")

-- Состояние системы
local pressure = 0 -- Текущее давление в кг/см2
local last_pressure_output = 0

-- Константы системы МиГ-23
local NOMINAL_PRESSURE = 210   -- Рабочее давление ГС
local MAX_PRESSURE     = 235   -- Предел (сброс клапана)
local PUMP_POWER       = 12.0  -- Скорость нагнетания давления насосом
local LEAK_RATE        = 0.02  -- Постепенное падение давления (утечки)

-- Предыдущие положения для расчета расхода
local last_pitch  = 0
local last_roll   = 0
local last_rudder = 0

function update()
    local rpm = sensor_data.getEngineLeftRPM() -- Обороты (0-100)
    
    -- 1. РАБОТА НАСОСА
    -- Насос начинает давать давление примерно с 10% оборотов и выходит на макс к 45%
    local pump_eff = 0
    if rpm > 10 then
        pump_eff = (rpm - 10) / 35
        if pump_eff > 1 then pump_eff = 1 end
    end
    
    -- Насос работает только если давление ниже номинала
    local pump_gain = 0
    if pressure < NOMINAL_PRESSURE then
        pump_gain = pump_eff * PUMP_POWER
    end

    -- 2. РАСХОД (Потребители: Бустеры рулей)
    local cur_pitch  = sensor_data.getStickPitchPosition() / 100
    local cur_roll   = sensor_data.getStickRollPosition() / 100
    local cur_rudder = sensor_data.getRudderPosition() / 100
    
    -- Считаем интенсивность работы рулями
    local movement = math.abs(cur_pitch - last_pitch) + 
                     math.abs(cur_roll - last_roll) + 
                     math.abs(cur_rudder - last_rudder)
    
    -- Расход давления при движении (чем резче двигаем, тем больше тратим)
    local consumption = movement * 18.0 
    
    -- Обновляем историю положений
    last_pitch  = cur_pitch
    last_roll   = cur_roll
    last_rudder = cur_rudder

    -- 3. ИТОГОВЫЙ БАЛАНС ДАВЛЕНИЯ
    -- Давление = старое + (приход - расход - утечка)
    pressure = pressure + (pump_gain - consumption - LEAK_RATE)
    
    -- Ограничители
    if pressure > MAX_PRESSURE then pressure = MAX_PRESSURE end
    if pressure < 0 then pressure = 0 end

    -- 4. ВЫВОД НА ПРИБОР
    -- Используем фильтр для "тяжести" стрелки
    local target_output = pressure
    last_pressure_output = last_pressure_output + (target_output - last_pressure_output) * 0.15
    
    booster_press_param:set(last_pressure_output)
    
    -- Прямая установка аргумента (для надежности)
    -- Шкала 250 кг/см2 соответствует 1.0 аргументу
    dev:set_argument_value(126, last_pressure_output / 250)
end

function post_initialize()
    -- При старте (если двигатель запущен) даем давление сразу
    local rpm = sensor_data.getEngineLeftRPM()
    if rpm > 50 then
        pressure = NOMINAL_PRESSURE
        last_pressure_output = NOMINAL_PRESSURE
    else
        pressure = 0
        last_pressure_output = 0
    end
    booster_press_param:set(last_pressure_output)
end

need_to_be_closed = false