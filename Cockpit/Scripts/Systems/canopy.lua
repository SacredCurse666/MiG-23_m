local dev = GetSelf()
dofile(LockOn_Options.common_script_path.."devices_defs.lua")
dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."utils.lua")
dofile(LockOn_Options.script_path.."Systems/pneumatic_system_api.lua")

local update_time_step = 0.02 
make_default_activity(update_time_step)

local canopy_ext_anim_arg = 38
local canopy_lever_cpt_anim_arg = 129

-- Состояния: 0 - закрыто, 1 - открыто, 2 - сброшено
local CANOPY_COMMAND = 0   

dev:listen_command(Keys.Canopy)
dev:listen_command(Keys.CanopyToggle)
dev:listen_command(device_commands.jettison_canopy)

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
        if CANOPY_COMMAND <= 1 then 
            CANOPY_COMMAND = 1 - CANOPY_COMMAND 
        end
    elseif command == device_commands.jettison_canopy then
        CANOPY_COMMAND = 2
        set_cockpit_draw_argument_value(998, 1.0) 
    end
end

function update()
    local current_canopy_position = get_aircraft_draw_argument_value(canopy_ext_anim_arg)
    local can_move_canopy = is_pneumo_main_ok()

    -- Если фонарь сброшен (катапультирование или рукоятка)
    if current_canopy_position > 0.905 or CANOPY_COMMAND == 2 then
        CANOPY_COMMAND = 2
        set_aircraft_draw_argument_value(canopy_ext_anim_arg, 1.0)
        set_cockpit_draw_argument_value(998, 1.0) -- Убеждаемся, что рукоятка вытянута
        return 
    end

    if CANOPY_COMMAND == 0 and current_canopy_position > 0 then
        -- ЗАКРЫТИЕ
        if can_move_canopy then
            local next_pos = math.max(0, current_canopy_position - 0.01)
            set_aircraft_draw_argument_value(canopy_ext_anim_arg, next_pos)
            set_aircraft_draw_argument_value(canopy_lever_cpt_anim_arg, 1 - (next_pos / 0.9))
            consume_main_air(0.04) -- Расход только при движении
        end
    elseif CANOPY_COMMAND == 1 and current_canopy_position < 0.9 then
        -- ОТКРЫТИЕ
        if can_move_canopy then
            local next_pos = math.min(0.9, current_canopy_position + 0.01)
            set_aircraft_draw_argument_value(canopy_ext_anim_arg, next_pos)
            set_aircraft_draw_argument_value(canopy_lever_cpt_anim_arg, 1 - (next_pos / 0.9))
            consume_main_air(0.04) -- Расход только при движении
        end
    end
end

need_to_be_closed = false
