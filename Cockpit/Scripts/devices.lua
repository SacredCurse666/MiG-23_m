local count = 0
local function counter()
	count = count + 1
	return count
end
-------DEVICE ID-------
devices = {}
devices["TEST"]						= counter()--1
devices["WEAPON_SYSTEM"]			= counter()--2
devices["ELECTRIC_SYSTEM"]			= counter()--3
devices["CLOCK"]					= counter()--4
devices["ADI"]						= counter()--5
devices["GEAR_SYSTEM"]				= counter()--6
devices["RADAR"]					= counter()--7
devices["EXTANIM"]					= counter()--7
devices["RADARWARN"]                = counter()     -- !!!!!!!!!!
devices["D_FUEL"] 					= counter() 
devices["WING"] 					= counter()
devices["AVIONICS"] 				= counter()
devices["FLAP_SYSTEM"] 				= counter()
devices["CANOPY"] 					= counter()
devices["SPEEDBRAKE"] 			    = counter()
devices["LIGHT_PANEL"] 			    = counter()
devices["EGT_SYSTEM"]				= counter()
devices["BAILOUT"] 			    	= counter()
--devices["D_RADAR_IDX"]				= counter() 
devices["HYDRAULIC_SYSTEM"]			= counter()--8
devices["ENGINE"]					= counter()
devices["PNEUMATIC_SYSTEM"]			= counter()

