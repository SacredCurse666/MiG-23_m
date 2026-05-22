-- MiG-23M Avionics & Life Support (FULLY RESTORED & MERGED)
local dev = GetSelf()

-- Подключение библиотек и API
dofile(LockOn_Options.common_script_path.."devices_defs.lua")
dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.script_path.."utils.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")
dofile(LockOn_Options.script_path.."Systems/pneumatic_system_api.lua") -- API Пневматики для УВП-15

local sensor_data = get_base_data()
local update_time_step = 0.01 -- 100 Hz
make_default_activity(update_time_step)

local RADIANS_TO_DEGREES = 57.2958
local MPS_TO_KMH = 3.6

-- --- ХЕНДЛЫ ОСВЕЩЕНИЯ ---
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
local inst_lights_warmup_time = 1.5
local inst_lights_max_brightness_multiplier = 0
local inst_lights_are_cold = true
local intlight_instruments_moving = 0

local console_lights_first_on_time = 0
local console_lights_warmup_time = 2
local console_lights_max_brightness_multiplier = 0
local console_lights_are_cold = true
local intlight_console_moving = 0

local red_floodlights_first_on_time = 0
local red_floodlights_warmup_time = 2.8
local red_floodlights_max_brightness_multiplier = 0
local red_floodlights_are_cold = true

local white_floodlights_first_on_time = 0
local white_floodlights_warmup_time = 2.8
local white_floodlights_max_brightness_multiplier = 0
local white_floodlights_are_cold = true
local intlight_whiteflood_moving = 0

-- --- ХЕНДЛЫ ВЫСОТОМЕРА ---
local ALT_PRESSURE_MAX = 799.0
local ALT_PRESSURE_MIN = 600.0
local ALT_PRESSURE_STD = 760.0

local alt_setting = ALT_PRESSURE_STD
local alt_pressure_moving = 0

local alt_needle = get_param_handle("D_ALT_NEEDLE")
local alt_adj_Nxxx = get_param_handle("ALT_ADJ_Nxxx")
local alt_adj_xNxx = get_param_handle("ALT_ADJ_xNxx")
local alt_adj_xxNx = get_param_handle("ALT_ADJ_xxNx")
local alt_adj_xxxN = get_param_handle("ALT_ADJ_xxxN")

local overall_pitch = 0
local pitch_max = 10
local pitch_min = -10

-- --- ХЕНДЛЫ АВИАГОРИЗОНТА (КПП) ---
local kpp_pitch = get_param_handle("KPP_1273K_pitch")
local kpp_roll = get_param_handle("KPP_1273K_roll")
local kpp_sideslip = get_param_handle("KPP_1273K_sideslip")
local kpp_stby_horiz = get_param_handle("KPP_1273K_stby_horiz")

local standby_val = 0.0

-- --- ХЕНДЛЫ СКОРОСТИ ---
local ias_needle = get_param_handle("IAS")
local mach_needle = get_param_handle("MACH")
local tas_needle = get_param_handle("TAS")

-- --- ХЕНДЛЫ УВП-15 (НОВЫЕ) ---
local uvp_drum = get_param_handle("UVP_DRUM")
local uvp_needle = get_param_handle("UVP_NEEDLE")
local UVP_NEEDLE_ZERO = 0.125
local seal_inflated = false

-- --- СГЛАЖИВАНИЕ АВИАГОРИЗОНТА (WMA) ---
-- Вспомогательная функция WMA
local function WMA(weight, val)
    local last_val = val or 0
    return function(new_val)
        last_val = last_val + (new_val - last_val) * weight
        return last_val
    end
end

local standby_off_value = WMA(0.15, 0)
local standby_gauge = WMA(0.15, 0)
local kpp_off_value = WMA(0.15, 0)
local kpp_slip_value = WMA(0.30, 0)
local kpp_turnrate_prev_heading = sensor_data.getMagneticHeading() * RADIANS_TO_DEGREES
local kpp_turnrate_diff_time = 0.2
local kpp_turnrate_time_step = 0
local kpp_latest_turnrate = 0
local kpp_turn_value = WMA(0.15, 0)

-- Регистрация слушателей команд
alt_needle:set(0.0)
dev:listen_command(Keys.AltPressureInc)
dev:listen_command(Keys.AltPressureDec)
dev:listen_command(device_commands.test)
dev:listen_command(device_commands.kpp_correct)
dev:listen_command(device_commands.intlight_whiteflood)
dev:listen_command(device_commands.intlight_instruments)
dev:listen_command(device_commands.intlight_console)
dev:listen_command(device_commands.intlight_brightness)

function post_initialize() end

function SetCommand(command, value)
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

-- --- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ---
function lighting_warmup(lights_on_duration, lights_warmup_time)
    return (math.atan( 20 * (lights_on_duration / lights_warmup_time))) / 1.52
end

local function get_pressure_at_alt(alt_meters)
    local P0 = 1.0332
    local a = math.max(0, alt_meters)
    return P0 * math.pow((1 - 0.0000225577 * a), 5.25588)
end

local function get_alt_from_pressure(pressure_kg)
    local P0 = 1.0332
    if pressure_kg <= 0.11 then return 15000 end
    return (1 - math.pow((pressure_kg / P0), (1/5.25588))) / 0.0000225577
end

-- --- ОБНОВЛЕНИЕ ПРИБОРОВ ---

function update_ias_mach()
    local ias = sensor_data.getIndicatedAirSpeed() * MPS_TO_KMH
    ias_needle:set(ias % 10000)
end

