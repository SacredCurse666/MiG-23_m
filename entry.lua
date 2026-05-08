local self_ID="MiG-23m by Ugra_Media"

declare_plugin(self_ID,
{
installed 	 = true, -- if false that will be place holder , or advertising
dirName	  	 = current_mod_path,
displayName  = _("MiG-23m"),

fileMenuName = _("MiG-23m"),
update_id        = "MiG-23m",
version		 = "0.1.0",		 
state		 = "installed",
info		 = _("Тест выгрузка MiG-23m от Югра медиа."),
--binaries	 = bin,

Skins	= 
	{
		{
			name	= "MiG-23m",
			dir		= "Theme"
		},
	},
Missions =
	{
		{
			name		= _("MiG-23m"),
			dir			= "Missions",
			-- CLSID		= "{CLSID5456456346CLSID}",	
		},
	},	
LogBook =
	{
		{
			name		= _("MiG-23m"),
			type		= "MiG-23m",
		},
	},	
InputProfiles =
	{
		["MiG-23m"]     = current_mod_path .. '/Input',
	},
})

-- указание путей 3d моделей и текстур
mount_vfs_liveries_path (current_mod_path.."/Liveries")
mount_vfs_texture_path  (current_mod_path.."/Cockpit/Textures")
mount_vfs_texture_path  (current_mod_path.."/Textures")
mount_vfs_model_path    (current_mod_path.."/Shapes")
mount_vfs_model_path    (current_mod_path.."/Cockpit/Shapes")
mount_vfs_sound_path    (current_mod_path.."/Sounds")

make_flyable('MiG-23m',current_mod_path..'/Cockpit/Scripts/', nil, nil)


dofile(current_mod_path..'/MiG-23m.lua')
dofile(current_mod_path.."/Views.lua")

make_view_settings('MiG-23m', ViewSettings, SnapViews)



----------------------------------------------------------------------------------------
plugin_done()-- finish declaration , clear temporal data