local dev = GetSelf()
dofile(LockOn_Options.common_script_path.."devices_defs.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")
device_commands = Keys
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")
dofile(LockOn_Options.script_path.."utils.lua")
dofile(LockOn_Options.script_path.."Systems/gear_system.lua")

local update_time_step = 0.05
make_default_activity(update_time_step)

local full_trim_time = 10.0 -- По умолчанию в DCS SFM, кажется, требуется 10 секунд для полного триммирования крена от нейтрали до правого, или тангажа от нейтрали до верхнего, или руля направления от нейтрали до правого
local full_trim_pitch_time = 3.75
local trim_update = update_time_step / full_trim_time
local trim_pitch_update = update_time_step / full_trim_pitch_time

-- некоторые корректировки масштабирования, входные значения находятся в диапазоне от -1 до 1, передайте масштабированную версию этих значений в DCS
local pitch_trim_scale = 0.4 -- приблизительное значение 0.4, возможно, требует доработки
local roll_trim_scale = 0.06  -- приблизительное значение 0.06, возможно, требует доработки
local rudder_trim_scale = 0.27  -- дает примерно 7 градусов максимального отклонения, согласно NATOPS

local sensor_data = get_base_data()

local fuel_warning	 = get_param_handle("FUEL_WARNING")


local trim_override_handle = get_param_handle("TRIM_OVERRIDE") -- устанавливается системой AFCS (автопилот), когда она берет на себя управление
trim_override_handle:set(0)
local trim_override = false

local pitch_trim_handle = get_param_handle("PITCH_TRIM")
pitch_trim_handle:set(0.0)
local roll_trim_handle = get_param_handle("ROLL_TRIM")
roll_trim_handle:set(0.0)
local rudder_trim_handle = get_param_handle("RUDDER_TRIM")
rudder_trim_handle:set(0.0)

local trim_rudder_gauge_handle = get_param_handle("TRIM_RUBBER_GAUGE")
--trim_rudder_gauge:set(1.0)
local roll_trim_gauge_handle= get_param_handle("TRIM_ROLL_GAUGE")
--roll_trim_gauge:set(1.0)
local pitch_trim_gauge_handle = get_param_handle("TRIM_PITCH_GAUGE")
--pitch_trim_gauge:set(1.0)

local pitch_trim_knob_handle = get_param_handle("PITCH_TRIM_KNOB")
pitch_trim_knob_handle:set(0.0)
local roll_trim_knob_handle = get_param_handle("ROLL_TRIM_KNOB")
roll_trim_knob_handle:set(0.0)
local rudder_trim_knob_handle = get_param_handle("RUDDER_TRIM_KNOB")
rudder_trim_knob_handle:set(0.0)

local engine_power_max = get_param_handle("ENG_POWER_MAX")
engine_power_max:set(0)
local engine_power_afterburn = get_param_handle("ENG_POWER_AFTERBURN")
engine_power_afterburn:set(0)

local wing_warning = get_param_handle("WING_WARNING")
wing_warning:set(0)

-- Landing Lights Parameters
local gear_nose_released = get_param_handle("GEAR_NOSE_RELEASED")
local gear_left_released = get_param_handle("GEAR_LEFT_RELEASED")
local gear_right_released = get_param_handle("GEAR_RIGHT_RELEASED")

local landing_light_switch_pos = -1.0 -- Default: Off
local land_light_left_ext = 0.0
local land_light_right_ext = 0.0
local land_light_anim_speed = 0.02 -- Animation speed
local last_debug_state = ""

local pitch_trim_gauge = WMA(0.15,0)
local yaw_trim_gauge = WMA(0.15,0)

dev:listen_command(Keys.TrimStop)
dev:listen_command(Keys.TrimUp)
dev:listen_command(Keys.TrimDown)
dev:listen_command(Keys.TrimRight)
dev:listen_command(Keys.TrimLeft)
dev:listen_command(Keys.TrimRightRudder)
dev:listen_command(Keys.TrimLeftRudder)
dev:listen_command(Keys.TrimCancel)
dev:listen_command(device_commands.LandingLightSwitch)
-- коэффициенты --
local optionsData_trimSpeedPitch =  1
local optionsData_trimSpeedRoll =  1
local optionsData_trimSpeedRudder =  1
------------------

