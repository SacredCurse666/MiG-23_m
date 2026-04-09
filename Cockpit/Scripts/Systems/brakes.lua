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

local BRAKE_CONSUMPTION = 0.1 -- Air consumed per update frame when braking hard

-- We listen to these commands to track intent
dev:listen_command(iCommandWheelBrake)
dev:listen_command(iCommandLeftWheelBrake)
dev:listen_command(iCommandRightWheelBrake)

local is_braking = false

local braking_active_param = get_param_handle("WHEEL_BRAKE_ACTIVE")

-- Direct commands
local iCommandWheelBrake = 74
local iCommandLeftWheelBrake = 2112
local iCommandRightWheelBrake = 2113

dev:listen_command(iCommandWheelBrake)
dev:listen_command(iCommandLeftWheelBrake)
dev:listen_command(iCommandRightWheelBrake)

function SetCommand(command, value)
    if command == iCommandWheelBrake or command == iCommandLeftWheelBrake or command == iCommandRightWheelBrake then
        braking_active_param:set(value)
    end
end

function update()
    -- Some flight models don't pass commands to Lua devices.
    -- In that case, we can try to "peek" at the base data if available.
    -- But for now, let's ensure the parameter is at least initialized.
    if braking_active_param:get() == nil then
        braking_active_param:set(0)
    end
end

function post_initialize()
    print_message_to_user("Pneumatic Brakes System Initialized")
end

function update()
    if is_braking then
        local press = get_pneumo_main_press()
        
        if press > 5 then
            -- Scale consumption by pressure? Or just constant.
            consume_main_air(BRAKE_CONSUMPTION)
            
            -- If pressure is very low, brakes become ineffective.
            -- In SFM we can't easily "weaken" brakes, but we could theoretically 
            -- spam "Brake Off" if pressure is zero, but that's jittery.
            -- For now, we mainly simulate the AIR CONSUMPTION which is the core request.
        else
            -- No air, no brakes. In SFM, we can try to force brakes off.
            -- dispatch_action(nil, iCommandWheelBrake, 0)
        end
    end
end

need_to_be_closed = false
