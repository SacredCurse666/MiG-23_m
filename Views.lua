-- для того, чтобы изменения заработали, нужно перезагружать всю игру
ViewSettings = {
	Cockpit = {
	[1] = {-- player slot 1
		CameraViewAngleLimits  = {20.0, 140.0}, -- FOV Mini Maxi
		CockpitLocalPoint      = {3.796, 0.578,  0.0},  --соответствует мировым координатам (x,z,y) 3ds max Cockpit= forward/backward, up/down, left/right (П.С почему-то координата Y в дкс инвертированная от координаты Y в 3ds max
		CameraAngleRestriction = {false, 90.0, 0.4},
		CameraAngleLimits      = {200.0, -90.0, 90.0}, -- max view angle left/right, max view down, max view up
		EyePoint               = {0.1, 0.1, 0.0}, --не до конца понятно что это конкретно
		ShoulderSize           = 0.25,
		Allow360rotation       = false,
		limits_6DOF            = {
			x    = {-0.05,0.30}, -- movement back/front
			y    = {-0.3,0.1},   -- movement up/down
			z    = {-0.17,0.17}, -- movement left/right
			roll = 90.000000
		}
		},
	}, -- Cockpit 

	Chase = { -- F4 view
		LocalPoint      = {-8.0,3.0,-4.0}, -- {left/right, up/down, front/back}
		AnglesDefault   = {-60.000000,-30.000000},
	}, -- Chase 

	Arcade = { -- аркадный режим, наверное F3
		LocalPoint      = {-20.000000,5.000000,0.000000},
		AnglesDefault   = {0.000000,-8.000000},
	}, -- Arcade 

}

SnapViews = {
[1] = {-- player slot 1
	[1] = { --LWin + Num0 : Прикрепить вид 0
		viewAngle = 70.611748,--FOV
		hAngle    = -1.240272,
		vAngle    = 0.850250,
		x_trans   = 0.164295,
		y_trans   = -0.074373,
		z_trans   = 0.000000,
		rollAngle = 0.000000,
	},

	[2] = { --LWin + Num1 : Прикрепить вид 1
		viewAngle = 32.704346,--FOV
		hAngle    = 25.696522,
		vAngle    = -34.778103,
		x_trans   = 0.264295,
		y_trans   = -0.064373,
		z_trans   = 0.000000,
		rollAngle = 0.000000,
	},

	[3] = { --LWin + Num2 : Прикрепить вид 2
		viewAngle = 32.704346,--FOV
		hAngle    = 0.000000,
		vAngle    = -47.845268,
		x_trans   = 0.264295,
		y_trans   = -0.064373,
		z_trans   = 0.000000,
		rollAngle = 0.000000,
	},

	[4] = { --LWin + Num3 : Прикрепить вид 3
		viewAngle = 36.106045,--FOV
		hAngle    = -28.878576,
		vAngle    = -36.780628,
		x_trans   = 0.264295,
		y_trans   = -0.064373,
		z_trans   = 0.000000,
		rollAngle = 0.000000,
	},

	[5] = { --LWin + Num4 : Прикрепить вид 4
		viewAngle = 88.727844,--FOV
		hAngle    = 128.508865,
		vAngle    = 13.131046,
		x_trans   = 0.264295,
		y_trans   = -0.064373,
		z_trans   = 0.000000,
		rollAngle = 0.000000,
	},

	[6] = { --LWin + Num5 : Прикрепить вид 5
		viewAngle = 41.928593,--FOV
		hAngle    = 0.000000,
		vAngle    = -4.630446,
		x_trans   = 0.264295,
		y_trans   = -0.064373,
		z_trans   = 0.000000,
		rollAngle = 0.000000,
	},

	[7] = { --LWin + Num6 : Прикрепить вид 6
		viewAngle = 88.727844,--FOV
		hAngle    = -128.508865,
		vAngle    = 13.131046,
		x_trans   = 0.264295,
		y_trans   = -0.064373,
		z_trans   = 0.000000,
		rollAngle = 0.000000,
	},

	[8] = { --LWin + Num7 : Прикрепить вид 7
		viewAngle = 88.727844,--FOV
		hAngle    = 81.648369,
		vAngle    = -9.500000,
		x_trans   = 0.264295,
		y_trans   = -0.064373,
		z_trans   = 0.000000,
		rollAngle = 0.000000,
	},

	[9] = { --LWin + Num8 : Прикрепить вид 8
		viewAngle = 88.727844,--FOV
		hAngle    = 0.000000,
		vAngle    = 34.180634,
		x_trans   = 0.264295,
		y_trans   = -0.064373,
		z_trans   = 0.000000,
		rollAngle = 0.000000,
	},

	[10] = { --LWin + Num9 : Прикрепить вид 9
		viewAngle = 88.727844,--FOV
		hAngle    = -80.997551,
		vAngle    = -9.500000,
		x_trans   = 0.264295,
		y_trans   = -0.064373,
		z_trans   = 0.000000,
		rollAngle = 0.000000,
	},

	[11] = { --посмотрите в левое зеркало
		viewAngle = 85.0,--FOV
		hAngle    = 18.0,
		vAngle    = 3.3,
		x_trans   = 0.2,
		y_trans   = 0.1,
		z_trans   = 0.0,
		rollAngle = 0.0,
	},

	[12] = { --посмотрите в правое зеркало
		viewAngle = 85.0,--FOV
		hAngle    = -18.0,
		vAngle    = 3.3,
		x_trans   = 0.2,
		y_trans   = 0.1,
		z_trans   = 0.0,
		rollAngle = 0.0,
	},

	[13] = { -- вид по умолчанию
		viewAngle  = 75.000000,
		hAngle     = 0.000000,
		vAngle     = -13.000000,
		x_trans    = -0,
		y_trans    = -0.0106,
		z_trans    = 0.000000,
		rollAngle  = 0.000000,
	},

	[14] = { -- VR HMD View
		viewAngle  = 75.000000,
		hAngle     = 0.000000,
		vAngle     = -13.000000,
		x_trans    = 0.05,
		y_trans    = -0.0106,
		z_trans    = 0.000000,
		rollAngle  = 0.000000,
	},
},
}
