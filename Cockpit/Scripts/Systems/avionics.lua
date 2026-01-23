local dev = GetSelf()

dofile(LockOn_Options.common_script_path.."devices_defs.lua")
dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.script_path.."utils.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")

-- require(common_scripts.."devices_defs")
-- require("devices")
-- require("command_defs")
-- require("utils")
-- require("Systems.air_data_computer")

local sensor_data = get_base_data()
local update_time_step = 0.01
make_default_activity(update_time_step)--update will be called 20 times per second

local RADIANS_TO_DEGREES = 57.2958
local MPS_TO_KMH = 3.6

local lights_int_floodwhite = get_param_handle("LIGHTS-FLOOD-WHITE")
local lights_int_floodred = get_param_handle("LIGHTS-FLOOD-RED")
local lights_int_instruments = get_param_handle("LIGHTS-INST")
local lights_int_console = get_param_handle("LIGHTS-CONSOLE")

local FLOODRED_DIM = 0.2
local FLOODRED_MED = 0.35
local FLOODRED_BRIGHT = 0.48

local lights_floodwhite_val = 0
local lights_floodred_val = FLOODRED_DIM
local lights_instruments_val = 0
local lights_console_val = 0

local inst_lights_first_on_time = 0
local inst_lights_warmup_time = 1.5 -- time it takes for the incandescent light bulbs to warm up
local inst_lights_max_brightness_multiplier = 0
local inst_lights_are_cold = true
local intlight_instruments_moving = 0

local console_lights_first_on_time = 0
local console_lights_warmup_time = 2 -- time it takes for the incandescent light bulbs to warm up
local console_lights_max_brightness_multiplier = 0
local console_lights_are_cold = true
local intlight_console_moving = 0

local red_floodlights_first_on_time = 0
local red_floodlights_warmup_time = 2.8 -- time it takes for the incandescent light bulbs to warm up
local red_floodlights_max_brightness_multiplier = 0
local red_floodlights_are_cold = true

local white_floodlights_first_on_time = 0
local white_floodlights_warmup_time = 2.8 -- time it takes for the incandescent light bulbs to warm up
local white_floodlights_max_brightness_multiplier = 0
local white_floodlights_are_cold = true
local intlight_whiteflood_moving = 0

