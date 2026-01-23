local dev = GetSelf()
dofile(LockOn_Options.common_script_path.."devices_defs.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")

--dofile(LockOn_Options.script_path.."utils.lua")

local update_time_step = 0.02
make_default_activity(update_time_step) -- enables call to update

local sensor_data = get_base_data()
local wing_angle
local wing_des -- desired wing angle [0,25,50,75,100]
local temp_des_wing_agle 
dev:listen_command(Keys.IncreasWingAngle)
dev:listen_command(Keys.ReducWingAngle)
dev:listen_command(Keys.WingStop)
dev:listen_command(device_commands.wing_angle)
dev:listen_command(device_commands.BtnFlapsTakeOff)

--local wing_angle_indicator = get_param_handle("WING_ANGLE_INDICATOR")	-- 451
-- local des_wing_angle = get_param_handle("DES_WING_ANGLE") -- 452
local wing_angle_indicator = get_param_handle("WING_ANGLE_INDICATOR")
local des_wing_angle = get_param_handle("DES_WING_ANGLE")
local angle_max_lim_mah = get_param_handle("ANGLE_MAX_LIM_MAH")
local angle_max_lim_speed = get_param_handle("ANGLE_MAX_LIM_SPEED")

function post_initialize()
    print_message_to_user ("wing loaded")
	wing_angle = 0
	wing_des = 0
	temp_des_wing_agle = 0
	set_aircraft_draw_argument_value(7, 0)
	--set_aircraft_draw_argument_value(501, 0)
end

function SetCommand(command,value)
	--print_message_to_user (command)
	if (command == Keys.IncreasWingAngle) then
		dev:performClickableAction(device_commands.wing_angle, (wing_desure_increment()/1000), false)
		print_message_to_user ("device_commands.wing_angle "..value .. " wing_des ".. wing_des)
	elseif command == Keys.ReducWingAngle then
		dev:performClickableAction(device_commands.wing_angle, (wing_desure_decrement()/1000), false)
		print_message_to_user ("device_commands.wing_angle "..value .. " wing_des ".. wing_des)
	end
	-- if wing_des > 1000 then
	-- 	wing_des = 1000
	-- elseif wing_des < 0 then
	-- 	wing_des = 0
	-- end
	--dev:performClickableAction(device_commands.wing_angle, wing_des/1000,false)
	if command == device_commands.wing_angle then
		wing_des = value*1000
		print_message_to_user ("device_commands.wing_angle "..value .. " wing_des ".. wing_des)

	end
	--des_wing_angle:set(wing_des)
	-- dev:performClickableAction(device_commands.wing_angle, wing_des/1000,false)
	-- print_message_to_user ("wing_des = " .. wing_des)
end
function wing_desure_increment()
	wing_des = wing_des + 250
	if wing_des > 1000 then
		wing_des = 1000
	elseif wing_des < 0 then
		wing_des = 0
	end
	return wing_des
end
function wing_desure_decrement()
	wing_des = wing_des - 250
	if wing_des > 1000 then
		wing_des = 1000
	elseif wing_des < 0 then
		wing_des = 0
	end
	return wing_des
end


function update()
	--print_message_to_user ("wing_angle_indicator = " .. wing_angle_indicator .. "des_wing_angle = " .. des_wing_angle)

	if wing_angle < wing_des then
		wing_angle = wing_angle + 1
		elseif wing_angle > wing_des then
			wing_angle = wing_angle - 1
	end

	if temp_des_wing_agle  < wing_des then
		temp_des_wing_agle  = temp_des_wing_agle  + 10
		elseif temp_des_wing_agle  > wing_des then
			temp_des_wing_agle  = temp_des_wing_agle - 10
	end
 
	--print_message_to_user ("temp_des_wing_agle = " .. temp_des_wing_agle .. "wing_angle = " .. wing_angle)
	angle_max_lim_mah:set(temp_des_wing_agle)
	angle_max_lim_speed:set(temp_des_wing_agle)
	wing_angle_indicator:set(wing_angle)
	des_wing_angle:set(temp_des_wing_agle)
 	-- print_message_to_user ("wing_angle = " .. wing_angle .. "wing_des = " .. wing_des)

	if wing_angle ~= wing_des then
		set_aircraft_draw_argument_value(7, wing_angle/1000)
		--print_message_to_user ("temp_des_wing_agle = " .. temp_des_wing_agle .. "wing_angle = " .. wing_angle.. " wing_des = ".. wing_des)
	end
end
need_to_be_closed = false