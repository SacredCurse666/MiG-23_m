local dev = GetSelf()

local update_time_step = 0.05
make_default_activity(update_time_step)

local sensor_data = get_base_data()

-- Parameter handle for the EGT gauge
local EGT_param = get_param_handle("MIG23_EGT")

function update()
    -- Read EGT from the EFM
    local EGT_value = sensor_data:getEngineLeftTemperatureBeforeTurbine()
    
    -- Set the value to the parameter
    EGT_param:set(EGT_value)
end

need_to_be_closed = false