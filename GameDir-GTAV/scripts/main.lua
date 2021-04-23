--[[ Config Area ]]
DebugMode		= false
Scripts_Path	= "C:\\Path\\To\\ScriptsDir-Lua\\"



--[[ Script/Code Area ]]
local Scripts_Init, Scripts_Loop, Scripts_Stop
local Enabled = false
local print, pcall, lfs_dir, require, collectgarbage
	= print, pcall, lfs.dir, require, collectgarbage
Scripts_Init = {
	Function	=	function()
						if Enabled then
							Scripts_Stop.Function()
						end
						print("All Lua Scripts Loaded Without Error:", pcall(function()
							local string_endsWith, require, string_gsub, type
								= string.endsWith, require, string.gsub, type
							for script in lfs_dir(Scripts_Path) do
								if string_endsWith(script, ".lua") then
									script = require(string_gsub(script, ".lua", ""))
									if type(script)=="table" then
										Scripts_Stop[#Scripts_Stop+1]=script.stop
										Scripts_Init[#Scripts_Init+1]=script.init
										Scripts_Loop[#Scripts_Loop+1]=script.loop
										--Support older/existing LuaPlugin format scripts
										Scripts_Stop[#Scripts_Stop+1]=script.unload
										Scripts_Loop[#Scripts_Loop+1]=script.tick
									end
								end
							end
						end))
						for i=1, #Scripts_Init do
							Scripts_Init[i]()
						end
						Enabled = true
					end
}
Scripts_Loop = {}
Scripts_Stop = {
	Function	=	function()
						Enabled = false
						
						local string_endsWith, unrequire, string_gsub
							= string.endsWith, unrequire, string.gsub
						for script in lfs_dir(Scripts_Path) do
							if string_endsWith(script, ".lua") then
								unrequire(string_gsub(script, ".lua", ""))
							end
						end
						
						for i=1, #Scripts_Init do
							Scripts_Init[i]=nil
						end
						for i=1, #Scripts_Loop do
							Scripts_Loop[i]=nil
						end
						for i=1, #Scripts_Stop do
							Scripts_Stop[i]() Scripts_Stop[i]=nil
						end
						
						collectgarbage()
					end
}
_G.Scripts_Init, _G.Scripts_Stop = Scripts_Init.Function, Scripts_Stop.Function



local os_clock
	= os.clock
local GetTime = function()
	return os_clock()*1000
end

local UpdateInfoTime = 0
local Info Info = {
	Time	= 0,
	Player	= 0,
}
if DebugMode then
	tick = function()
		local Time = GetTime()
		local Info = Info
		Info.Time = Time
		if Time >= UpdateInfoTime then
			Info.Player.Function()
			Time = GetTime()
			Info.Time = Time
			UpdateInfoTime = Time + 500
		end
		local Scripts_Loop = Scripts_Loop
		for i=1, #Scripts_Loop do
			if not Enabled and i>1 then break end
			Scripts_Loop[i](Info)
		end
	end
else
	tick = function()
		if Enabled then
			local Time = GetTime()
			local Info = Info
			Info.Time = Time
			if Time >= UpdateInfoTime then
				Info.Player.Function()
				Time = GetTime()
				Info.Time = Time
				UpdateInfoTime = Time + 500
			end
			local Scripts_Loop = Scripts_Loop
			for i=1, #Scripts_Loop do
				Scripts_Loop[i](Info)
			end
		end
	end
end
local function _init()
	--[[ Introduce some new useful functions ]]
	function unrequire(script) -- Very useful for script resets/reloads/cleanup
		package.loaded[script]=nil
	end
	
	local string_gmatch
		= string.gmatch
	local function string_split(inputstr,sep) -- Split strings into chunks or arguments (in tables)
		sep = sep or "%s" local t,n={},0
		for str in string_gmatch(inputstr, "([^"..sep.."]+)") do
			n=n+1 t[n]=str
		end
	return t end string.split = string_split
	local function string_upperFirst(s) -- Make the first letter of a string uppercase
		return s:sub(1,1):upper()..s:sub(2)
	end string.upperFirst = string_upperFirst
	local function string_endsWith(str, ending) -- Check if a string ends with something
		return ending == "" or str:sub(-#ending) == ending
	end string.endsWith = string_endsWith
	
	--[[ Introduce/Create FiveM style game native function calls ]]
	local FiveM_GameNativeFunctionCalls = {}
	local Namespaces	= {
		PLAYER			= true,
		ENTITY			= true,
		PED				= true,
		VEHICLE			= true,
		OBJECT			= true,
		AI				= true,
		GAMEPLAY		= true,
		AUDIO			= true,
		CUTSCENE		= true,
		INTERIOR		= true,
		CAM				= true,
		WEAPON			= true,
		ITEMSET			= true,
		STREAMING		= true,
		SCRIPT			= true,
		UI				= true,
		GRAPHICS		= true,
		STATS			= true,
		BRAIN			= true,
		MOBILE			= true,
		APP				= true,
		TIME			= true,
		PATHFIND		= true,
		CONTROLS		= true,
		DATAFILE		= true,
		FIRE			= true,
		DECISIONEVENT	= true,
		ZONE			= true,
		ROPE			= true,
		WATER			= true,
		WORLDPROBE		= true,
		NETWORK			= true,
		NETWORKCASH		= true,
		DLC1			= true,
		DLC2			= true,
		SYSTEM			= true,
		DECORATOR		= true,
		SOCIALCLUB		= true,
		UNK				= true,
		UNK1			= true,
		UNK2			= true,
		UNK3			= true,
	}
	local pairs, string_lower
		= pairs, string.lower
	for k,v in pairs(_G) do
		if Namespaces[k] then
			local FunctionName
			for k,v in pairs(_G[k]) do
				k = string_split(k, "_")
				
				for i=1, #k do
					k[i] = string_upperFirst(string_lower(k[i]))
				end
				
				FunctionName = ""
				for i=1, #k do
					FunctionName = FunctionName..k[i]
				end
				
				FiveM_GameNativeFunctionCalls[FunctionName] = v
			end
		end
	end
	FiveM_GameNativeFunctionCalls.IsKeyPressed=get_key_pressed
	FiveM_GameNativeFunctionCalls.Wait=wait
	setmetatable(_G,{
		__index = function(table, key) return FiveM_GameNativeFunctionCalls[key] end
	})
	
	--[[ Framework Things ]]
	local PlayerId, PlayerPedId, GetEntityCoords, IsPedInAnyVehicle, GetVehiclePedIsIn, GetPedInVehicleSeat, NetworkGetNetworkIdFromEntity, GetEntityModel, GetDisplayNameFromVehicleModel, IsThisModelABicycle, IsThisModelABike, IsThisModelABoat, IsThisModelACar, IsThisModelAHeli, IsThisModelAJetski, IsThisModelAPlane, IsThisModelAQuadbike, IsThisModelATrain, IsThisModelAnAmphibiousCar, IsThisModelAnAmphibiousQuadbike
		= PlayerId, PlayerPedId, GetEntityCoords, IsPedInAnyVehicle, GetVehiclePedIsIn, GetPedInVehicleSeat, NetworkGetNetworkIdFromEntity, GetEntityModel, GetDisplayNameFromVehicleModel, IsThisModelABicycle, IsThisModelABike, IsThisModelABoat, IsThisModelACar, IsThisModelAHeli, IsThisModelAJetski, IsThisModelAPlane, IsThisModelAQuadbike, IsThisModelATrain, IsThisModelAnAmphibiousCar, IsThisModelAnAmphibiousQuadbike
	local Player Player =
	{
		--Id			=	0,
		Ped			=	0,
		Coords		=	0,
		Vehicle		=	{
							IsIn	=	0,
							IsOp	=	0,
							Id		=	0,
							NetId	=	0,
							Model	=	0,
							Name	=	0,
							Type	=	setmetatable({},{__index = function() return false end}),
						},
		Function	=	function()
							--Player.Id		= PlayerId() -- GetPlayerIndex()
							local Ped		= PlayerPedId() Player.Ped = Ped
							Player.Coords	= GetEntityCoords(Ped, false)
							local IsIn		= IsPedInAnyVehicle(Ped, false) Player.Vehicle.IsIn = IsIn
							if IsIn then
								local Vehicle	= Player.Vehicle
								local Veh		= GetVehiclePedIsIn(Ped, false)
								Vehicle.IsOp	= Ped == GetPedInVehicleSeat(Veh, -1)
								
								if Veh == Vehicle.Id then return end
								
								Vehicle.Id		= Veh
								Vehicle.NetId	= NetworkGetNetworkIdFromEntity(Veh)
								local VehModel	= GetEntityModel(Veh) Vehicle.Model = VehModel
								Vehicle.Name	= GetDisplayNameFromVehicleModel(Veh)
								
								local Vehicle_Type = Vehicle.Type
								Vehicle_Type.Bicycle			= IsThisModelABicycle(VehModel)
								Vehicle_Type.Bike				= IsThisModelABike(VehModel)
								Vehicle_Type.Boat				= IsThisModelABoat(VehModel)
								Vehicle_Type.Car				= IsThisModelACar(VehModel)
								Vehicle_Type.Heli				= IsThisModelAHeli(VehModel)
								--Vehicle_Type.Jetski				= IsThisModelAJetski(VehModel)
								Vehicle_Type.Plane				= IsThisModelAPlane(VehModel)
								Vehicle_Type.Quadbike			= IsThisModelAQuadbike(VehModel)
								Vehicle_Type.Train				= IsThisModelATrain(VehModel)
								--Vehicle_Type.AmphibiousCar		= IsThisModelAnAmphibiousCar(VehModel)
								--Vehicle_Type.AmphibiousQuadbike	= IsThisModelAnAmphibiousQuadbike(VehModel)
							end
						end
	} Info.Player = Player
	
	--[[ Fix Scripts_Path string variable if missing the trailing "//" on the end ]]
	if not string_endsWith(Scripts_Path, "//") then
		Scripts_Path = Scripts_Path.."//"
	end
	
	--[[ Update the search path ]]
	local string_format
		= string.format
	package.path = string_format(".\\?.dll;%s?.dll;%slibs\\?.dll;%slibs\\?\\init.dll;%s", Scripts_Path, Scripts_Path, Scripts_Path, package.path) -- DLL
	package.path = string_format(".\\?.lua;%s?.lua;%slibs\\?.lua;%slibs\\?\\init.lua;%s", Scripts_Path, Scripts_Path, Scripts_Path, package.path) -- Lua
	package.path = string_format(".\\?;%s?;%slibs\\?;%slibs\\?\\init;%s", Scripts_Path, Scripts_Path, Scripts_Path, package.path) -- NoExtension
	
	--[[ Compatability with original LuaPlugin GUI.lua script ]]
	Keys = require("Keys")
	
	--[[ Perform scripts initialization ]]
	Scripts_Init.Function()
end
function init()
	_init()
end