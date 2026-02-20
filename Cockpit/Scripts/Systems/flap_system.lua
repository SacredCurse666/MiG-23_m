local dev = GetSelf()
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/hydraulic_system_api.lua")
dofile(LockOn_Options.common_script_path.."devices_defs.lua")

local sensor_data = get_base_data()
print_message_to_user("flap load")

local update_time_step = 0.02
make_default_activity(update_time_step)

local FlapExtensionTimeSeconds = 6.0  

local flap_ind = get_param_handle("FLAP_IND")
flap_ind:set(0)

local FLAPS_STATE	=	0.0 -- 0 = retracted, 0.5 = takeoff, 1.0 = landing -- "current" flap position		
local FLAPS_TARGET  =   0 -- 0 = retracted, 0.5 = takeoff, 1.0 = landing -- "future" flap position
local FLAPS_TARGET_LAST = 0
local MOVING = 0          -- 1 = we "want" movement to a new position

local flap_keyboard = 0
-- local fromkeyboard = true -- сделал с клавиатуры переключение по кругу, т.к переключение вверх и вниз получается очень геморно

dev:listen_command(Keys.PlaneFlaps)
dev:listen_command(Keys.PlaneFlapsUp)
dev:listen_command(Keys.PlaneFlapsDown)

dev:listen_command(device_commands.BtnFlapsCleared)
dev:listen_command(device_commands.BtnFlapsTakeOff)
dev:listen_command(device_commands.BtnFlapsLanding)
dev:listen_command(device_commands.BtnFlapsOff)

function post_initialize()
end

function SetCommand(command,value)
print_message_to_user("Command: ".. command .. " Value: ".. value)
    if command == device_commands.BtnFlapsTakeOff and value == 1 then -- взлет
        flap_keyboard = 1
        dev:performClickableAction(device_commands.BtnFlapsLanding, 0, false)
        dev:performClickableAction(device_commands.BtnFlapsCleared, 0, false)
        flap_ind:set(1)
        MOVING = 1
        FLAPS_TARGET = 0.5
        FLAPS_TARGET_LAST= 1
        
        -- print_message_to_user ("TakeOff ON")
    -- elseif command == device_commands.BtnFlapsTakeOff and value == 0 then
        -- fromkeyboard = false
        -- print_message_to_user ("TakeOff OFF")
    elseif command == device_commands.BtnFlapsLanding and value == 1 then -- посадка
        flap_keyboard = 2
        dev:performClickableAction(device_commands.BtnFlapsTakeOff, 0, false)
        dev:performClickableAction(device_commands.BtnFlapsCleared, 0, false)
        flap_ind:set(1)
        MOVING = 1
        FLAPS_TARGET = 1
        FLAPS_TARGET_LAST= -1

        -- print_message_to_user ("Landing ON")        
    -- elseif command == device_commands.BtnFlapsLanding and value == 0 then
        --fromkeyboard = true
        -- print_message_to_user ("Landing OFF")
    elseif command == device_commands.BtnFlapsCleared and value == 1 then -- убрано
        flap_keyboard = 0
        flap_ind:set(0)
        dev:performClickableAction(device_commands.BtnFlapsTakeOff, 0, false)
        dev:performClickableAction(device_commands.BtnFlapsLanding, 0, false)
        MOVING = -1 
        -- print_message_to_user ("Cleared ON")
        -- print_message_to_user ("MOVING = " .. MOVING)
    -- elseif command == device_commands.BtnFlapsCleared and value == 0 then
        -- print_message_to_user ("Cleared OFF")
        --fromkeyboard = true
    elseif command == device_commands.BtnFlapsOff then
        dev:performClickableAction(device_commands.BtnFlapsTakeOff, 0, false)
        dev:performClickableAction(device_commands.BtnFlapsCleared, 0, false)
        dev:performClickableAction(device_commands.BtnFlapsLanding, 0, false)
    end

    if command == Keys.PlaneFlaps then                                        --управление с клавиатуры
        if flap_keyboard == 0 then
            dev:performClickableAction(device_commands.BtnFlapsTakeOff, 1, false)
        elseif flap_keyboard == 1 then
            dev:performClickableAction(device_commands.BtnFlapsLanding, 1, false)
        elseif flap_keyboard == 2 then
            dev:performClickableAction(device_commands.BtnFlapsCleared, 1, false)
        end
    -- elseif command == Keys.PlaneFlapsDown then
    --     if flap_keyboard == 0 and fromkeyboard == false then
    --         dev:performClickableAction(device_commands.BtnFlapsTakeOff, 1, false)
    --     elseif flap_keyboard == 1 and fromkeyboard == false then
    --         dev:performClickableAction(device_commands.BtnFlapsLanding, 1, false)
        
    end
end

local flaps_increment = update_time_step / FlapExtensionTimeSeconds -- sets the speed of flap animation
function update()
    if get_hyd_utility_ok() then
        if MOVING == 1 then
        if math.abs(FLAPS_STATE - FLAPS_TARGET) < flaps_increment then
            FLAPS_STATE = FLAPS_TARGET
            elseif FLAPS_STATE < FLAPS_TARGET then
                FLAPS_STATE = FLAPS_STATE + flaps_increment
                -- print_message_to_user("FLAPS_STATE inc = " .. FLAPS_STATE)
            else
                FLAPS_STATE = FLAPS_STATE - flaps_increment
                -- print_message_to_user("FLAPS_STATE dec = " .. FLAPS_STATE)
        end
    elseif MOVING == -1 then
        if FLAPS_TARGET_LAST == 1 or FLAPS_TARGET_LAST == -1 then
           FLAPS_STATE = FLAPS_STATE - flaps_increment
        --    print_message_to_user("FLAPS_STATE dec MOV 0 = " .. FLAPS_STATE)
            

        end
    end

    end

    if FLAPS_STATE < 0 then
        -- print_message_to_user("FLAPS_STATE < 0 ")
        FLAPS_STATE = 0
        MOVING = 0
    elseif FLAPS_STATE > 1 then
        -- print_message_to_user("FLAPS_STATE > 1 ")
        FLAPS_STATE = 1
        
    end
    set_aircraft_draw_argument_value(9,FLAPS_STATE)
	set_aircraft_draw_argument_value(10,FLAPS_STATE)
end

need_to_be_closed = false