local trimming_updown = 0 -- 1=вверх,0=нейтраль,-1=вниз
local trimming_leftright = 0 -- 1=вправо,0=нейтраль,-1=влево
local trimming_rudder_leftright = 0 -- 1=вправо,0=нейтраль,-1=влево

local trim_cancellation = 0

local trim_rudder_state = 1
local trim_roll_state = 1
local trim_pitch_state = 1

local iCommandPlaneTrimPitchAbs = 2022
local iCommandPlaneTrimRollAbs = 2023
local iCommandPlaneTrimRudderAbs = 2024
local iCommandPlaneTrimCancel = 97
local iCommandPlaneTrimRoll = 2020
--local iCommandPlanePitch = 2001
--local iCommandPlaneRoll	= 2002
local iCommandPlaneRudder = 2003
function post_initialize()
    --print_message_to_user ("start initialize")
    trim_rudder_gauge_handle:set(1.0)
    roll_trim_gauge_handle:set(1.0)
    pitch_trim_gauge_handle:set(1.0)

    -- engine_power_max:set(0)
    -- engine_power_afterburn:set(0)
    --print_message_to_user ("end initialize ")
    
    local birth = LockOn_Options.init_conditions.birth_place
    if birth == "GROUND_HOT" then
        landing_light_switch_pos = 0.0 -- Рулежный
        land_light_left_ext = 1.0
        land_light_right_ext = 1.0
        dev:performClickableAction(device_commands.LandingLightSwitch, 0.0, true)
    elseif birth == "AIR_HOT" then
        landing_light_switch_pos = -1.0 -- Выкл
        land_light_left_ext = 0.0
        land_light_right_ext = 0.0
        dev:performClickableAction(device_commands.LandingLightSwitch, -1.0, true)
    else
        landing_light_switch_pos = -1.0 -- Холодный старт
        land_light_left_ext = 0.0
        land_light_right_ext = 0.0
    end
end

function SetCommand(command,value)
    --print_message_to_user(command)
    if command == Keys.TrimStop then
        trimming_updown = 0
        trimming_leftright = 0
        trimming_rudder_leftright = 0
        trim_cancellation = 0
        -- pitch_trim_knob_handle:set(0)
        -- roll_trim_knob_handle:set(0)
    elseif command == Keys.TrimUp then
        trimming_updown = 1
        -- pitch_trim_knob_handle:set(trimming_updown)
        --print_message_to_user("TrimUp")
    elseif command == Keys.TrimDown then
        trimming_updown = -1
        -- pitch_trim_knob_handle:set(trimming_updown)
        --print_message_to_user("TrimDown")
    elseif command == Keys.TrimRight then
        trimming_leftright = 1
        -- roll_trim_knob_handle:set(trimming_leftright)
        --print_message_to_user("TrimRight")
    elseif command == Keys.TrimLeft then
        trimming_leftright = -1
        -- roll_trim_knob_handle:set(trimming_leftright)
        --print_message_to_user("TrimLeft")
    elseif command == Keys.TrimRightRudder then
        trimming_rudder_leftright = 1
        --print_message_to_user("TrimRightRudder")
    elseif command == Keys.TrimLeftRudder then
        trimming_rudder_leftright = -1
        --print_message_to_user("TrimLeftRudder")
    elseif command == Keys.TrimCancel then
        trim_cancellation = 1
        --print_message_to_user("trim_cancellation")
    -- разделение оси руля направления (доступность)
    elseif command == device_commands.rudder_axis_left then
        dispatch_action(nil, iCommandPlaneRudder, value * -0.5 - 0.5)
    elseif command == device_commands.rudder_axis_right then
        dispatch_action(nil, iCommandPlaneRudder, value * 0.5 + 0.5)
    elseif command == device_commands.LandingLightSwitch then
        landing_light_switch_pos = value
    -- elseif command == Keys.ShowControls then
    --     SHOW_CONTROLS:set(1-SHOW_CONTROLS:get())
    end
end


local prev_trim_override = trim_override