----------------------------------------------------------------------------
-- барометрический высотомер (прибор #)

local ALT_PRESSURE_MAX = 799.0 -- мм.рт.столба
local ALT_PRESSURE_MIN = 600.0 -- мм.рт.столба
local ALT_PRESSURE_STD = 760.0 -- мм.рт.столба

local alt_setting = ALT_PRESSURE_STD
local alt_pressure_moving = 0

local alt_needle = get_param_handle("D_ALT_NEEDLE") -- 0 to 1000
-- local alt_10k = get_param_handle("D_ALT_10K") -- 0 to 100,000
-- local alt_1k = get_param_handle("D_ALT_1K") -- 0 to 10,000
-- local alt_100s = get_param_handle("D_ALT_100S") -- 0 to 1000
-- local alt_adj_NNxx = get_param_handle("ALT_ADJ_Nxx") -- первая цифра рт.столба
-- local alt_adj_xxNx = get_param_handle("ALT_ADJ_xNx") -- вторая цифра рт.столба
-- local alt_adj_xxxN = get_param_handle("ALT_ADJ_xxN") -- третья цифра рт.столба

local alt_adj_Nxxx = get_param_handle("ALT_ADJ_Nxxx") -- 1 цифра рт.столба
local alt_adj_xNxx = get_param_handle("ALT_ADJ_xNxx") -- 2 цифра рт.столба
local alt_adj_xxNx = get_param_handle("ALT_ADJ_xxNx") -- 3 цифра рт.столба
local alt_adj_xxxN = get_param_handle("ALT_ADJ_xxxN") -- 4 цифра

local overall_pitch = 0
local pitch_max = 10
local pitch_min = -10
----------------------------------------------------------------------------
-- авиагоризонт (прибор #)
local kpp_pitch = get_param_handle("KPP_1273K_pitch")
local kpp_roll = get_param_handle("KPP_1273K_roll")
local kpp_sideslip = get_param_handle("KPP_1273K_sideslip") -- шарик
local kpp_stby_horiz = get_param_handle("KPP_1273K_stby_horiz") -- регулировка 

local standby_val = 0.0

----------------------------------------------------------------------------
-- приборная скорость
local ias_needle = get_param_handle("IAS")
local mach_needle = get_param_handle("MACH")
local tas_needle = get_param_handle("TAS")
----------------------------------------------------------------------------

alt_needle:set(0.0)
dev:listen_command(Keys.AltPressureInc)
dev:listen_command(Keys.AltPressureDec)
dev:listen_command(device_commands.test)
dev:listen_command(device_commands.kpp_correct)
dev:listen_command(device_commands.intlight_whiteflood)
dev:listen_command(device_commands.intlight_instruments)
dev:listen_command(device_commands.intlight_console)
dev:listen_command(device_commands.intlight_brightness)

function post_initialize()
end
function SetCommand(command,value)

    print_message_to_user("Command: ".. command .. " Value: ".. value)

    if command == Keys.AltPressureInc then
        alt_setting = alt_setting + 0.001
        if alt_setting >= ALT_PRESSURE_MAX then
            alt_setting = ALT_PRESSURE_MAX
        end

    elseif command == Keys.AltPressureDec then
        alt_setting = alt_setting - 0.001
        if alt_setting <= ALT_PRESSURE_MIN then
            alt_setting = ALT_PRESSURE_MIN
        end
    
    elseif command == device_commands.kpp_correct then
        overall_pitch = overall_pitch + value
        if overall_pitch >= pitch_max then 
            overall_pitch = pitch_max
        elseif overall_pitch <= pitch_min then
            overall_pitch = pitch_min
        end
    elseif command == device_commands.intlight_instruments then
        lights_instruments_val = value
    elseif command == device_commands.intlight_console then
        lights_console_val = value
    elseif command == device_commands.intlight_brightness then
        local x = value
        if x == 1.0 then
            lights_floodred_val = FLOODRED_BRIGHT
        elseif x == 0 then
            lights_floodred_val = FLOODRED_DIM
        elseif x == -1 then
            lights_floodred_val = FLOODRED_MED
        end
    elseif command == device_commands.intlight_whiteflood then
        lights_floodwhite_val = value
    end
end

function lighting_warmup(lights_on_duration, lights_warmup_time)
    return (math.atan( 20 * (lights_on_duration / lights_warmup_time))) / 1.52
end

function update_ias_mach()
    local ias = sensor_data.getIndicatedAirSpeed()*MPS_TO_KMH
    local mach = 0
        
--print_message_to_user("Needle:".. ias)
    ias_needle:set(ias % 10000)

    -- -- if ias < 1000 then
    -- --     set_aircraft_draw_argument_value (101, 0)
    -- if ias >= 1000 then
    --     set_aircraft_draw_argument_value (101, ias)
    -- end
    
end
function update_int_lights()
    -- red floodlights, console, and instrument lighting are powered by the primary dc bus
    if get_elec_primary_ac_ok() then
        if inst_lights_are_cold and (lights_instruments_val > 0) then
            inst_lights_first_on_time = get_model_time()
            inst_lights_are_cold = false
        end

        if console_lights_are_cold and (lights_console_val > 0) then
            console_lights_first_on_time = get_model_time()
            red_floodlights_first_on_time = get_model_time()
            console_lights_are_cold = false
        end

        -- lights power on effect
        local inst_lights_on_duration = get_model_time() - inst_lights_first_on_time
        if inst_lights_on_duration < inst_lights_warmup_time then
            inst_lights_max_brightness_multiplier = lighting_warmup(inst_lights_on_duration, inst_lights_warmup_time)
        else
            -- inst_lights_max_brightness_multiplier = 1
        end

        local console_lights_on_duration = get_model_time() - console_lights_first_on_time
        if console_lights_on_duration < console_lights_warmup_time then
            console_lights_max_brightness_multiplier = lighting_warmup(console_lights_on_duration, console_lights_warmup_time)
        else
            -- console_lights_max_brightness_multiplier = 1
        end

        local red_floodlights_on_duration = get_model_time() - red_floodlights_first_on_time
        if red_floodlights_on_duration < red_floodlights_warmup_time then
            red_floodlights_max_brightness_multiplier = lighting_warmup(red_floodlights_on_duration, red_floodlights_warmup_time)
        else
            -- red_floodlights_max_brightness_multiplier = 1
        end

        lights_int_instruments:set(lights_instruments_val * inst_lights_max_brightness_multiplier)
        lights_int_console:set(lights_console_val * console_lights_max_brightness_multiplier)

        -- red floods are conditional upon console knob enabled
        if lights_console_val > 0 then
            lights_int_floodred:set(lights_floodred_val * red_floodlights_max_brightness_multiplier)
        else
            if get_cockpit_draw_argument_value(114) > 0 then
                lights_int_floodred:set(0)
            end
        end
    else
        lights_int_instruments:set(0)
        lights_int_console:set(0)
        lights_int_floodred:set(0)
    end
    
    -- white floodlights are powered by the forward monitors ac bus
    if get_elec_fwd_mon_ac_ok() then
        if white_floodlights_are_cold and (lights_floodwhite_val > 0) then
            white_floodlights_first_on_time = get_model_time()
            white_floodlights_are_cold = false
        end

        local white_floodlights_on_duration = get_model_time() - white_floodlights_first_on_time
        if white_floodlights_on_duration < white_floodlights_warmup_time then
            white_floodlights_max_brightness_multiplier = lighting_warmup(white_floodlights_on_duration, white_floodlights_warmup_time)
        else
            -- white_floodlights_max_brightness_multiplier = 1
        end

        lights_int_floodwhite:set(lights_floodwhite_val * white_floodlights_max_brightness_multiplier)
    else
        lights_int_floodwhite:set(0)
    end
end
function update_altimeter() --логика барометрического высотомера
    
    local alt = sensor_data.getBarometricAltitude()
   
    local altNxxx = math.floor(alt_setting)         -- пока просто сделай это дискретным
    local altxNxx = math.floor(alt_setting/10) % 10
    local altxxNx = math.floor(alt_setting) % 10
    local altxxxN = math.floor(alt_setting*10) % 10

    -- Сначала обновите отображаемое значение выбранного значения настройки
    alt_adj_Nxxx:set(altNxxx)
    alt_adj_xNxx:set(altxNxx)
    alt_adj_xxNx:set(altxxNx)
    alt_adj_xxxN:set(altxxxN)

    -- На основе настройки отрегулируйте отображаемая высота
    local alt_adj = (alt_setting - ALT_PRESSURE_STD)*1000   
    
    -- alt_10k:set(alt % 100000)
    -- alt_1k:set(alt % 10000)
    -- alt_100s:set(alt % 1000)
    alt_needle:set(alt % 1000)

    --print_message_to_user("alt_needle: ".. alt % 10)

    --непрерывное движение барабаном
    if alt_pressure_moving ~= 0 then
        alt_setting = clamp(alt_setting + 0.005 * alt_pressure_moving, ALT_PRESSURE_MIN, ALT_PRESSURE_MAX)
    end
end
------------------------------------------------
--kpp

local standby_off_value = WMA(0.15, 0)
local standby_gauge = WMA(0.15, 0)
local kpp_off_value = WMA(0.15, 0)
local kpp_slip_value = WMA(0.30, 0)
local kpp_turnrate_prev_heading=sensor_data.getMagneticHeading()*RADIANS_TO_DEGREES
local kpp_turnrate_diff_time=0.2 -- секунды, как часто вычислять скорость разворота
local kpp_turnrate_time_step=0
local kpp_latest_turnrate=0
local kpp_turn_value = WMA(0.15, 0)

function update_kpp() --логика
    --local standby_off_target=0
    -- if not get_elec_primary_ac_ok() then  -- TODO : учесть резервный гироскоп
    --     standby_off_target=1
    -- end
    --attgyro_stby_off:set(standby_off_value:get_WMA(standby_off_target))
    -- local adi_off_target=0
    -- if not get_elec_primary_ac_ok() or not get_elec_primary_dc_ok() then  -- TODO: учесть гироскоп

    --adi_off_target=0
    -- end
    --adi_off:set(adi_off_value:get_WMA(adi_off_target))
    --print_message_to_user("adi_off: ".. adi_off)
    --kpp_stby_horiz:set(standby_gauge:get_WMA(standby_val))
    local pitch = (sensor_data.getPitch() * RADIANS_TO_DEGREES) + overall_pitch
    local roll = sensor_data.getRoll() * RADIANS_TO_DEGREES
    local heading = sensor_data.getMagneticHeading() * RADIANS_TO_DEGREES
    local slip = math.deg(sensor_data.getAngleOfSlide()) / 18.5  -- 18.5 - это примерное максимальное значение скольжения при полном нажатии на педаль
    if slip > 1 then
        slip = 1
    elseif slip < -1 then
        slip = -1
    end

    kpp_turnrate_time_step = kpp_turnrate_time_step + update_time_step
    if kpp_turnrate_time_step >= kpp_turnrate_diff_time then
        -- обновить скорость разворота
        local delta = heading - kpp_turnrate_prev_heading
        if delta < -180 then
            delta=delta + 360
        elseif delta > 180 then
            delta = delta - 360
        end
        kpp_latest_turnrate = delta/kpp_turnrate_time_step  -- градусов/секунду
        kpp_latest_turnrate = kpp_latest_turnrate/6 -- полное отклонение при 6 град/секунду
        if kpp_latest_turnrate > 1 then
            kpp_latest_turnrate = 1
        elseif kpp_latest_turnrate < -1 then
            kpp_latest_turnrate = -1
        end

        kpp_turnrate_prev_heading = heading
        kpp_turnrate_time_step = 0
    end


    kpp_pitch:set(pitch)  
    kpp_roll:set(roll)
    --adi_hdg:set(heading)
    kpp_sideslip:set(kpp_slip_value:get_WMA(slip))
    --adi_turn:set(adi_turn_value:get_WMA(adi_latest_turnrate))

    --TODO нужно добавить смещения/калибровку гироскопа в какой-то момент

end

function update()
    update_altimeter()
    update_kpp()
    update_ias_mach()
    update_int_lights()
    

    local ias_1k = ias_needle:get()
    if ias_1k > 1000 then
        --set_cockpit_draw_argument_value (101, 1)
    end
    
end
need_to_be_closed = false -- close lua state after initialization


-- getAngleOfAttack
-- getAngleOfSlide
-- getBarometricAltitude
-- getCanopyPos
-- getCanopyState
-- getEngineLeftFuelConsumption --
-- getEngineLeftRPM
-- getEngineLeftTemperatureBeforeTurbine
-- getEngineRightFuelConsumption
-- getEngineRightRPM
-- getEngineRightTemperatureBeforeTurbine
-- getFlapsPos
-- getFlapsRetracted
-- getHeading
-- getHelicopterCollective
-- getHelicopterCorrection
-- getHorizontalAcceleration
-- getIndicatedAirSpeed
-- getLandingGearHandlePos
-- getLateralAcceleration
-- getLeftMainLandingGearDown
-- getLeftMainLandingGearUp
-- getMachNumber
-- getMagneticHeading
-- getNoseLandingGearDown
-- getNoseLandingGearUp
-- getPitch
-- getRadarAltitude
-- getRateOfPitch
-- getRateOfRoll
-- getRateOfYaw
-- getRightMainLandingGearDown
-- getRightMainLandingGearUp
-- getRoll
-- getRudderPosition
-- getSelfAirspeed
-- getSelfCoordinates
-- getSelfVelocity
-- getSpeedBrakePos
-- getStickPitchPosition
-- getStickRollPosition
-- getThrottleLeftPosition
-- getThrottleRightPosition
-- getTotalFuelWeight  
-- getTrueAirSpeed
-- getVerticalAcceleration
-- getVerticalVelocity
-- getWOW_LeftMainLandingGear
-- getWOW_NoseLandingGear
-- getWOW_RightMainLandingGear



