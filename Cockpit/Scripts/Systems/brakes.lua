-- Brakes System for MiG-23M (Pneumatic)
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/pneumatic_system_api.lua")
dofile(LockOn_Options.script_path.."utils.lua")

local dev = GetSelf()
local update_time_step = 0.02
make_default_activity(update_time_step)

local sensor_data = get_base_data()

local iCommandWheelBrake = 74
local iCommandLeftWheelBrake = 2112
local iCommandRightWheelBrake = 2113

local BRAKE_CONSUMPTION = 0.05 -- Air consumed per update frame when braking hard

-- We listen to these commands to track intent
dev:listen_command(iCommandWheelBrake)
dev:listen_command(iCommandLeftWheelBrake)
dev:listen_command(iCommandRightWheelBrake)

local braking_active_param = get_param_handle("WHEEL_BRAKE_ACTIVE")

function post_initialize()
    braking_active_param:set(0)
    print_message_to_user("Pneumatic Brakes System Initialized")
end

function SetCommand(command, value)
    if command == iCommandWheelBrake or command == iCommandLeftWheelBrake or command == iCommandRightWheelBrake then
        braking_active_param:set(value)
    end
end

function update()
    local is_braking = (braking_active_param:get() or 0) > 0
    
    if is_braking then
        local press = get_pneumo_main_press()
        if press > 5 then
            consume_main_air(BRAKE_CONSUMPTION)
        end
    end
end

need_to_be_closed = false
