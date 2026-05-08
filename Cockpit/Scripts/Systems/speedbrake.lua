local dev = GetSelf()
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/hydraulic_system_api.lua")
dofile(LockOn_Options.common_script_path.."devices_defs.lua")

local sensor_data = get_base_data()
print_message_to_user("brake_shield load")

local update_time_step = 0.1
make_default_activity(update_time_step)

local FlapExtensionTimeSeconds = 3.0  

local value_command = 1
local PlaneAirBrake_State = 0
local PlaneAirBrake_LastState = 0
--local PlaneAirBrake_TargetState = 0

dev:listen_command(Keys.PlaneAirBrake)
dev:listen_command(device_commands.speedbrake)
--dev:listen_command(iCommandPlaneAirBrake)
function post_initialize()
end

function SetCommand(command,value)
    print_message_to_user("Command: ".. command .. " Value: ".. value)
    if command == device_commands.speedbrake then
        PlaneAirBrake_LastState = 1 - PlaneAirBrake_LastState
        --value_command = 1
    elseif command == Keys.PlaneAirBrake and value_command == 0 then
        dev:performClickableAction(device_commands.speedbrake, 0, false)
        print_message_to_user("Value_command: ".. value_command)
        value_command = 1

    elseif command == Keys.PlaneAirBrake and value_command == 1 then
        dev:performClickableAction(device_commands.speedbrake, 1, false)
        print_message_to_user("Value_command: ".. value_command)
        value_command = 0
        
        --PlaneAirBrake_LastState = 1
        --PlaneAirBrake_LastState = 1

    -- elseif command == Keys.PlaneAirBrake then
    --     print_message_to_user ("Keys.PlaneAirBrake")
    end
end

local AirBrake_increment = update_time_step / FlapExtensionTimeSeconds -- sets the speed of flap animation
function update()
    if get_hyd_utility_ok() then
        if PlaneAirBrake_LastState == 0 then
        PlaneAirBrake_State = PlaneAirBrake_State - AirBrake_increment
        -- print_message_to_user ("PlaneAirBrake_LastState Update DEC = " .. PlaneAirBrake_LastState)
        --PlaneAirBrake_LastState = 1
        -- PlaneAirBrake_LastState = 1
    elseif PlaneAirBrake_LastState == 1 then
        PlaneAirBrake_State = PlaneAirBrake_State + AirBrake_increment
        -- print_message_to_user ("PlaneAirBrake_LastState Update INC = " .. PlaneAirBrake_LastState)
        -- PlaneAirBrake_LastState = 0
    end
    end

    if PlaneAirBrake_State < 0 then
        -- print_message_to_user("FLAPS_STATE < 0 ")
        PlaneAirBrake_State = 0
        PlaneAirBrake_LastState = 0
    elseif PlaneAirBrake_State > 1 then
        -- print_message_to_user("FLAPS_STATE > 1 ")
        PlaneAirBrake_State = 1
        PlaneAirBrake_LastState = 1
    end
    set_aircraft_draw_argument_value(21,PlaneAirBrake_State)
end

need_to_be_closed = false