local dev = GetSelf()
dofile(LockOn_Options.common_script_path.."devices_defs.lua")
dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."utils.lua")

local update_time_step = 0.02  -- 50 time per second
make_default_activity(update_time_step)

local sensor_data = get_base_data()

local main_press_param = get_param_handle("PNEUMO_MAIN_PRESS")

local canopy_ext_anim_arg = 38
local canopy_lever_cpt_anim_arg = 129

-- Состояния: 0 - закрыто, 1 - открыто, 2 - сброшено
local CANOPY_COMMAND = 0   

dev:listen_command(Keys.Canopy)
dev:listen_command(Keys.CanopyToggle)
dev:listen_command(device_commands.jettison_canopy)

dev:listen_event("repair")

function post_initialize()
    local birth = LockOn_Options.init_conditions.birth_place
    if birth == "GROUND_COLD" then
        CANOPY_COMMAND = 1
        set_aircraft_draw_argument_value(canopy_ext_anim_arg, 0.9)
    else
        CANOPY_COMMAND = 0
        set_aircraft_draw_argument_value(canopy_ext_anim_arg, 0.0)
    end
end

function SetCommand(command,value)
    if (command == Keys.Canopy or command == Keys.CanopyToggle) then
        if CANOPY_COMMAND <= 1 then -- работаем только если фонарь на месте
            CANOPY_COMMAND = 1 - CANOPY_COMMAND 
        end
    elseif command == device_commands.jettison_canopy then
        CANOPY_COMMAND = 2
    end
end

local prev_canopy_val = -1
function update()
    local current_canopy_position = get_aircraft_draw_argument_value(canopy_ext_anim_arg)
    local current_pressure = main_press_param:get()
    local can_move_canopy = current_pressure > 20

    -- ЛОГИКА A-29B (используется в Yak-3): Если значение выше 0.95, значит произошел сброс (Jettison)
    -- Мы используем 0.905 как порог, так как открытие ограничено 0.9
    if current_canopy_position > 0.905 then
        CANOPY_COMMAND = 2
    end

    if CANOPY_COMMAND == 0 and current_canopy_position > 0 and can_move_canopy then
        -- ЗАКРЫТИЕ
        current_canopy_position = current_canopy_position - 0.01
        if current_canopy_position < 0 then current_canopy_position = 0 end
        
        set_aircraft_draw_argument_value(canopy_ext_anim_arg, current_canopy_position)
        set_aircraft_draw_argument_value(canopy_lever_cpt_anim_arg, 1 - (current_canopy_position / 0.9))

    elseif CANOPY_COMMAND == 1 and current_canopy_position < 0.9 and can_move_canopy then
        -- ОТКРЫТИЕ (Остановка на 0.9, чтобы не доходить до ключа исчезновения 1.0)
        current_canopy_position = current_canopy_position + 0.01
        if current_canopy_position > 0.9 then current_canopy_position = 0.9 end
        
        set_aircraft_draw_argument_value(canopy_ext_anim_arg, current_canopy_position)
        set_aircraft_draw_argument_value(canopy_lever_cpt_anim_arg, 1 - (current_canopy_position / 0.9))
    
    elseif current_canopy_position >= 0.895 and current_canopy_position < 0.905 and CANOPY_COMMAND == 1 then
        -- Принудительная фиксация в открытом положении (защита от перелета за 0.9)
        current_canopy_position = 0.9
        set_aircraft_draw_argument_value(canopy_ext_anim_arg, current_canopy_position)
        -- Рычаг ставим в соответствующее положение (0.0 для открытого)
        set_aircraft_draw_argument_value(canopy_lever_cpt_anim_arg, 0.0)

    elseif CANOPY_COMMAND == 2 then
        -- СБРОС (Ключ 100 = 1.0 - фонарь пропадает)
        set_aircraft_draw_argument_value(canopy_ext_anim_arg, 1.0)
        set_aircraft_draw_argument_value(canopy_lever_cpt_anim_arg, 0.0)
    end

    -- Обновление рычага в кабине
    local cockpit_lever = get_cockpit_draw_argument_value(canopy_lever_cpt_anim_arg)
    if prev_canopy_val ~= cockpit_lever then
        local canopy_lever_clickable_ref = get_clickable_element_reference("PNT_129")
        if canopy_lever_clickable_ref then
            canopy_lever_clickable_ref:update()
        end
        prev_canopy_val = cockpit_lever
    end
end

function CockpitEvent(event, val)
    if event == "repair" then
        CANOPY_COMMAND = 1 
        set_aircraft_draw_argument_value(canopy_ext_anim_arg, 0.9)
    end
end

need_to_be_closed = false