function update_landing_lights()
    -- Проверка выпуска шасси (все 3 стойки должны быть выпущены > 0.5)
    local g_nose = gear_nose_released:get()
    local g_left = gear_left_released:get()
    local g_right = gear_right_released:get()
    local gear_ok = g_nose > 0.5 and g_left > 0.5 and g_right > 0.5
    
    -- Проверка электропитания (DC шина)
    local power_ok = get_elec_primary_dc_ok()
    
    local target_left_ext = 0
    local target_right_ext = 0
    local brightness_208 = 0 -- Передняя
    local brightness_209 = 0 -- Левая
    local brightness_210 = 0 -- Правая
    
    local mode_name = "ВЫКЛ"
    
    if gear_ok then
        if landing_light_switch_pos == -1.0 then -- ВЫКЛЮЧЕНО / УБРАНО
            target_left_ext = 0
            target_right_ext = 0
            brightness_208 = 0
            brightness_209 = 0
            brightness_210 = 0
            mode_name = "ВЫКЛ"
        elseif landing_light_switch_pos == 0.0 then -- РУЛЕЖНЫЙ (все 3 выпущены и горят)
            target_left_ext = 1.0
            target_right_ext = 1.0
            brightness_208 = 1.0 -- 100%
            brightness_210 = 1.0 -- 100%
            brightness_209 = 0.5 -- 50%
            mode_name = "РУЛЕЖНЫЙ"
        elseif landing_light_switch_pos == 1.0 then -- ПОСАДОЧНЫЙ (асимметрия)
            target_left_ext = 1.0
            target_right_ext = 0.0 -- Складывается
            brightness_209 = 1.0 -- 100%
            brightness_208 = 0.0 -- Выкл
            brightness_210 = 0.0 -- Выкл
            mode_name = "ПОСАДОЧНЫЙ"
        end
    else
        -- Шасси не выпущено - всё выключаем и убираем
        target_left_ext = 0
        target_right_ext = 0
        brightness_208 = 0
        brightness_209 = 0
        brightness_210 = 0
        mode_name = "ШАССИ УБРАНО (БЛОКИРОВКА)"
    end

    -- Если нет электричества, свет гаснет независимо от режима
    if not power_ok then
        brightness_208 = 0
        brightness_209 = 0
        brightness_210 = 0
        mode_name = mode_name .. " (БЕЗ ПИТАНИЯ)"
    end
    
    -- Вывод отладочных сообщений при изменении состояния
    local current_debug = string.format("LL Mode: %s | Gear: %.1f/%.1f/%.1f | Pwr: %s", 
                                        mode_name, g_nose, g_left, g_right, power_ok and "OK" or "OFF")
    if current_debug ~= last_debug_state then
        print_message_to_user(current_debug)
        last_debug_state = current_debug
    end
    
    -- Плавная анимация выпуска/уборки (аргументы 51 и 52)
    -- Если НЕТ питания, механизмы НЕ двигаются (замерзают в текущем положении)
    if power_ok then
        if land_light_left_ext < target_left_ext then
            land_light_left_ext = math.min(target_left_ext, land_light_left_ext + land_light_anim_speed)
        elseif land_light_left_ext > target_left_ext then
            land_light_left_ext = math.max(target_left_ext, land_light_left_ext - land_light_anim_speed)
        end
        
        if land_light_right_ext < target_right_ext then
            land_light_right_ext = math.min(target_right_ext, land_light_right_ext + land_light_anim_speed)
        elseif land_light_right_ext > target_right_ext then
            land_light_right_ext = math.max(target_right_ext, land_light_right_ext - land_light_anim_speed)
        end
    end
    
    -- Установка аргументов анимации выпуска
    set_aircraft_draw_argument_value(51, land_light_left_ext)
    set_aircraft_draw_argument_value(52, land_light_right_ext)
    
    -- Установка яркости фар (только если шасси выпущено и есть питание, иначе 0)
    if not gear_ok or not power_ok then
        brightness_208 = 0
        brightness_209 = 0
        brightness_210 = 0
    end
    
    set_aircraft_draw_argument_value(208, brightness_208)
    set_aircraft_draw_argument_value(209, brightness_209)
    set_aircraft_draw_argument_value(210, brightness_210)
