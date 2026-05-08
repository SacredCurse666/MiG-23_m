local dev = GetSelf()

dofile(LockOn_Options.common_script_path.."devices_defs.lua")
dofile(LockOn_Options.script_path.."devices.lua")
dofile(LockOn_Options.script_path.."utils.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")
dofile(LockOn_Options.script_path.."Systems/pneumatic_system_api.lua")

local sensor_data = get_base_data()
local update_time_step = 0.02
make_default_activity(update_time_step)

local RADIANS_TO_DEGREES = 57.2958
local MPS_TO_KMH = 3.6

-- Handles
local uvp_drum = get_param_handle("UVP_DRUM")
local uvp_needle = get_param_handle("UVP_NEEDLE")

-- Калибровка стрелки
local UVP_NEEDLE_ZERO = 0.125 

-- Переменные для отслеживания состояния "надува"
local seal_inflated = false

----------------------------------------------------------------------------
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

function update()
    local alt = sensor_data.getBarometricAltitude() or 0
    local canopy_pos = get_aircraft_draw_argument_value(38) or 0
    
    -- ПРОВЕРКА ПНЕВМАТИКИ
    local main_pneumo_press = get_pneumo_main_press()
    local has_air_for_seal = main_pneumo_press > 30 -- Минимум 30 кгс для надува шланга
    
    local cabin_alt = alt
    local pressure_diff = 0
    local is_sealed = false
    
    -- Логика герметизации
    if canopy_pos < 0.05 then
        if has_air_for_seal then
            is_sealed = true
            -- Если только что закрыли и еще не списывали воздух
            if not seal_inflated then
                consume_main_air(0.5) -- Разовый расход на надув шланга
                seal_inflated = true
            end
        else
            -- Фонарь закрыт, но воздуха в системе нет -> шланг не надувается
            is_sealed = false
            seal_inflated = false
        end
    else
        -- Фонарь открыт -> воздух из шланга мгновенно выходит
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

    -- ОТЛАДКА
    -- print_message_to_user(string.format("PNEUMO: %.1f | SEALED: %s", main_pneumo_press, tostring(is_sealed)), 0.1)

    -- Обновление остальных систем
    get_param_handle("D_ALT_NEEDLE"):set(alt % 1000)
    get_param_handle("IAS"):set((sensor_data.getIndicatedAirSpeed() or 0) * MPS_TO_KMH)
    get_param_handle("KPP_1273K_pitch"):set((sensor_data.getPitch() or 0) * RADIANS_TO_DEGREES)
    get_param_handle("KPP_1273K_roll"):set((sensor_data.getRoll() or 0) * RADIANS_TO_DEGREES)
end

function post_initialize() end
function SetCommand(command, value) end
need_to_be_closed = false
