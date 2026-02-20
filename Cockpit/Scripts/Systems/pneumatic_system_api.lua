-- Protected API functions for Pneumatic System (MiG-23M)

local function get_p(name)
    local p = get_param_handle(name)
    return p:get() or 0
end

local function set_p(name, val)
    local p = get_param_handle(name)
    p:set(val)
end

function get_pneumo_main_press()
    return get_p("PNEUMO_MAIN_PRESS")
end

function get_pneumo_emer_press()
    return get_p("PNEUMO_EMER_PRESS")
end

function is_pneumo_main_ok()
    return get_pneumo_main_press() > 20
end

function is_pneumo_emer_ok()
    return get_pneumo_emer_press() > 20
end

function consume_main_air(amount)
    local current = get_p("PNEUMO_MAIN_CONSUMPTION")
    set_p("PNEUMO_MAIN_CONSUMPTION", current + amount)
end

function consume_emer_air(amount)
    local current = get_p("PNEUMO_EMER_CONSUMPTION")
    set_p("PNEUMO_EMER_CONSUMPTION", current + amount)
end
