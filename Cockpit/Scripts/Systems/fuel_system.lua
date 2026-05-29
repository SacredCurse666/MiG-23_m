dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")

local fuel_system = GetSelf()
local update_time_step = 0.1
make_default_activity(update_time_step)

local sensor_data = get_base_data()

-- Состояние тумблеров (0 - выкл, 1 - вкл)
local pump_tank1_pos = 0
local pump_tank3_pos = 0
local pump_expI_pos = 0
local pump_expII_pos = 0

-- Параметры для других систем (давление/статус)
local pump_tank1_ok = get_param_handle("FUEL_PUMP_TANK1_OK")
local pump_tank3_ok = get_param_handle("FUEL_PUMP_TANK3_OK")
local pump_expI_ok = get_param_handle("FUEL_PUMP_EXPI_OK")
local pump_expII_ok = get_param_handle("FUEL_PUMP_EXPII_OK")
local fuel_press_low = get_param_handle("FUEL_PRESSURE_LOW")

function post_initialize()
    local birth = LockOn_Options.init_conditions.birth_place
    if birth=="GROUND_HOT" or birth=="AIR_HOT" then
        pump_tank1_pos = 1
        pump_tank3_pos = 1
        pump_expI_pos = 1
        pump_expII_pos = 1
        
        -- Синхронизация тумблеров в кабине
        fuel_system:performClickableAction(device_commands.FuelPump_Tank1, 1, true)
        fuel_system:performClickableAction(device_commands.FuelPump_Tank3, 1, true)
        fuel_system:performClickableAction(device_commands.FuelPump_ExpI, 1, true)
        fuel_system:performClickableAction(device_commands.FuelPump_ExpII, 1, true)
    end
    
    set_aircraft_draw_argument_value(2008, pump_tank1_pos)
    set_aircraft_draw_argument_value(2009, pump_tank3_pos)
    set_aircraft_draw_argument_value(2010, pump_expI_pos)
    set_aircraft_draw_argument_value(2011, pump_expII_pos)
end

function update()
    local dc_ok = get_elec_primary_dc_ok()
    
    pump_tank1_ok:set((dc_ok and pump_tank1_pos > 0.5) and 1 or 0)
    pump_tank3_ok:set((dc_ok and pump_tank3_pos > 0.5) and 1 or 0)
    pump_expI_ok:set((dc_ok and pump_expI_pos > 0.5) and 1 or 0)
    pump_expII_ok:set((dc_ok and pump_expII_pos > 0.5) and 1 or 0)
    
    if (pump_expI_ok:get() == 0 and pump_expII_ok:get() == 0) then
        fuel_press_low:set(1)
    else
        fuel_press_low:set(0)
    end
end

function SetCommand(command, value)
    -- Отладочное сообщение для любого нажатия в топливной системе
    print_message_to_user(string.format("FUEL CMD: %d | Value: %.2f", command, value))

    if command == device_commands.FuelPump_Tank1 then
        pump_tank1_pos = value
        set_aircraft_draw_argument_value(2008, pump_tank1_pos)
        print_message_to_user("Насос бака 1: " .. (pump_tank1_pos > 0.5 and "ВКЛ" or "ВЫКЛ"))
    elseif command == device_commands.FuelPump_Tank3 then
        pump_tank3_pos = value
        set_aircraft_draw_argument_value(2009, pump_tank3_pos)
        print_message_to_user("Насос бака 3: " .. (pump_tank3_pos > 0.5 and "ВКЛ" or "ВЫКЛ"))
    elseif command == device_commands.FuelPump_ExpI then
        pump_expI_pos = value
        set_aircraft_draw_argument_value(2010, pump_expI_pos)
        print_message_to_user("Расходный насос I: " .. (pump_expI_pos > 0.5 and "ВКЛ" or "ВЫКЛ"))
    elseif command == device_commands.FuelPump_ExpII then
        pump_expII_pos = value
        set_aircraft_draw_argument_value(2011, pump_expII_pos)
        print_message_to_user("Расходный насос II: " .. (pump_expII_pos > 0.5 and "ВКЛ" or "ВЫКЛ"))
    end
end

fuel_system:listen_command(device_commands.FuelPump_Tank1)
fuel_system:listen_command(device_commands.FuelPump_Tank3)
fuel_system:listen_command(device_commands.FuelPump_ExpI)
fuel_system:listen_command(device_commands.FuelPump_ExpII)
