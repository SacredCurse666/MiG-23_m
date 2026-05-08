local dev = GetSelf()
dofile(LockOn_Options.common_script_path.."devices_defs.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")
--dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")
dofile(LockOn_Options.script_path.."utils.lua")
--dofile(LockOn_Options.script_path.."sound_params.lua")

local clock_condition -- 0 = RUN= STOP/ 1 = STOP / 2 = STOP + OLD STOP
local clock_time_pause
local clock_time_start = 0
local local_time
local flight_clock_condition -- 0 = STOP/ 1 = RUN / 2 = PAUSE
local pause_time -- 0 = STOP/ 1 = RUN / 2 = PAUSE
local stopwatch_condition -- 0 = STOP/ 1 = RUN / 2 = PAUSE
local timer_time
local stopwatch_time
local stopwatch_pause_time
local clock_delta
 

local RADIANS_TO_DEGREES = 57.2958
local update_time_step = 0.05
local update_rate = 0.02
make_default_activity(update_rate)

local sensor_data = get_base_data()

local warning_altitude=500
--local gauge_altitude = ExsSmooth(0.15,prev_altitude)
local current_RALT = get_param_handle("D_RADAR_ALT")
local RALT_idx = get_param_handle("D_RADAR_IDX")
RALT_idx:set(warning_altitude)
local snd_inst_radar_altimeter_warning = get_param_handle("SND_INST_RADAR_ALTIMITER_WARNING")
local fuelgauge = get_param_handle("D_FUEL")
local RALT_warn = get_param_handle("D_RADAR_WARN")
RALT_warn:set(0)
local RALT_off = get_param_handle("D_RADAR_OFF")
RALT_off:set(0)
--local RALT_regulator = get_param_handle("D_RADAR_REGULATOR")

local adi_slip = get_param_handle("ADI_SLIP")
local adi_turn = get_param_handle("ADI_TURN")

local achs_ch = get_param_handle("ACHS_CH")
local achs_cm = get_param_handle("ACHS_CM")
local achs_cs = get_param_handle("ACHS_CS")
local achs_t_ch = get_param_handle("ACHS_T_CH")
local achs_t_cm = get_param_handle("ACHS_T_CM")
local achs_t_switch = get_param_handle("ACHS_T_SWITCH")
local achs_stp_cs = get_param_handle("ACHS_STOPWATCH")

--local fuel_warning = get_param_handle("FUEL_WARNING")


dev:listen_command(Keys.RadarAltWarningDown)
dev:listen_command(Keys.RadarAltWarningUp)

dev:listen_command(device_commands.warn_crown_twist)
dev:listen_command(device_commands.warn_crown_push)
dev:listen_command(device_commands.starter_twist)
dev:listen_command(device_commands.starter_push)


--dev:listen_command(device_commands.radar_altitude_warning_axis_slew)

local sec_time
local value_old=0
function SetCommand(command,value)
       
    local warning_delta = math.floor(warning_altitude/100 + 1) 

    if (command == Keys.RadarAltWarningDown) or (command == device_commands.warn_alt and value<0) then 
        --print_message_to_user ("warning_altitude " .. warning_altitude)
        warning_altitude = warning_altitude-warning_delta        
        if warning_altitude<=1 then warning_altitude = 1 end
    
        elseif (command == Keys.RadarAltWarningUp) or (command == device_commands.warn_alt and value>0) then
            --print_message_to_user ("warning_altitude" .. warning_altitude)
            warning_altitude=warning_altitude+warning_delta
            if warning_altitude>=1500 then warning_altitude = 1500 end
    end
    --print_message_to_user("command"  ..  command  .. "value" ..  value)
---------ACHS------------------------------
-------------CLOCK-------------------------
    if (command == device_commands.warn_crown_push and value == 1) then
        print_message_to_user ("warn_crown_push" .. value)
        if flight_clock_condition == 2 then
            flight_clock_condition = 0
            timer_time = 0
            achs_t_switch:set(0)
        else
                flight_clock_condition = flight_clock_condition + 1
                achs_t_switch:set(flight_clock_condition/2)  
        end
         print_message_to_user ("flight_clock_condition" .. flight_clock_condition)
    end
