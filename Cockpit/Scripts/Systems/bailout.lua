local dev = GetSelf()
dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")

local update_time_step = 0.1
make_default_activity(update_time_step)

local iCommandPlaneEject = 83

-- We only listen to our custom command now, because Ctrl+E is mapped to it in default.lua
dev:listen_command(device_commands.CPT_secondary_ejection_handle)

function SetCommand(command, value)
    if command == device_commands.CPT_secondary_ejection_handle then
        -- Whether triggered by Clickable Handle or Ctrl+E
        
        -- Visual Jettison
        local canopy_dev = GetDevice(devices.CANOPY)
        if canopy_dev then
            canopy_dev:performClickableAction(device_commands.jettison_canopy, 1, false)
        end

        -- Trigger DCS Bailout Sequence (3 times required internally by DCS)
        for i = 0, 2, 1 do
            dispatch_action(nil, iCommandPlaneEject)
        end
    end
end