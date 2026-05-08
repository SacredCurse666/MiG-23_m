local dev = GetSelf()
dofile(LockOn_Options.common_script_path.."devices_defs.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")

--dofile(LockOn_Options.script_path.."utils.lua")

local update_time_step = 0.02
make_default_activity(update_time_step) -- enables call to update
local sensor_data = get_base_data()


function post_initialize()
 print_message_to_user("extern_load")
end

function SetCommand(command,value)

	if command == device_commands.BtnFlapsTakeOff then
        flap_current_state = 1
        print_message_to_user("flap_current_state = " .. flap_current_state)
	end

end
function update()
	--wing_angle = smooth_wing_des:get_WMA(wing_des/100)
	--print_message_to_user ("wing_angle_indicator = " .. wing_angle_indicator .. "des_wing_angle = " .. des_wing_angle)

	-- print_message_to_user ("wing_angle = " .. wing_angle)
	-- local WING_ROTATION = sensor_data:get
	-- set_aircraft_draw_argument_value(11, ROLL_STATE)

	local ROLL_STATE = sensor_data:getStickPitchPosition() / 100
	set_aircraft_draw_argument_value(11, ROLL_STATE) -- right aileron
	set_aircraft_draw_argument_value(12, -ROLL_STATE) -- left aileron
	

	local PITCH_STATE = sensor_data:getStickRollPosition() / 100
	set_aircraft_draw_argument_value(15, PITCH_STATE) -- right elevator
	set_aircraft_draw_argument_value(16, PITCH_STATE) -- left elevator

	local RUDDER_STATE = sensor_data:getRudderPosition() / 100
	set_aircraft_draw_argument_value(17, RUDDER_STATE)
	
	-- if get_elec_retraction_release_ground() then
    --     set_aircraft_draw_argument_value(2, -RUDDER_STATE*0.333) -- limit visual nosewheel deflection to 30 degrees
    -- else
    --     set_aircraft_draw_argument_value(2, 0)  -- otherwise center it
    -- end

    -- local pitch_trim_handle = get_param_handle("PITCH_TRIM")
    -- local pitch_trim = pitch_trim_handle:get() -- from -0.24 (1deg down) to 1.0 (13 deg up)
    -- if pitch_trim>=0 then
    --     set_aircraft_draw_argument_value(117, pitch_trim)
    -- elseif pitch_trim<0 then
    --     set_aircraft_draw_argument_value(117, (1.0/0.24)*pitch_trim)
    -- end
    
	--print_message_to_user (ROLL_STATE)
	--print_message_to_user (PITCH_STATE)
	--print_message_to_user (PITCH_TRIM)
	
end

need_to_be_closed = false -- close lua state after initialization