end

function update()
    update_landing_lights()
    -- Индикатор выпуска крыла
    -- print_message_to_user("LANDING_GEAR_STATE ")
    -- local current_gear_state = LANDING_GEAR_STATE
    -- print_message_to_user("LANDING_GEAR_STATE " .. current_gear_state) 
    --  if current_gear_state == 1.0 then
    --     wing_warning:set(1)
    --     else
    --         wing_warning:set(0)
    -- end
    -- Индикатор макс тяги и форсажа
    local engine_power = sensor_data.getEngineLeftRPM()
    -- print_message_to_user(engine_power)
    if (math.abs(engine_power) > 99 and math.abs(engine_power) < 101) then
        engine_power_max:set(1)
        engine_power_afterburn:set(0)
        --print_message_to_user("power_max" )
        elseif math.abs(engine_power) > 101  then
            engine_power_afterburn:set(1)
            engine_power_max:set(0)
            --print_message_to_user("afterburn " )
        else
            engine_power_max:set(0)
            engine_power_afterburn:set(0)
    end
        -- Индикатор низкого уровня топлива 

    local totalFuel = sensor_data.getTotalFuelWeight()
    if totalFuel<= 600 then
        fuel_warning:set(1)
        else
            fuel_warning:set(0)
    end 


    -- Триммирование

    trim_override = (trim_override_handle:get()==1)
    if prev_trim_override ~= trim_override then
        if trim_override then
            -- началось переопределение триммера
            --print_message_to_user("началось переопределение триммера")
        else
            -- переопределение триммера остановлено, восстановить триммер
            --print_message_to_user("переопределение триммера остановлено")
            local pitch_trim = pitch_trim_handle:get()
            dispatch_action(nil, iCommandPlaneTrimPitchAbs, pitch_trim*pitch_trim_scale)
            local roll_trim = roll_trim_handle:get()
            dispatch_action(nil, iCommandPlaneTrimRollAbs, roll_trim*roll_trim_scale)
            local rudder_trim = rudder_trim_handle:get()
            dispatch_action(nil, iCommandPlaneTrimRudderAbs, rudder_trim*rudder_trim_scale)
        end
        prev_trim_override = trim_override
    end
    local pitch_trim=pitch_trim_handle:get()
    local roll_trim=roll_trim_handle:get()
    local rudder_trim=rudder_trim_handle:get()

    if trimming_updown ~= 0 then
        pitch_trim = pitch_trim + trimming_updown * trim_pitch_update * optionsData_trimSpeedPitch
        if pitch_trim>1 then
            pitch_trim=1
        elseif pitch_trim<-1 then
            pitch_trim=-1
        end
        pitch_trim_handle:set(pitch_trim)
        dispatch_action(nil, iCommandPlaneTrimPitchAbs, pitch_trim*pitch_trim_scale)
    end
    --print_message_to_user("pitch_trim = ".. pitch_trim .. " roll_trim = " .. roll_trim .. " rudder_trim= " .. rudder_trim)


    pitch_trim_knob_handle:set(trimming_updown)
    roll_trim_knob_handle:set(trimming_leftright)
    rudder_trim_knob_handle:set(trimming_rudder_leftright)
    --print_message_to_user("trimming_updown = ".. trimming_updown.. "trimming_leftright = " .. trimming_leftright)

    if trim_override then
        return
    end

    if trimming_updown ~= 0 then
        pitch_trim = pitch_trim + trimming_updown * trim_pitch_update * optionsData_trimSpeedPitch
        if pitch_trim>1 then
            pitch_trim=1
        elseif pitch_trim<-1 then
            pitch_trim=-1
        end
        pitch_trim_handle:set(pitch_trim)
        dispatch_action(nil, iCommandPlaneTrimPitchAbs, pitch_trim*pitch_trim_scale)
        --[[
        ПРИМЕЧАНИЕ: согласно NATOPS, продольное триммирование на самом деле
        обеспечивается перемещением всего горизонтального стабилизатора, а не только
        рулей высоты. Не уверен, как переопределить это в SFM, так что пока
        мы просто триммируем рулями высоты.

        --]]
    end
    if trimming_leftright ~= 0 then
        roll_trim = roll_trim + trimming_leftright * trim_update * optionsData_trimSpeedRoll
        if roll_trim>1 then
            roll_trim=1
        elseif roll_trim<-1 then
            roll_trim=-1
        end
        roll_trim_handle:set(roll_trim)
        dispatch_action(nil, iCommandPlaneTrimRoll, trimming_leftright * roll_trim_scale * 0.05)
    end
    if trimming_rudder_leftright ~= 0 then
        rudder_trim = rudder_trim + trimming_rudder_leftright * trim_update * optionsData_trimSpeedRudder
        if rudder_trim>1 then
            rudder_trim=1
        elseif rudder_trim<-1 then
            rudder_trim=-1
        end
        dev:performClickableAction(device_commands.rudder_trim, rudder_trim, true)
        --rudder_trim_handle:set(rudder_trim)
        --dispatch_action(nil, iCommandPlaneTrimRudderAbs, rudder_trim)
    end

    	set_aircraft_draw_argument_value(510, (pitch_trim))
		set_aircraft_draw_argument_value(511, (pitch_trim))
        --print_message_to_user ("pitch_trim+roll_trim = " .. (pitch_trim+roll_trim)/2)
    if pitch_trim == 0 then
        pitch_trim_gauge_handle:set(1)
        else
            pitch_trim_gauge_handle:set(0)
    end
    if roll_trim == 0 then
        roll_trim_gauge_handle:set(1)
        else
            roll_trim_gauge_handle:set(0)  
    end
    if rudder_trim==0 then
        trim_rudder_gauge_handle:set(1)
        else
            trim_rudder_gauge_handle:set(0)
    end
    update_trim_reset()