function update_int_lights()
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

        local inst_lights_on_duration = get_model_time() - inst_lights_first_on_time
        if inst_lights_on_duration < inst_lights_warmup_time then
            inst_lights_max_brightness_multiplier = lighting_warmup(inst_lights_on_duration, inst_lights_warmup_time)
        end

        local console_lights_on_duration = get_model_time() - console_lights_first_on_time
        if console_lights_on_duration < console_lights_warmup_time then
            console_lights_max_brightness_multiplier = lighting_warmup(console_lights_on_duration, console_lights_warmup_time)
        end

        local red_floodlights_on_duration = get_model_time() - red_floodlights_first_on_time
        if red_floodlights_on_duration < red_floodlights_warmup_time then
            red_floodlights_max_brightness_multiplier = lighting_warmup(red_floodlights_on_duration, red_floodlights_warmup_time)
        end

        lights_int_instruments:set(lights_instruments_val * inst_lights_max_brightness_multiplier)
        lights_int_console:set(lights_console_val * console_lights_max_brightness_multiplier)

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
    
    if get_elec_fwd_mon_ac_ok() then
        if white_floodlights_are_cold and (lights_floodwhite_val > 0) then
            white_floodlights_first_on_time = get_model_time()
            white_floodlights_are_cold = false
        end

        local white_floodlights_on_duration = get_model_time() - white_floodlights_first_on_time
        if white_floodlights_on_duration < white_floodlights_warmup_time then
            white_floodlights_max_brightness_multiplier = lighting_warmup(white_floodlights_on_duration, white_floodlights_warmup_time)
        end

        lights_int_floodwhite:set(lights_floodwhite_val * white_floodlights_max_brightness_multiplier)
    else
        lights_int_floodwhite:set(0)
    end
end

function update_altimeter()
    local alt = sensor_data.getBarometricAltitude()
   
    local altNxxx = math.floor(alt_setting)
    local altxNxx = math.floor(alt_setting/10) % 10
    local altxxNx = math.floor(alt_setting) % 10
    local altxxxN = math.floor(alt_setting*10) % 10

    alt_adj_Nxxx:set(altNxxx)
    alt_adj_xNxx:set(altxNxx)
    alt_adj_xxNx:set(altxxNx)
    alt_adj_xxxN:set(altxxxN)

    local alt_adj = (alt_setting - ALT_PRESSURE_STD)*1000   
    alt_needle:set(alt % 1000)
end

function update_kpp()
    local pitch = (sensor_data.getPitch() * RADIANS_TO_DEGREES) + overall_pitch
    local roll = sensor_data.getRoll() * RADIANS_TO_DEGREES
    local heading = sensor_data.getMagneticHeading() * RADIANS_TO_DEGREES
    local slip = math.deg(sensor_data.getAngleOfSlide()) / 18.5
    if slip > 1 then
        slip = 1
    elseif slip < -1 then
        slip = -1
    end

    kpp_turnrate_time_step = kpp_turnrate_time_step + update_time_step
    if kpp_turnrate_time_step >= kpp_turnrate_diff_time then
        local delta = heading - kpp_turnrate_prev_heading
        if delta < -180 then
            delta=delta + 360
        elseif delta > 180 then
            delta = delta - 360
        end
        kpp_latest_turnrate = delta/kpp_turnrate_time_step
        kpp_latest_turnrate = kpp_latest_turnrate/6
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
    kpp_sideslip:set(kpp_slip_value:get_WMA(slip))
end

-- --- ЛОГИКА ПРИБОРА УВП-15 (ГЕРМЕТИЗАЦИЯ) ---
function update_uvp()
    local alt = sensor_data.getBarometricAltitude() or 0
    local canopy_pos = get_aircraft_draw_argument_value(38) or 0
    
    -- Проверка давления в пневмосистеме через API
    local main_pneumo_press = get_pneumo_main_press()
    local has_air_for_seal = main_pneumo_press > 30 -- Минимум 30 кгс
    
    local cabin_alt = alt
    local pressure_diff = 0
    local is_sealed = false
    
    -- Алгоритм герметизации шланга фонаря
    if canopy_pos < 0.05 then
        if has_air_for_seal then
            is_sealed = true
            if not seal_inflated then
                consume_main_air(0.5) -- Разовый расход воздуха на надув
                seal_inflated = true
            end
        else
            is_sealed = false
            seal_inflated = false
        end
    else
        is_sealed = false
        seal_inflated = false
    end

    -- Расчет давления внутри
    if is_sealed then
        if alt <= 2000 then
            cabin_alt = alt
            pressure_diff = 0
        elseif alt <= 7000 then
            cabin_alt = 2000
            pressure_diff = get_pressure_at_alt(2000) - get_pressure_at_alt(alt)
        else
            pressure_diff = 0.3
            local p_cabin = get_pressure_at_alt(alt) + pressure_diff
            cabin_alt = get_alt_from_pressure(p_cabin)
        end
    else
        cabin_alt = alt
        pressure_diff = 0
    end
    
    -- Вывод на приборы
    local drum_arg = cabin_alt / 20000
    local needle_arg = UVP_NEEDLE_ZERO + (pressure_diff / 0.6) * (1.0 - UVP_NEEDLE_ZERO)
    
    uvp_drum:set(math.max(0, math.min(1.0, drum_arg)))
    uvp_needle:set(math.max(0, math.min(1.0, needle_arg)))
end

-- --- ГЛАВНЫЙ ЦИКЛ ОБНОВЛЕНИЯ ---
function update()
    update_altimeter()
    update_kpp()
    update_ias_mach()
    update_int_lights()
    update_uvp() 
end

need_to_be_closed = false
