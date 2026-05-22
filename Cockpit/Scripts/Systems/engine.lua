dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")

local dev = GetSelf()

local update_time_step = 0.02
make_default_activity(update_time_step)

local sensor_data = get_base_data()

local iCommandEnginesStart = 309
local iCommandEnginesStop = 310

-- Хелпер для сглаживания (WMA)
local function WMA(weight, val)
    local last_val = val or 0
    return function(new_val)
        last_val = last_val + (new_val - last_val) * weight
        return last_val
    end
end

local throttle_smoother = WMA(0.2, 0)

-- Состояние систем
local start_cover_pos = 0 
local start_pto_pos = 0
local start_mode = 0       
local throttle_lock_pos = 0 

local engine_starting = get_param_handle("ENGINE_START_ACTIVE")
local throttle_pos_param = get_param_handle("THROTTLE_POS")
local start_timer = 0
local start_duration = 35.0 
local is_starting = false

dev:listen_command(device_commands.StartCover)
dev:listen_command(device_commands.StartButton)
dev:listen_command(device_commands.StartPTO)
dev:listen_command(device_commands.StartMode)
dev:listen_command(device_commands.ThrottleLock)
dev:listen_command(device_commands.Engine_Stop)

function post_initialize()
    local birth = LockOn_Options.init_conditions.birth_place
    if birth=="GROUND_HOT" or birth=="AIR_HOT" then
        throttle_lock_pos = 1
        throttle_pos_param:set(0.1)
    else
        throttle_lock_pos = 0
        throttle_pos_param:set(0.0)
    end
    set_aircraft_draw_argument_value(2015, throttle_lock_pos)
end

function SetCommand(command, value)
    if command == device_commands.ThrottleLock then
        print_message_to_user("DEBUG: Клик защелки, Value: " .. value)
        if value == 1 then 
            local current_axis = sensor_data.getThrottleLeftPosition()
            if throttle_lock_pos == 0 then 
                throttle_lock_pos = 1
                -- Мгновенная визуальная фиксация
                set_aircraft_draw_argument_value(2015, 1)
                
                if start_timer > 0 and start_mode == 1 then
                    dispatch_action(nil, iCommandEnginesStart)
                    print_message_to_user("РУД: МАЛЫЙ ГАЗ (ЗАЖИГАНИЕ)")
                else
                    dispatch_action(nil, iCommandEnginesStart)
                    print_message_to_user("РУД: МАЛЫЙ ГАЗ")
                end
            else
                if current_axis < 0.05 then
                    throttle_lock_pos = 0
                    set_aircraft_draw_argument_value(2015, 0)
                    dispatch_action(nil, iCommandEnginesStop)
                    print_message_to_user("РУД: СТОП (ОСТАНОВ)")
                else
                    print_message_to_user("ОШИБКА: Уберите газ в ноль!")
                end
            end
        end

    elseif command == device_commands.StartCover then
        start_cover_pos = (value > 0) and 1 or 0
        set_aircraft_draw_argument_value(2012, start_cover_pos)
        
    elseif command == device_commands.StartMode then
        start_mode = value
        set_aircraft_draw_argument_value(989, start_mode)

    elseif command == device_commands.StartPTO then
        start_pto_pos = (value > 0) and 1 or 0
        set_aircraft_draw_argument_value(2014, start_pto_pos)
        if start_pto_pos == 1 and start_timer == 0 then
            print_message_to_user(">>> ПТО: АКТИВИРОВАН")
            start_timer = 15.0
        end

    elseif command == device_commands.StartButton then
        if value == 1 and start_cover_pos == 1 and not is_starting then
            local dc_ok = get_elec_primary_dc_ok()
            local ac_pto_ok = (start_pto_pos == 1)
            local pump_ok = (get_param_handle("FUEL_PUMP_EXPI_OK"):get() == 1)
            
            if dc_ok and ac_pto_ok and pump_ok and throttle_lock_pos == 1 then
                is_starting = true
                start_timer = 0
                print_message_to_user(">>> ЦИКЛ ЗАПУСКА НАЧАТ")
            else
                print_message_to_user("ОШИБКА: Проверь ПИТАНИЕ (DC/AC), НАСОСЫ и РУД (МГ)")
            end
        end
    end
end

function update()
    local time_step = update_time_step
    
    if is_starting then
        start_timer = start_timer + time_step
        if start_timer < 15 then
            -- RPM simulation...
        elseif start_timer < 35 then
            -- ...
        else
            is_starting = false
            print_message_to_user(">>> ЗАПУСК ЗАВЕРШЕН")
        end
    end

    -- Анимация РУД
    local throttle_axis = sensor_data.getThrottleLeftPosition()
    local target_anim = (throttle_lock_pos == 1) and (0.1 + throttle_axis * 0.9) or 0.0
    
    local smooth_anim = throttle_smoother(target_anim)
    throttle_pos_param:set(smooth_anim)
    set_aircraft_draw_argument_value(2016, smooth_anim)
end
