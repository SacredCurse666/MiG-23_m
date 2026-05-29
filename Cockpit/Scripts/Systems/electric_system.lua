dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")
dofile(LockOn_Options.script_path.."utils.lua")

local electric_system = GetSelf()
local update_time_step = 0.05 -- 20 раз в секунду
make_default_activity(update_time_step)

local sensor_data = get_base_data()

-- Константы аккумулятора
local battery_charge = 1.0      
local discharge_rate = 0.00005  
local charge_rate = 0.0002     
local starter_consumption = 0.0003 

-- Буфер питания (чтобы запуск не срывался при быстром переключении тумблера)
local power_buffer_timer = 0
local POWER_BUFFER_MAX = 0.5 

-- Состояние переключателей
local battery_ext_pos = 0     -- 1: Аккум (Борт), 0: Выкл, -1: Аэродром
local dc_gen_on = false       
local ac_gen_on = false       

-- Инициализация параметров
elec_primary_dc_ok:set(0)
elec_primary_ac_ok:set(0)
elec_ac_36v_ok:set(0)

-- Для отладки
local prev_dc_ok = false
local prev_charge_log = -1.0 
local last_status = ""

function update()
    local rpm = sensor_data.getEngineLeftRPM()
    local is_starting = get_param_handle("ENGINE_START_ACTIVE"):get() == 1
    
    local source_active = false 
    local current_voltage = 0
    local current_status = "IDLE"
    
    -------------------------------------------------------
    -- ПРОВЕРКА ИСТОЧНИКОВ
    -------------------------------------------------------
    
    -- Режим 1: Аэродромное питание (РАП)
    if battery_ext_pos == -1 then
        source_active = true
        current_voltage = 28.5
        battery_charge = math.min(1.0, battery_charge + charge_rate)
        current_status = "GND PWR (CHARGING)"
        
    -- Режим 2: Бортовой аккумулятор
    elseif battery_ext_pos == 1 then
        if battery_charge > 0.01 then 
            source_active = true
            if dc_gen_on and rpm > 45.0 then
                current_voltage = 28.5
                battery_charge = math.min(1.0, battery_charge + charge_rate)
                current_status = "DC GEN (CHARGING)"
            else
                current_voltage = 24.0 * battery_charge
                battery_charge = math.max(0.0, battery_charge - discharge_rate)
                current_status = "BATTERY (DISCHARGING)"
            end
        end
        
    -- Режим 3: Прямое питание от генератора
    elseif dc_gen_on and rpm > 45.0 then
        source_active = true
        current_voltage = 28.5
        current_status = "GEN ONLY"
    end

    -------------------------------------------------------
    -- ЛОГИКА БУФЕРА И КРИТИЧЕСКОЙ ПРОСАДКИ
    -------------------------------------------------------
    if source_active then
        power_buffer_timer = POWER_BUFFER_MAX
    else
        power_buffer_timer = math.max(0, power_buffer_timer - update_time_step)
    end

    local dc_available = (power_buffer_timer > 0)

    -- Если идет запуск, считаем просадку напряжения
    if is_starting and dc_available then
        local drop = 7.0
        if battery_ext_pos == -1 then drop = 2.0 end 
        
        current_voltage = math.max(0, current_voltage - drop)
        battery_charge = math.max(0.0, battery_charge - starter_consumption)
        current_status = "!!! STARTING LOAD !!!"
        
        if current_voltage < 12.0 then
            dc_available = false
            current_status = "VOLTAGE DROP FAIL"
        end
    end

    -------------------------------------------------------
    -- ОБНОВЛЕНИЕ ПАРАМЕТРОВ
    -------------------------------------------------------
    elec_primary_dc_ok:set(dc_available and 1 or 0)
    elec_primary_ac_ok:set((ac_gen_on and rpm > 55.0) and 1 or 0)
    elec_ac_36v_ok:set((dc_available and battery_ext_pos ~= 0) and 1 or 0)
    
    get_param_handle("ELEC_DC_VOLTAGE"):set(current_voltage)
    get_param_handle("ELEC_BATTERY_CHARGE"):set(battery_charge)

    electric_system:DC_Battery_on(dc_available)
    electric_system:AC_Generator_1_on((ac_gen_on and rpm > 55.0))

    -------------------------------------------------------
    -- ОТЛАДКА
    -------------------------------------------------------
    if dc_available ~= prev_dc_ok then
        print_message_to_user("DC Bus: " .. (dc_available and "ONLINE" or "OFFLINE"))
        prev_dc_ok = dc_available
    end

    if math.abs(battery_charge - prev_charge_log) >= 0.01 or current_status ~= last_status then
        local charge_pct = math.floor(battery_charge * 100)
        print_message_to_user(string.format("Battery: %d%% | Status: %s | Volts: %.1f", charge_pct, current_status, current_voltage))
        prev_charge_log = battery_charge
        last_status = current_status
    end
end

function post_initialize()
    local birth = LockOn_Options.init_conditions.birth_place
    if birth=="GROUND_HOT" or birth=="AIR_HOT" then
        battery_ext_pos = 1
        dc_gen_on = true
        ac_gen_on = true
        battery_charge = 1.0
        
        -- Синхронизация тумблеров в кабине
        electric_system:performClickableAction(device_commands.BatteryExtSwitch, 1, true)
        electric_system:performClickableAction(device_commands.GeneratorDCSwitch, 1, true)
        electric_system:performClickableAction(device_commands.GeneratorACSwitch, 1, true)
    elseif birth=="GROUND_COLD" then
        battery_ext_pos = 0
        dc_gen_on = false
        ac_gen_on = false
        battery_charge = 1.0 -- Аккумулятор заряжен для холодного старта
    end
end

function SetCommand(command, value)
    print_message_to_user(string.format("ELEC CMD: %d | Value: %.2f", command, value))
    if command == device_commands.BatteryExtSwitch then
        battery_ext_pos = value
    elseif command == device_commands.GeneratorDCSwitch then
        dc_gen_on = (value == 1)
    elseif command == device_commands.GeneratorACSwitch then
        ac_gen_on = (value == 1)
    end
end

electric_system:listen_command(device_commands.BatteryExtSwitch)
electric_system:listen_command(device_commands.GeneratorDCSwitch)
electric_system:listen_command(device_commands.GeneratorACSwitch)
