-- API functions to determine state of hydraulic system for MiG-23M
-- Consistent with dual system logic (GS1 and GS2) like in MiG-21bis

function get_hyd_flight_control_ok()
    return hyd_flight_control_ok:get() == 1
end

function get_hyd_utility_ok()
    return hyd_utility_ok:get() == 1
end

function get_hyd_brakes_ok()
    -- On MiG-23/21 brakes are usually pneumatic, but we keep this for compatibility
    return hyd_utility_ok:get() == 1
end

function get_hyd1_pressure()
    return hyd1_pressure:get()
end

function get_hyd2_pressure()
    return hyd2_pressure:get()
end

-- Handles for System 1 (Utility/Main)
hyd1_pressure = get_param_handle("MAIN_HYDRO_PRESS")
hyd_utility_ok = get_param_handle("HYD_UTILITY_OK")

-- Handles for System 2 (Booster/Flight Control)
hyd2_pressure = get_param_handle("BOOSTER_HYDRO_PRESS")
hyd_flight_control_ok = get_param_handle("HYD_FLIGHT_CONTROL_OK")