-------------STOP_CLOCK---------------------
    if (command == device_commands.warn_crown_twist) then
        if value<0 then
            clock_delta = clock_delta - 5
            else
                clock_delta = clock_delta + 5
        end
        print_message_to_user ("warn_crown_twist_value = " .. value .. " clock_delta = " .. clock_delta)
    end
    ---------TIMER--------------------------
    if (command == device_commands.starter_push and value == 1) then  ---and value == 1
        --print_message_to_user (" stopwatch_condition OLD = " .. stopwatch_condition)
        if stopwatch_condition == 2 then
            stopwatch_condition = 0
            pause_time = 0
        else
                stopwatch_condition = stopwatch_condition + 1
        end
        --print_message_to_user ("stopwatch_condition = " .. stopwatch_condition)
    end

    if (command == device_commands.starter_twist) then
        print_message_to_user ("starter_twist_value = " .. value)
        if value == 0 then
            clock_condition = 0
            clock_time_start = get_absolute_model_time() + clock_delta
        else
            clock_condition = 1
        end
    end
end


local second_handle_wma = WMA_wrap(0.4, 0, 0, 60)
function post_initialize()
    clock_condition = 0
    clock_time_pause = 0
    clock_delta = 0
    flight_clock_condition = 0
    timer_time = 0
    stopwatch_condition = 0
    pause_time = 0
    stopwatch_time = 0
    stopwatch_pause_time = 0

    local_time = get_absolute_model_time()
    local hours12 = local_time/3600.0
    if hours12>12.0 then
        hours12 = hours12 - 12.0
    end
    achs_ch:set(hours12)
    local int,frac = math.modf(hours12)
    achs_cm:set(frac*60)
    local int,frac_s = math.modf(frac*60.0)
    second_handle_wma:set_current_val(math.floor(frac_s*60))
    achs_cs:set(math.floor(frac_s*60))
    print_message_to_user (stopwatch_condition .. " post in") 
