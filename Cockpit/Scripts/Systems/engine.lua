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

-- Создаем сглаживатель для РУД
local throttle_smoother = WMA(0.2, 0)

-- Состояние системы запуска
local start_cover_pos = 0 
local start_pto_pos = 0
local start_mode = 0       
local throttle_lock_pos = 0 

local engine_starting = get_param_handle("ENGINE_START_ACTIVE")
local throttle_pos_param = get_param_handle("THROTTLE_POS")
local start_timer = 0
local start_duration = 35.0 

dev:listen_command(device_commands.StartCover)
dev:listen_command(device_commands.StartButton)
dev:listen_command(device_commands.StartPTO)
dev:listen_command(device_commands.StartMode)
dev:listen_command(device_commands.ThrottleLock)
dev:listen_command(device_commands.Engine_Stop)
dev:listen_command(Keys.Engine_Stop)

function post_initialize()
    local birth = LockOn_Options.init_conditions.birth_place
    if birth=="GROUND_HOT" or birth=="AIR_HOT" then
        start_mode = 1
        start_cover_pos = 1
        throttle_lock_pos = 1
        throttle_pos_param:set(0.1)
    else
        start_mode = 0
        start_cover_pos = 0
        throttle_lock_pos = 0
        throttle_pos_param:set(0.0)
    end
    set_aircraft_draw_argument_value(989, start_mode)
    set_aircraft_draw_argument_value(2012, start_cover_pos)
    set_aircraft_draw_argument_value(2015, throttle_lock_pos)
    set_aircraft_draw_argument_value(2014, 0)
    print_message_to_user("MiG-23M Engine System Initialized")
end

function SetCommand(command, value)
    if command == device_commands.StartCover then
        if value > 0 then start_cover_pos = 1 else start_cover_pos = 0 end
        set_aircraft_draw_argument_value(2012, start_cover_pos)
        print_message_to_user(string.format("DEBUG: Крышка = %d", start_cover_pos))
        
    elseif command == device_commands.StartMode then
        start_mode = value
        set_aircraft_draw_argument_value(989, start_mode)
        print_message_to_user(string.format("DEBUG: Режим (989) = %d", start_mode))

    elseif command == device_commands.ThrottleLock then
        set_aircraft_draw_argument_value(2015, value)
        if value == 1 then 
            local current_axis = sensor_data.getThrottleLeftPosition()
            if throttle_lock_pos == 0 then 
                throttle_lock_pos = 1
                dispatch_action(nil, iCommandEnginesStart)
                print_message_to_user("РУД: МАЛЫЙ ГАЗ (ЗАЩЕЛКА СНЯТА)")
            else
                if current_axis < 0.05 then
                    throttle_lock_pos = 0
                    dispatch_action(nil, iCommandEnginesStop)
                    print_message_to_user("РУД: СТОП (ОСТАНОВ)")
                else
                    print_message_to_user("ОШИБКА: Сначала уберите газ в ноль!")
                end
            end
        end

    elseif command == device_commands.StartPTO then
        if value > 0 then start_pto_pos = 1 else start_pto_pos = 0 end
        set_aircraft_draw_argument_value(2014, start_pto_pos)
        if start_pto_pos == 1 and start_timer == 0 then
            print_message_to_user(">>> ПТО: АКТИВИРОВАН")
            start_timer = 15.0
            dispatch_action(nil, iCommandEnginesStart)
        end

    elseif command == device_commands.StartButton then
        set_aircraft_draw_argument_value(2013, value)
        if value == 1 then
            if start_cover_pos == 0 then
                print_message_to_user("ОШИБКА: Крышка закрыта!")
                return
            end
            if start_mode == 0 then
                print_message_to_user("ИНФО: Выберите режим (Запуск/Прокрутка)")
                return
            end
            
            local dc_ok = get_elec_primary_dc_ok()
            local pumpI_ok = get_param_handle("FUEL_PUMP_EXPI_OK"):get()
            local pumpII_ok = get_param_handle("FUEL_PUMP_EXPII_OK"):get()
            
            if not dc_ok then
                print_message_to_user("ОШИБКА: Нет питания!")
            elseif start_mode == 1 and (pumpI_ok == 0 and pumpII_ok == 0) then
                print_message_to_user("ОШИБКА: Нет давления топлива!")
            elseif start_timer > 0 then
                print_message_to_user("ИНФО: Цикл уже идет")
            else
                if start_mode == 1 then
                    print_message_to_user(">>> ЗАПУСК...")
                    engine_starting:set(1)
                    start_timer = start_duration
                    dispatch_action(nil, iCommandEnginesStart)
                elseif start_mode == -1 then
                    print_message_to_user(">>> ПРОКРУТКА...")
                    start_timer = 20.0
                    dispatch_action(nil, iCommandEnginesStart) 
                end
            end
        end

    elseif (command == device_commands.Engine_Stop or command == Keys.Engine_Stop) then
        engine_starting:set(0)
        start_timer = 0
        dispatch_action(nil, iCommandEnginesStop)
        print_message_to_user("ДВИГАТЕЛЬ ОСТАНОВЛЕН")
    end
end

local prev_rpm = -1
local timer = 0

function update()
    local rpm = sensor_data.getEngineLeftRPM()
    local throttle_axis = sensor_data.getThrottleLeftPosition()
    local target_anim = 0
    
    if throttle_lock_pos == 1 then
        target_anim = 0.1 + (throttle_axis * 0.9)
    else
        target_anim = 0.0
    end
    
    local smooth_anim = throttle_smoother(target_anim)
    throttle_pos_param:set(smooth_anim)
    set_aircraft_draw_argument_value(2016, smooth_anim)

    if start_timer > 0 then
        start_timer = start_timer - update_time_step
        if start_timer <= 0 then
            engine_starting:set(0)
            print_message_to_user("ЦИКЛ ЗАВЕРШЕН")
        end
    end

    timer = timer + update_time_step
    if timer > 0.5 then
        if math.abs(rpm - prev_rpm) > 1.0 then
            if rpm > 0.1 and rpm < 95 then 
                print_message_to_user(string.format("RPM: %.1f%%", rpm))
            end
            prev_rpm = rpm
        end
        timer = 0
    end
end

need_to_be_closed = false
