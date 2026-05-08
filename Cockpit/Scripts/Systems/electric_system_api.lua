-- API functions to determine state of electric system
-- To use, add this near the top of your system file:
-- dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")

function get_elec_primary_ac_ok()
    return elec_primary_ac_ok:get()==1 and true or false
end

function get_elec_primary_dc_ok()
    return elec_primary_dc_ok:get()==1 and true or false
end

function get_elec_ac_36v_ok()
    return elec_ac_36v_ok:get()==1 and true or false
end

-- Основные параметры состояния шин
elec_primary_ac_ok=get_param_handle("ELEC_PRIMARY_AC_OK") -- 1 or 0
elec_primary_dc_ok=get_param_handle("ELEC_PRIMARY_DC_OK") -- 1 or 0
elec_ac_36v_ok=get_param_handle("ELEC_AC_36V_OK") -- 1 or 0
elec_external_power=get_param_handle("ELEC_EXTERNAL_POWER") -- 1 or 0

-- Пока оставим минимальный набор, расширим при необходимости