end
function stopwatch()
    --print_message_to_user ("stopwatch_condition" .. stopwatch_condition)
    local abstime_s = get_absolute_model_time()
    if (stopwatch_condition == 1 and stopwatch_time == 0) then
        stopwatch_time = get_absolute_model_time()
        --print_message_to_user (pause_time .. " pause_time_1_0 ")
        stopwatch_pause_time = 0
        achs_stp_cs:set(0)
    end

    if (stopwatch_condition == 1 and stopwatch_time ~= 0) then
            local tt_delta = abstime_s - stopwatch_time
            local hours12 = tt_delta/3600.0
        if hours12>12.0 then
            hours12 = hours12 - 12.0
        end
        local int,frac = math.modf(hours12)     
        local int,frac_s = math.modf(frac*60.0)
        achs_stp_cs:set(frac_s*60)
        stopwatch_pause_time = tt_delta
        --print_message_to_user (stopwatch_condition.. " 1" .. pause_time .. " pause_time_1_0 "    
    end

    if stopwatch_condition == 2 then
        local hours12 = stopwatch_pause_time/3600.0
        if hours12>12.0 then
            hours12 = hours12 - 12.0
        end
        local int,frac = math.modf(hours12)     
        local int,frac_s = math.modf(frac*60.0)
        achs_stp_cs:set(frac_s*60)
        --print_message_to_user (stopwatch_condition .. " 2" .. pause_time .. "pause_time_2")
    end
    if stopwatch_condition == 0 then
        stopwatch_pause_time = 0
        stopwatch_time = 0
        achs_stp_cs:set(0)
        --print_message_to_user (stopwatch_condition .. " stopwatch_condition_0")
    end
end
function clock()
    local abstime = get_absolute_model_time()
    if clock_condition == 0 then
        local_time = clock_time_pause + abstime - clock_time_start + clock_delta
    end
    --local local_time = abstime - clock_time_pause + clock_delta

    if clock_condition == 1 then
        clock_time_pause = local_time
        clock_condition = 2
        local_time = clock_time_pause 
    end
    if clock_condition == 2 then
        local_time = clock_time_pause 
    end

    local hours12 = local_time/3600.0
    if hours12>12.0 then
        hours12 = hours12 - 12.0
    end
    achs_ch:set(hours12)
    local int,frac = math.modf(hours12)
    achs_cm:set(frac*60)          
    local int,frac_s = math.modf(frac*60.0)
    achs_cs:set(second_handle_wma:get_WMA_wrap(math.floor(frac_s*60)))
    --print_message_to_user (clock_delta)

    if (flight_clock_condition == 1 and timer_time == 0) then
        timer_time = get_absolute_model_time()
        achs_t_cm:set(0)
        achs_t_ch:set(0)
        achs_t_switch:set(0.5)
        --print_message_to_user (timer_time .. "timer_time")
        pause_time = 0.1
        
    end
    if (flight_clock_condition == 1 and timer_time ~= 0) then
            local t_delta = abstime - timer_time
            local hours_t_12 = t_delta/3600.0
        if hours_t_12>12.0 then
            hours_t_12 = hours_t_12 - 12.0
        end
        achs_t_ch:set(hours_t_12)
        local int_t,frac_t = math.modf(hours_t_12)
        achs_t_cm:set(frac_t*60) 
        achs_t_switch:set(0.5)
        pause_time = t_delta

        --print_message_to_user (flight_clock_condition)    
    end
    if flight_clock_condition == 2 then
        achs_t_switch:set(1) 
        local hours_tp_12 = pause_time/3600.0
        if hours_tp_12>12.0 then
            hours_tp_12 = hours_tp_12 - 12.0
        end
        achs_t_ch:set(hours_tp_12)
        local frac_t = hours_tp_12 % 1
        achs_t_cm:set(frac_t*60) 
        achs_t_switch:set(1)
    end
    if flight_clock_condition == 0 then
        timer_time = 0
        pause_time = 0
        achs_t_cm:set(0)
        achs_t_ch:set(0)
        achs_t_switch:set(0)
        --print_message_to_user (flight_clock_condition)
    end

end


local standby_off_value = WMA(0.15, 0)
local standby_gauge = WMA(0.15, 0)
local adi_off_value = WMA(0.15, 0)
local adi_slip_value = WMA(0.30, 0)
local adi_turnrate_prev_heading = sensor_data.getMagneticHeading()*RADIANS_TO_DEGREES
local adi_turnrate_diff_time = 0.2 -- секунды, как часто вычислять скорость поворота
local adi_turnrate_time_step = 0
local adi_latest_turnrate = 0
local adi_turn_value = WMA(0.15, 0)

function update_attitude_gyros()

    local pitch = sensor_data.getPitch()*RADIANS_TO_DEGREES
    local roll = sensor_data.getRoll()*RADIANS_TO_DEGREES
    local heading = sensor_data.getMagneticHeading()*RADIANS_TO_DEGREES
    local slip = math.deg(sensor_data.getAngleOfSlide())/30  -- 30 - это примерное максимальное значение скольжения при полном нажатии на руль направления
    if slip>1 then
        slip=1
    elseif slip<-1 then
        slip=-1
    end
    -- !!! print_message_to_user(" pitch " .. pitch .. " roll " .. roll .. " heading " .. heading)
    --[[
    Индикаторы поворота и скольжения расположены под
    сферой и являются неотъемлемой частью авиагоризонта
    . Отклонение стрелки индикатора поворота на одну ширину
    приведет к стандартной скорости, 2-минутному,
    360-градусному развороту. Полное отклонение (две ширины стрелки)
    приводит к 1-минутному, 360-градусному развороту. Индикатор поворота
    имеет электрический привод и будет работать от
    аварийного генератора.
    --]]

    adi_turnrate_time_step = adi_turnrate_time_step + update_time_step
    if adi_turnrate_time_step >= adi_turnrate_diff_time then
        -- обновить скорость поворота
        local delta=heading - adi_turnrate_prev_heading
        if delta<-180 then
            delta=delta+360
        elseif delta>180 then
            delta=delta-360
        end
        adi_latest_turnrate=delta/adi_turnrate_time_step  -- градусов/секунду
        adi_latest_turnrate=adi_latest_turnrate/6 -- полное отклонение при 6 град/секунду
        if adi_latest_turnrate>1 then
            adi_latest_turnrate=1
        elseif adi_latest_turnrate<-1 then
            adi_latest_turnrate=-1
        end

        adi_turnrate_prev_heading = heading
        adi_turnrate_time_step=0
    end


    heading = ((heading+270) % 360)   -- Текстура ADI имеет W при "0" вращении, поэтому добавьте 270 градусов к фактическому
    --backup_compass:set((360 - heading) %360)


    adi_slip:set(adi_slip_value:get_WMA(slip))
    adi_turn:set(adi_turn_value:get_WMA(adi_latest_turnrate))
    --print_message_to_user(adi_slip_value:get_WMA(slip))
    --TODO нужно добавить смещения/калибровку гироскопа в какой-то момент

    -- attgyro_stby_pitch:set(-pitch)    -- от -90 до 90 градусов, вращение "вверх" указывает на подъем
    -- attgyro_stby_roll:set(roll)      -- от -180 до 180 градусов
end     


-- Vertical Velocity Indicator

vvi = get_param_handle("VVI")
local vvi_wma = WMA(0.025,0) 

function update_vvi()
    v = sensor_data.getVerticalVelocity()

    local max = 200    

    -- don't allow the VVI WMA to accumulate huge lag when flying at high angles
    if v > max then
        v = max
    elseif v < -max then
        v = -max
    end
    -- print_message_to_user("Hard VVI " .. v .. " Smooth VVI " .. vvi_wma:get_WMA(v))
    vvi:set(vvi_wma:get_WMA(v))
end


local bdhi_hdg = get_param_handle("BDHI_HDG")

function update_bdhi()
    local maghead = math.deg( sensor_data.getMagneticHeading() ) % 360
    bdhi_hdg:set(maghead)   -- outer ring of BDHI always operates as a magnetic compass
end

local air_speed = get_param_handle("AIR_SPD")
local air_spd_th = get_param_handle("AIR_SPD_THSND")
function air_spid()
    local air_spd = sensor_data.getIndicatedAirSpeed()*3.6
    air_speed:set(air_spd%1000)
    local air_th = math.floor(air_spd/1000)
    if air_th > 1 then
        air_th = 1
    end
    air_spd_th:set(air_th)
end

function update()  

    --update_fuel_gauge()
    update_attitude_gyros()
    update_vvi()
    update_bdhi()
    air_spid()
    clock()
    stopwatch()

    RALT_idx:set(warning_altitude)
    --print_message_to_user ("Update")

    --print_message_to_user (warning_altitude)
    local altitude_meters_old = current_RALT:get()
    local altitude_meters = sensor_data.getRadarAltitude()
    local altitude_meters_cor = altitude_meters  
    local valid_radar=true

    -- Проверка корректности работы радиоальтметра 
    if altitude_meters > 1500 then -- по высоте
        valid_radar = false
    end

    local abspitch=math.abs(sensor_data.getPitch())
    local absroll=math.abs(sensor_data.getRoll())
    if abspitch>(50*2.0*math.pi/360.0) then                 --по тангажу 50 градусов
        abspitch=(50*2.0*math.pi/360.0)
        valid_radar=false
    end
    if absroll>(30*2.0*math.pi/360.0) then                  --по крену 30 градусов
        absroll=(30*2.0*math.pi/360.0)
        valid_radar=false
    end


    if valid_radar == true then
        altitude_meters_cor =math.floor(altitude_meters_old - (altitude_meters_old - altitude_meters)/4)
        RALT_off:set(0)
    else
        altitude_meters_cor = math.floor(altitude_meters_old - (altitude_meters_old - 1500)/25)
        RALT_off:set(1)
        -- print_message_to_user (altitude_meters_cor)
    end


    current_RALT:set(altitude_meters_cor)
 -- Индикатор топлива
    local totalFuel = sensor_data.getTotalFuelWeight()

    fuelgauge:set(totalFuel)

 -- Индикатор критической высот альтиметра    
    -- print_message_to_user ("altitude_meters_core = ".. altitude_meters_cor .. " warning_altitude = ".. warning_altitude) --.." valid_radar = " .. valid_radar
    if altitude_meters_cor <= warning_altitude then
        RALT_warn:set(1)
        else
        RALT_warn:set(0)        
    end
--  -- Индикатор низкого уровня топлива
--     if totalFuel<= 600 then
--         fuel_warning:set(1)
--         --print_message_to_user (totalFuel)
--     else
--         fuel_warning:set(0)
--     end 
    -- local message1 = string.format("%d, %d, %d",altitude_meters_old, altitude_meters, altitude_meters_cor)
    -- print_message_to_user (message1)
    --print_message_to_user (RALT_idx:get())
end


need_to_be_closed = false