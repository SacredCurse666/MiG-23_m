MiG_23m =  {
        
	Name 				=   'MiG-23m',
	DisplayName			= _('MiG-23m'),
	ViewSettings        = ViewSettings,
	
	HumanCockpit 		= false,
	HumanCockpitPath    = current_mod_path..'/Cockpit/',
	
	Picture 			= "../../../../../Mods/aircraft/MiG-23m/MiG-23m.png",
	Rate 				= 40, -- RewardPoint in Multiplayer
	Shape 				= "MiG-23m",
	
	shape_table_data 	= 
	{
		{
			file  	 = 'MiG-23m';
			life  	 = 18; -- lifebar
			vis   	 = 3; -- visibility gain.
			desrt    = 'MiG-23m_destr'; -- Name of destroyed object file name
			fire  	 = { 300, 2}; -- Fire on the ground after destoyed: 300sec 2m
			username = 'MiG-23m';
			index    =  WSTYPE_PLACEHOLDER;
			classname   = "lLandPlane";
            positioning = "BYNORMAL";
		},
	--	{
	--		name  = "MiG-23m_destr";
	--		file  = "MiG-23m_destr";
	--		fire  = { 240, 2};
	--	},

	net_animation ={
        0, -- front gear
        3, -- right gear
        5, -- left gear
        9, -- right flap
        10, -- left flap
        11, -- right aileron
        12, -- left aileron
        15, -- right elevator
        16, -- left elevator
        17, -- rudder

        2,  -- nose wheel steering
        21, -- SFM air brake
        13, -- right slat
        14, -- left slat
        25, -- tail hook
        38, -- canopy
        120, -- right spoiler
        123, -- left spoiler
        190, -- left (red) navigation wing-tip light
        191, -- right (green) navigation wing-tip light
        192, -- tail (white) light

        198, -- anticollision (flashing red) top light
        199, -- anticollision (flashing red) bottom light
        208, -- taxi light (white) right main gear door
        402, -- huffer
        500, -- model air brake
        501, -- RAT
        499, -- wheel chocks
         117, -- stabilizer
    },
	},
	mapclasskey 		= "P0091000025",
	attribute  			= {wsType_Air, wsType_Airplane, wsType_Fighter, WSTYPE_PLACEHOLDER ,"Battleplanes",},
	Categories 			= {"{78EFB7A2-FD52-4b57-A6A6-3BF0E1D6555F}", "Interceptor",},	
	-------------------------
	M_empty 					= 11000, -- kg
	M_nominal 					= 15200, -- kg ~ %50 fuel, combat load
	M_max 						= 18900, -- kg
	M_fuel_max 					= 4500, -- kg --2225
	H_max 					 	= 17000, -- m
	average_fuel_consumption 	= 0.4244, -- this is highly relative, but good estimates are 36-40l/min = 28-31kg/min = 0.47-0.52kg/s -- 45l/min = 35kg/min = 0.583kg/s
	CAS_min 					= 76, -- if this is not OVERAL FLIGHT TIME, but jus LOITER TIME, than it sholud be 10-15 minutes.....CAS capability in minute (for AI)
	V_opt 						= 210, -- cruise m/s (for AI) M0.8 @ 20,000 ft
	V_take_off 					= 84, -- Take off speed in m/s (for AI) ~ 190 kts
	V_land 						= 80, -- Land speed in m/s (for AI) ~ 220 kts
	V_max_sea_level 			= 375, -- Max speed at sea level in m/s (for AI) ~ 1.2 Mach
	V_max_h 					= 523.61, -- Max speed at max altitude in m/s (for AI) ~ 2.2 Mach @ 36000' = 1262 kts = 649 m / s
	Vy_max 						= 200, -- Max climb speed in m/s (for AI) ~ 400 kts TAS @ 10000'
	Mach_max 					= 1.7, -- Max speed in Mach (for AI)
	Ny_min 						= -2, -- Min G (for AI)
	Ny_max 						= 5.9,  -- Max G (for AI)
	Ny_max_e 					= 6.5,  -- Max G (for AI)
	AOA_take_off 				= 0.16, -- AoA in take off (for AI)
	bank_angle_max 				= 60, -- Max bank angle (for AI)

	has_afteburner 				= true, -- AFB yes/no
	has_speedbrake 				= true, -- Speedbrake yes/no
	has_differential_stabilizer = true,
	nose_gear_pos 				= { 5.599148, -2.497651, 0}, -- nosegear coord 
	main_gear_pos 				= {-2.832159, -2.450034, 1.687489}, -- main gear coords 
	nose_gear_wheel_diameter 	= 0.541, -- in m
	main_gear_wheel_diameter 	= 0.86, -- in m
	--nose_gear_amortizer_direct_stroke        =  0,  -- down from nose_gear_pos !!!
	--nose_gear_amortizer_reversal_stroke      = -0.366912,  -- up 
	--main_gear_amortizer_direct_stroke	     =  0, --  down from main_gear_pos !!!
	--main_gear_amortizer_reversal_stroke      = -0.433269, --  up 
	--nose_gear_amortizer_normal_weight_stroke = -0.075,-- down from nose_gear_pos
	--main_gear_amortizer_normal_weight_stroke = -0.15, -- down from main_gear_pos
	
	tand_gear_max 				= 0.577, -- +/- 25 degrees
	wing_area 					= 55.17, -- wing area in m2
	wing_span 					= 17.64, -- wing spain in m
	wing_type 					= VARIABLE_GEOMETRY,	-- тип крыла изменяемая стреловидность
	thrust_sum_max 				= 8000, -- thrust in kg (52.9 kN)
	thrust_sum_ab 				= 11500, -- thrust inkg (79.3 kN)
	length 						= 16.7, -- full lenght in m
	height 						= 5.64, -- height in m
	flaps_maneuver 				= 1, -- Max flaps in take-off and maneuver (0.5 = 1st stage; 1.0 = 2nd stage) (for AI)
	range 						= 1950, -- Max range in km (for AI)
	RCS 						= 5, -- Radar Cross Section m2
	IR_emission_coeff 			= 0.69, -- Normal engine -- IR_emission_coeff = 1 is Su-27 without afterburner. It is reference.
	IR_emission_coeff_ab 		= 1.3, -- With afterburner
	wing_tip_pos 				=  {-2.466,	0.115, 7.107}, -- wingtip coords for visual effects

	brakeshute_name 			= 4, -- 	
	is_tanker 					= false, -- Tanker yes/no
	air_refuel_receptacle_pos 	= {7.610, 1.225, 0,035}, -- координаты заправляемого разъема
	engines_count				= 1, -- Engines count
	engines_nozzles = 
		{
			[1] = 
			{
				pos = 	{-7.292,	-0.248,	0},
				elevation	=	0,
				diameter	=	1.178,
				exhaust_length_ab	=	8.631,
				exhaust_length_ab_K	=	0.76,
				smokiness_level     = 	0.3, --хз что это, возможно это эффект дыма от двигателя
			}, -- end of [1]
		}, -- end of engines_nozzles
	crew_size	 = 1,
	crew_members = 
		{
			[1] = 
			{
				drop_canopy_name	 = "MiG-23m_canopy",
				ejection_seat_name	 = 17,
				pos = 	{3.5, 0,  0}, --используется для определения местоположения катапультирование
				can_be_playable 	 = true,
				canopy_arg           = 38, 
				ejection_order 		 = 1,
				canopy_pos			 = {1.5, 0.798, 0},
				ejection_added_speed = {-5,15,0},
			},-- end of [1]
		},-- end of crew_members			
		fires_pos = 
		{
			[1] = 	{-2.117,	-0.9,	0},
			[2] = 	{-1.584,	0.176,	2.693},
			[3] = 	{-1.645,	0.213,	-2.182},
			[4] = 	{-0.82,	0.265,	2.774},
			[5] = 	{-0.82,	0.265,	-2.774},
			[6] = 	{-0.82,	0.255,	4.274},
			[7] = 	{-0.82,	0.255,	-4.274},
			[8] = 	{-6.548,	-0.248,	0},
			[9] = 	{-6.548,	-0.248,	0},
			[10] = 	{0.304,	-0.748,	0.442},
			[11] = 	{0.304,	-0.748,	-0.442},
		}, -- end of fires_pos
	
	
	-- Countermeasures
	Countermeasures = {
    	ECM = "Siren SPS-141"
    	},
    SingleChargeTotal = 120,
    CMDS_Incrementation = 30,
    ChaffDefault = 60, -- PPR-26
    ChaffChargeSize = 1,
    FlareDefault = 60, -- PPI-26
    FlareChargeSize = 1,
    CMDS_Edit = true,
	chaff_flare_dispenser 	= {
		[1] = 
		{
			dir =  {-1,0,0},	-- dispenses to rear
			pos =  {-6, 0, -0.8},	-- left rear of fuselage
		}, -- end of [1]
	}, -- end of chaff_flare_dispenser

	--sensors
	
	detection_range_max		 = 0,
	radar_can_see_ground 	 = false, -- this should be examined (what is this exactly?)
    CanopyGeometry = {
        azimuth = {-130.0, 130.0},
        elevation = {-40.0, 90.0}
    },
    Sensors = {
        OPTIC = "Kaira-1",
        RWR = "Abstract RWR"
    },
	HumanRadio = {
		frequency = 251.0,  -- Radio Freq
		editable = true,
		minFrequency = 225.000,
		maxFrequency = 399.975,
		modulation = MODULATION_AM
	},
	
	
	Guns = {gun_mount("M_61", { count = 725 }, 
							  { muzzle_pos_connector = "GUN_POINT", muzzle_pos = {6.103, -0.496, -0.406}, elevation_initial = 2.000}
					 )
		   },
			--положение и вооружение на пилонах
	Pylons =     {
		-- center of left wing tip
        pylon(1, 0, -0.513, -0.355, -3.398,
            {
				use_full_connector_position=true,
            },
            {
				{ CLSID = "{9BFD8C90-F7AE-4e90-833B-BFD0CED0E536}" }, --    AIM-9P
            }
        ),
		-- left wing pylon
        pylon(2, 0, -0.128, -0.571, -1.95,
            {
				use_full_connector_position=true,
            },
            {
				{ CLSID = "{BCE4E030-38E9-423E-98ED-24BE3DA87C32}" }, -- "Mk-82"
				{ CLSID = "{7A44FF09-527C-4B7E-B42B-3F111CFE50FB}" }, -- "Mk-83"
				{ CLSID = "{FD90A1DC-9147-49FA-BF56-CB83EF0BD32B}"}, -- LAU-61 2.75x19 (closest LAU-3 equiv)
            }
        ),
		-- fuselage ventral
        pylon(3, 1, -0.555000, -0.884000, 0,
            {
				use_full_connector_position=true,
            },
            {
				{ CLSID = "{BCE4E030-38E9-423E-98ED-24BE3DA87C32}" }, -- "Mk-82"
				{ CLSID = "{7A44FF09-527C-4B7E-B42B-3F111CFE50FB}" }, -- "Mk-83"
                { CLSID = "{AB8B8299-F1CC-4359-89B5-2172E0CF4A5A}" }, -- Mk-84
            }
        ),
		-- right wing pylon
		pylon(4, 0, -0.128, -0.571, 1.95,
            {
				use_full_connector_position=true,
			},
            {
				{ CLSID = "{BCE4E030-38E9-423E-98ED-24BE3DA87C32}" }, -- "Mk-82"
				{ CLSID = "{7A44FF09-527C-4B7E-B42B-3F111CFE50FB}" }, -- "Mk-83"
				{ CLSID = "{FD90A1DC-9147-49FA-BF56-CB83EF0BD32B}"}, -- LAU-61 2.75x19 (closest LAU-3 equiv)
            }
		),
		-- right wing tip
		pylon(5, 0, -0.514, -0.355, 3.398,
            {
				use_full_connector_position=true,
			},
            {
				{ CLSID = "{9BFD8C90-F7AE-4e90-833B-BFD0CED0E536}" }, --    AIM-9P
            }
		),
    },
	
	Tasks = {
        aircraft_task(GroundAttack),
        --aircraft_task(RunwayAttack),
        --aircraft_task(PinpointStrike),
        --aircraft_task(CAS),
        --aircraft_task(AFAC),
		--aircraft_task(CAP),
        --aircraft_task(Escort),
        aircraft_task(FighterSweep),
        aircraft_task(Intercept),
    },	
	DefaultTask = aircraft_task(Intercept),

	SFM_Data = {
		aerodynamics = -- Cx = Cx_0 + Cy^2*B2 +Cy^4*B4
		{
			Cy0			=	0,      -- zero AoA lift coefficient
			Mzalfa		=	4.355, -- 4.355,	-- tail pitch coefficient M0.9
			Mzalfadt	=	0.8, -- 0.8,	-- wing pitch coefficient M0.9
			kjx			=	2.75,	-- roll acceleration rate in rad/sec
			kjz			=	0.00125, -- 0.0011, -- elevator or stab control power coefficient / pitch damping coefficient
			Czbe		=	-0.016,  -- directional stability coefficient, along Z axis (perpendicular), affects yaw, negative value means force orientation in FC coordinate system
			cx_gear		=	0.032,  -- coefficient, drag, gear
			cx_flap		=	0.035,  -- coefficient, drag, full flaps
			cy_flap		=	0.24,   -- coefficient, normal force, lift, flaps
			cx_brk		=	0.06,  -- coefficient, drag, breaks
			table_data  = 
			{	--      M		Cx0		 Cya	B		B4	    Omxmax		Aldop		Cymax
				[1] = 	{0,		0.024,	0.07,	0.075,	0.12,	0.5,		30,			1.2},
				[2] = 	{0.2,	0.024,	0.07,	0.075,	0.12,	1.5,		30,			1.2},
				[3] = 	{0.4,	0.024,	0.07,	0.075,	0.12,	2.5,		30,			1.2},
				[4] = 	{0.6,	0.0239,	0.073,	0.075,	0.12,	3.5,		30,			1.2},
				[5] = 	{0.7,	0.024,	0.076,	0.075,	0.12,	3.5,		28.666666666667,	1.18},
				[6] = 	{0.8,	0.0235,	0.079,	0.075,	0.12,	3.5,		27.333333333333,	1.16},
				[7] = 	{0.9,	0.025,	0.083,	0.075,	0.125,	3.5,		26,			1.14},
				[8] = 	{1,		0.044,	0.085,	0.14,	0.1,	3.5,		24.666666666667,	1.12},
				[9] = 	{1.05,	0.0465,	0.0855,	0.1775,	0.125,	3.5,		24,			1.11},
				[10] = 	{1.1,	0.049,	0.086,	0.215,	0.15,	3.15,		18,			1.1},
				[11] = 	{1.2,	0.049,	0.083,	0.228,	0.17,	2.45,		17,			1.05},
				[12] = 	{1.3,	0.049,	0.077,	0.237,	0.2,	1.75,		16,			1},
				[13] = 	{1.5,	0.0475,	0.062,	0.251,	0.2,	1.5,		13,			0.9},
				[14] = 	{1.7,	0.045166666666667,	0.051333333333333,	0.24366666666667,	0.32,	0.9,	12,	0.7},
				[15] = 	{1.8,	0.044,	0.046,	0.24,	0.38,	0.86,		11.4,		0.64},
				[16] = 	{2,		0.043,	0.039,	0.222,	2.5,	0.78,		10.2,		0.52},
				[17] = 	{2.2,	0.041,	0.034,	0.227,	3.2,	0.7,		9,			0.4},
				[18] = 	{2.5,	0.04,	0.033,	0.25,	4.5,	0.7,		9,			0.4},
				[19] = 	{3.9,	0.035,	0.033,	0.35,	6,		0.7,		9,			0.4},
			}, -- end of table_data
			-- M - Mach number
			-- Cx0 - Coefficient, drag, profile, of the airplane
			-- Cya - Normal force coefficient of the wing and body of the aircraft in the normal direction to that of flight. Inversely proportional to the available G-loading at any Mach value. (lower the Cya value, higher G available) per 1 degree AOA
			-- B - Polar quad coeff
			-- B4 - Polar 4th power coeff
			-- Omxmax - roll rate, rad/s
			-- Aldop - Alfadop Max AOA at current M - departure threshold
			-- Cymax - Coefficient, lift, maximum possible (ignores other calculations if current Cy > Cymax)
		}, -- end of aerodynamics
		engine = 
		{
			Nmg		=	60.00001, -- RPM at idle
			MinRUD	=	0, -- Min state of the throttle
			MaxRUD	=	1, -- Max state of the throttle
			MaksRUD	=	0.85, -- Military power state of the throttle
			ForsRUD	=	0.91, -- Afterburner state of the throttle
			typeng	=	0,
			
			--[[
				E_TURBOJET = 0
				E_TURBOJET_AB = 1
				E_PISTON = 2
				E_TURBOPROP = 3
				E_TURBOFAN	= 4
				E_TURBOSHAFT = 5
			--]]
			
			hMaxEng	=	19, -- Max altitude for safe engine operation in km
			dcx_eng	=	0.0144, -- Engine drag coeficient
			cemax	=	1.24, -- not used for fuel calulation , only for AI routines to check flight time ( fuel calculation algorithm is built in )
			cefor	=	2.56, -- not used for fuel calulation , only for AI routines to check flight time ( fuel calculation algorithm is built in )
			dpdh_m	=	4500, --  altitude coefficient for max thrust
			dpdh_f	=	9800,  --  altitude coefficient for AB thrust
			table_data = 
			{			
				[1] = 	{0,		65660,	141000},
				[2] = 	{0.2,	80000,	143000},
				[3] = 	{0.4,	79000,	150000},
				[4] = 	{0.6,	82000,	165000},
				[5] = 	{0.7,	90000,	177000},
				[6] = 	{0.8,	94000,	193000},
				[7] = 	{0.9,	96000,	200000},
				[8] = 	{1,		100000,	205000},
				[9] = 	{1.1,	100000,	214000},
				[10] = 	{1.2,	98000,	222000},
				[11] = 	{1.3,	100000,	235000},
				[12] = 	{1.5,	98000,	258000},
				[13] = 	{1.8,	94000,	276000},
				[14] = 	{2,		88000,	283000},
				[15] = 	{2.2,	82000,	285000},
				[16] = 	{2.5,	80000,	287000},
				[17] = 	{3.9,	50000,	200000},
			}, -- end of table_data
			-- M - Mach number
			-- Pmax - Engine thrust at military power
			-- Pfor - Engine thrust at AFB
		}, -- end of engine
	},
	Damage = {
				[0]		= {critical_damage = 5, args = {146}},
				[3]		= {critical_damage = 20,args = {65}}  ,
				[4]		= {critical_damage = 20, args = {150}},
				[5]		= {critical_damage = 20, args = {147}},
				[7]		= {critical_damage = 4, args = {249}} ,
				[9]		= {critical_damage = 3, args = {154}},
				[10]	= {critical_damage = 3, args = {153}},
				[11]	= {critical_damage = 3, args = {167}},
				[12]	= {critical_damage = 3, args = {161}},
				[15]	= {critical_damage = 5, args = {267}},
				[16]	= {critical_damage = 5, args = {266}},
				[23]	= {critical_damage = 8, args = {223}, deps_cells = {25}},
				[24]	= {critical_damage = 8, args = {213}, deps_cells = {26, 60}},
				[25]	= {critical_damage = 3, args = {226}},
				[26]	= {critical_damage = 3, args = {216}},
				[29]	= {critical_damage = 9, args = {224}, deps_cells = {31, 25, 23}},
				[30]	= {critical_damage = 9, args = {214}, deps_cells = {32, 26, 24, 60}},
				[31]	= {critical_damage = 4, args = {229}},
				[32]	= {critical_damage = 4, args = {219}},
				[35]	= {critical_damage = 10, args = {225}, deps_cells = {29, 31, 25, 23}},
				[36]	= {critical_damage = 10, args = {215}, deps_cells = {30, 32, 26, 24, 60}} ,
				[37]	= {critical_damage = 4, args = {227}},
				[38]	= {critical_damage = 4, args = {217}},
				[39]	= {critical_damage = 7,	args = {244}, deps_cells = {53}},
				[40]	= {critical_damage = 7, args = {241}, deps_cells = {54}},
				[45]	= {critical_damage = 9, args = {235}, deps_cells = {39, 51, 53}},
				[46]	= {critical_damage = 9, args = {233}, deps_cells = {40, 52, 54}},
				[51]	= {critical_damage = 3, args = {239}},
				[52]	= {critical_damage = 3, args = {237}},
				[53]	= {critical_damage = 3, args = {248}},
				[54]	= {critical_damage = 3, args = {247}},
				[55]	= {critical_damage = 20, args = {81}, deps_cells = {39, 40, 45, 46, 51, 52, 53, 54}},
				[59]	= {critical_damage = 5, args = {148}},
				[60]	= {critical_damage = 1, args = {144}},

				[83]	= {critical_damage = 3, args = {134}} ,-- nose wheel
				[84]	= {critical_damage = 3, args = {136}}, -- left wheel
				[85]	= {critical_damage = 3, args = {135}} ,-- right wheel
	},
	
	DamageParts = 
	{  
--DAMAGEOFF		[1] = "F-104T-part-wing-R", -- wing R
--DAMAGEOFF		[2] = "F-104T-part-wing-L", -- wing L
--DAMAGEOFF		[3] = "F-104T-part-nose", -- nose
--DAMAGEOFF		[4] = "F-104T-part-tail", -- tail
	},
	
	lights_data = {
	typename = "collection",
	lights = {
    [1] = { typename = "collection",
						lights = {-- Top Anticollision Light (red)
								  {typename = "natostrobelight",
								   connector = "RED_BEACON_T",
								   argument_1 = 198,
								   period = 1.2,
								   phase_shift = 0
								  },
								  -- Bottom Anticollision Light (red)
								  {typename = "natostrobelight",
								   connector = "RED_BEACON_B",
								   argument_1 = 199,
								   period = 1.2,
								   phase_shift = 0
								  }
								 }
		  },
	[2] = { typename = "collection",
							lights = {-- Left Landing light
									  {typename = "spotlight",
									   connector = "LEFT_MAIN_SPOT",
									   argument = 209,
									   dir_correction = {elevation = math.rad(-1)}
									  },
									  -- Right Landing light
									  {typename = "spotlight",
									   connector = "RIGHT_MAIN_SPOT",
									   argument = 209,
									   dir_correction = {elevation = math.rad(-1)}
									  },
									  -- Nose Landing/Taxi light
									  {typename = "spotlight",
									   connector = "NOSE_TAXI_SPOT",
									   argument = 208,
									   dir_correction = {elevation = math.rad(3)}
									  }
									 }
		  },
    [3]	= {	typename = "collection",
						lights = {
								  { typename = "collection",
									lights = {
									  -- Left Position Light (red)
									  {typename = "omnilight",
										connector = "RED_POS_L",
										color = {0.99, 0.11, 0.3},
										pos_correction  = {0, 0, -0.2},
										argument  = 190
									  },
									  -- Right Position Light (green)
									  {typename = "omnilight",
										connector = "GREEN_POS_R",
										color = {0, 0.894, 0.6},
										pos_correction = {0, 0, 0.2},
										argument  = 191
									  }
									}
								  },
								  { typename = "collection",
								    lights = {
									  -- Left rear upper nav Light (red)
									  {typename = "omnilight",
										connector = "RED_UP_L_REAR",
										color = {0.99, 0.11, 0.3},
										pos_correction  = {0, 0, -0.2},
										argument  = 192
									  },
									  -- Right rear upper nav Light (red)
									  {typename = "omnilight",
										connector = "RED_UP_R_REAR",
										color = {0.99, 0.11, 0.3},
										pos_correction  = {0, 0, -0.2},
										argument  = 193
									  }
									}
								  },
								  { typename = "collection",
								    lights = {
									  -- Left rear lower nav Light (white)
									  {typename = "omnilight",
										connector = "WHITE_DN_L_REAR",
										color = {1, 1, 1},
										pos_correction  = {0, 0, -0.2},
										argument  = 194
									  },
									  -- Right rear lower nav Light (white)
									  {typename = "omnilight",
										connector = "WHITE_DN_R_REAR",
										color = {1, 1, 1},
										pos_correction  = {0, 0, -0.2},
										argument  = 195
									  }
									}
								  }
						}
		  },
    [4] = {	typename = "collection",
						   lights = {
									 -- Top Formation Light (white)
									 {typename = "omnilight",
									  connector = "WHITE_FORM_TOP",
									  color = {1, 1, 1},
									  argument = 200
									 }
									}
		  }
		}
	}
}
add_aircraft(MiG_23m)