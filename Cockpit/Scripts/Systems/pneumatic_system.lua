-- MiG-23M Pneumatic System (Final Calibrated)
local dev = GetSelf()
make_default_activity(0.02) -- 50 Hz

local sensor_data = get_base_data()

local main_tank = 200 
local emer_tank = 240

local cur_131 = 0
local cur_132 = 0
local cur_133 = 0
local cur_134 = 0

function post_initialize()
    print_message_to_user("PNEUMATIC SYSTEM: READY")
end

function update()
    local rpm = 0
    if sensor_data.getEngineLeftRPM then rpm = (sensor_data.getEngineLeftRPM() or 0) end
    if rpm < 1.1 then rpm = rpm * 100 end
    
    -- Получаем тормоза более надежно
    local bl = sensor_data.getLeftWheelBrake() or 0
    local br = sensor_data.getRightWheelBrake() or 0
    -- Если тормоза по умолчанию 1.0, значит они инвертированы в DCS.
    -- Простейшая логика - берем тормоза только при нажатии.
    local brake_in = math.max(bl, br)
    
    local rud = 0
    if sensor_data.getRudderPosition then rud = (sensor_data.getRudderPosition() or 0) end

    -- Зарядка
    if rpm > 40 then main_tank = math.min(240, main_tank + 0.1) end
    if brake_in > 0.1 then main_tank = math.max(0, main_tank - 0.05) end

    -- Редукторы 0-16
    local target_131 = math.min(13.0, main_tank)
    local target_line_emer = math.min(14.0, emer_tank)
    
    -- МВ-12 (0-12)
    local factor_l = 1.0 - math.max(0, rud) 
    local factor_r = 1.0 - math.max(0, -rud)
    local target_133 = target_131 * 0.77 * brake_in * factor_l
    local target_134 = target_131 * 0.77 * brake_in * factor_r

    -- Инерция
    local f = 0.15
    cur_131 = cur_131 + (target_131 - cur_131) * f
    cur_132 = cur_132 + (target_line_emer - cur_132) * f
    cur_133 = cur_133 + (target_133 - cur_133) * f
    cur_134 = cur_134 + (target_134 - cur_134) * f

    -- Запись
    get_param_handle("PNEUMO_MAIN_PRESS"):set(main_tank)
    get_param_handle("PNEUMO_EMER_PRESS"):set(emer_tank)
    get_param_handle("PNEUMO_LINE_MAIN"):set(cur_131)
    get_param_handle("PNEUMO_LINE_EMER"):set(cur_132) -- Для инвертированной стрелки
    get_param_handle("PNEUMO_BRAKE_L"):set(cur_133)
    get_param_handle("PNEUMO_BRAKE_R"):set(cur_134)
end
