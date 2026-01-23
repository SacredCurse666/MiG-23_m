dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")
dofile(LockOn_Options.script_path.."utils.lua")

local electric_system = GetSelf()
local update_time_step = 0.05 -- 20 раз в секунду
make_default_activity(update_time_step)

local sensor_data = get_base_data() -- Используем стандартные данные сенсоров DCS

-- Состояние переключателей
local battery_on = false
local generator_on = false

-- Инициализация параметров
elec_primary_dc_ok:set(0)
elec_primary_ac_ok:set(0)

local prev_dc_ok = false
local prev_ac_ok = false

function update()
    -- Получаем обороты двигателя (RPM)
    local rpm = sensor_data.getEngineLeftRPM()
    
    -- Логика DC (Постоянный ток)
    local dc_ok = false
    if battery_on then
        dc_ok = true
    elseif generator_on and rpm > 40 then
        dc_ok = true
    end
    
    -- Логика AC (Переменный ток)
    local ac_ok = false
    if generator_on and rpm > 40 then
        ac_ok = true
    elseif dc_ok then 
        ac_ok = true 
    end

    -- Отладка изменения состояния
    if dc_ok ~= prev_dc_ok then
        print_message_to_user("DC Bus: " .. (dc_ok and "ONLINE" or "OFFLINE"))
        prev_dc_ok = dc_ok
    end
    if ac_ok ~= prev_ac_ok then
        print_message_to_user("AC Bus: " .. (ac_ok and "ONLINE" or "OFFLINE"))
        prev_ac_ok = ac_ok
    end

    -- Обновляем параметры для других систем
    elec_primary_dc_ok:set(dc_ok and 1 or 0)
    elec_primary_ac_ok:set(ac_ok and 1 or 0)
    
    if dc_ok then
        electric_system:DC_Battery_on(true)
    else
        electric_system:DC_Battery_on(false)
    end
    
    if ac_ok then
        electric_system:AC_Generator_1_on(true)
    else
        electric_system:AC_Generator_1_on(false)
    end
end

function post_initialize()
    local birth = LockOn_Options.init_conditions.birth_place
    
    if birth=="GROUND_HOT" or birth=="AIR_HOT" then
        battery_on = true
        generator_on = true
    elseif birth=="GROUND_COLD" then
        battery_on = false
        generator_on = false
    end
    
    print_message_to_user("MiG-23 Electric System: INITIALIZED (" .. birth .. ")")
end

function SetCommand(command,value)
    -- Используем Keys из command_defs.lua
    -- Стандартная команда переключения питания (RShift + L)
    if command == Keys.PowerOnOff then
        if battery_on then
            battery_on = false
            generator_on = false
            print_message_to_user("Power: OFF")
        else
            battery_on = true
            generator_on = true
            print_message_to_user("Power: ON")
        end
    -- Команды батареи (если будут назначены на тумблеры)
    elseif command == Keys.BatteryPower then
        battery_on = (value == 1)
        print_message_to_user("Battery: " .. (battery_on and "ON" or "OFF"))
    elseif command == Keys.PowerGeneratorLeft then
        generator_on = (value == 1)
        print_message_to_user("Generator: " .. (generator_on and "ON" or "OFF"))
    end
end

-- Слушаем стандартные команды
electric_system:listen_command(Keys.PowerOnOff)
electric_system:listen_command(Keys.BatteryPower)
electric_system:listen_command(Keys.PowerGeneratorLeft)
