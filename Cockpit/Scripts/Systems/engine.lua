dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."devices.lua")

local dev = GetSelf()

local update_time_step = 0.02
make_default_activity(update_time_step)

local sensor_data = get_base_data()

local iCommandEnginesStart = 309
local iCommandEnginesStop = 310

dev:listen_command(device_commands.Engine_Start)
dev:listen_command(device_commands.Engine_Stop)
dev:listen_command(Keys.Engine_Start)
dev:listen_command(Keys.Engine_Stop)

function post_initialize()
    print_message_to_user("MiG-23M Engine System Initialized")
end

function SetCommand(command,value)
    if (command == device_commands.Engine_Start or command == Keys.Engine_Start) then
        print_message_to_user("Engine Start Command Received")
        dispatch_action(nil, iCommandEnginesStart)
    elseif (command == device_commands.Engine_Stop or command == Keys.Engine_Stop) then
        print_message_to_user("Engine Stop Command Received")
        dispatch_action(nil, iCommandEnginesStop)
    end
end

local prev_rpm = -1
local timer = 0

function update()
    local rpm = sensor_data.getEngineLeftRPM()
    
    -- Вывод RPM каждые 0.5 секунды, если двигатель крутится, но еще не на режиме (или просто для отладки всегда, если меняется)
    timer = timer + update_time_step
    if timer > 0.5 then
        if math.abs(rpm - prev_rpm) > 1.0 then -- Если обороты изменились более чем на 1%
             -- Выводим только если идет процесс запуска (например до 60%) или остановки
            if rpm > 0.1 and rpm < 90 then 
                print_message_to_user(string.format("Engine RPM: %.1f%%", rpm))
            end
            prev_rpm = rpm
        end
        timer = 0
    end
end

need_to_be_closed = false