end


function update_trim_reset()
    -- плавный сброс триммера
    if trim_cancellation ~= 0 then
        -- вместо центрирования, установите триммер тангажа примерно на 2 на указателе (0.5)
        -- это положение по умолчанию для холодного старта, взлета и в полете,
        -- так что это кажется лучшим выбором, чем 0.
        local pitch_trim_default = 0 -- 0.5

        local pitch_trim=pitch_trim_handle:get()
        local roll_trim=roll_trim_handle:get()
        local rudder_trim=rudder_trim_handle:get()
        --print_message_to_user("pitch_trim = ".. pitch_trim.. " roll_trim = " .. roll_trim .. " rudder_trim = " .. rudder_trim)
        local trim_pitch_delta = trim_pitch_update * optionsData_trimSpeedPitch
        local trim_roll_delta = trim_pitch_update * optionsData_trimSpeedRoll
        local trim_rudder_delta = trim_pitch_update * optionsData_trimSpeedRudder
        -- print_message_to_user('сброс триммера... ' ..pitch_trim)
        -- центрировать носовой триммер 
        if math.abs(pitch_trim) + pitch_trim_default < trim_pitch_delta then
           pitch_trim = pitch_trim_default
        elseif pitch_trim < -pitch_trim_default then
            pitch_trim = pitch_trim + trim_pitch_delta
        elseif pitch_trim > -pitch_trim_default then
            pitch_trim = pitch_trim - trim_pitch_delta
        end

        pitch_trim_handle:set(pitch_trim)
        -- центрировать триммер элеронов
        if math.abs(roll_trim) < trim_roll_delta then
            roll_trim = 0
        elseif roll_trim < 0 then
            roll_trim = roll_trim + trim_roll_delta
        elseif roll_trim > 0 then
            roll_trim = roll_trim - trim_roll_delta
        end

        roll_trim_handle:set(roll_trim)
        -- центрировать триммер руля направления
        if math.abs(rudder_trim) < trim_rudder_delta then
            rudder_trim = 0
        elseif rudder_trim < 0 then
            rudder_trim = rudder_trim + trim_rudder_delta
        elseif rudder_trim > 0 then
            rudder_trim = rudder_trim - trim_rudder_delta
        end

        rudder_trim_handle:set(rudder_trim)
        --dev:performClickableAction(device_commands.rudder_trim, rudder_trim, true)
    end
end




need_to_be_closed = false