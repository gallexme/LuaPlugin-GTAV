--[[ Config Area ]]
DebugMode		= false
Scripts_Path	= "C:\\Path\\To\\ScriptsDir-Lua\\"



--[[ Script/Code Area ]]
local Scripts_Init, Scripts_Loop, Scripts_Stop
local Enabled = false
local print, pcall, lfs_dir, require, collectgarbage, setmetatable
	= print, pcall, lfs.dir, require, collectgarbage, setmetatable
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
						local Successful, Error
						for i=1, #Scripts_Init do
							Successful, Error = pcall(Scripts_Init[i]) if not Successful then print(Error) end
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
		local NoErrors, Error = pcall(function()
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
		end)
		if not NoErrors then print(Error) end
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
	--[[ Introduce/Create a new Secondary Global Environment Variable ]]
	local _G2 = {} _G2._G2=_G2
	setmetatable(_G,{
		__index = _G2
	})
	
	--[[ Introduce some new useful functions ]]
	function _G2.unrequire(script) -- Very useful for script resets/reloads/cleanup
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
	local function string_startsWith(str, start) -- Check if a string starts with something
		return str:sub(1, #start) == start
	end string.startsWith = string_startsWith
	local function string_endsWith(str, ending) -- Check if a string ends with something
		return ending == "" or str:sub(-#ending) == ending
	end string.endsWith = string_endsWith
	
	local io_open, io_lines, string_gsub
		= io.open, io.lines, string.gsub
	function _G2.configFileRead(file, sep) -- Read simple config file
		file, sep = Scripts_Path..file, sep or "="
		local config, configFile = {}, io_open(file)
		if configFile then
			for line in io_lines(file) do
				if not (string_startsWith(line, "[") and string_endsWith(line, "]")) then
					line = string_gsub(line, "\n", "")
					line = string_gsub(line, "\r", "")
					if line ~= "" then
						line = string_split(line, sep)
						config[line[1]] = line[2]
					end
				end
			end
			configFile:close()
		end
		return config
	end
	local io_open, pairs, string_format, tostring
		= io.open, pairs, string.format, tostring
	function _G2.configFileWrite(file, config, sep) -- Write simple config file
		local configFile, sep = io_open(Scripts_Path..file, "w"), sep or "="
		for k,v in pairs(config) do
			configFile:write(string_format("%s%s%s\n", k, sep, tostring(v)))
		end
	end
	
	--[[ Introduce/Create FiveM style game native function calls ]]
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
	local string_lower, table_concat
		= string.lower, table.concat
	for k,v in pairs(_G) do
		if Namespaces[k] then
			for k,v in pairs(_G[k]) do
				k = string_split(k, "_")
				
				for i=1, #k do
					k[i] = string_upperFirst(string_lower(k[i]))
				end
				
				k = table_concat(k)
				
				if string_startsWith(k, "0x") then
					_G2["_"..k] = v
				end
				_G2[k] = v
			end
		end
	end
	_G2.IsKeyPressed=get_key_pressed
	_G2.Wait=wait
	
	--[[ Framework Things ]]
	local PlayerId, PlayerPedId, GetEntityCoords, IsPedInAnyVehicle, GetVehiclePedIsIn, GetPedInVehicleSeat, NetworkGetNetworkIdFromEntity, GetEntityModel, GetDisplayNameFromVehicleModel, IsThisModelABicycle, IsThisModelABike, IsThisModelABoat, IsThisModelACar, IsThisModelAHeli, IsThisModelAJetski, IsThisModelAPlane, IsThisModelAQuadbike, IsThisModelATrain, IsThisModelAnAmphibiousCar, IsThisModelAnAmphibiousQuadbike
		= PlayerId, PlayerPedId, GetEntityCoords, IsPedInAnyVehicle, GetVehiclePedIsIn, GetPedInVehicleSeat, NetworkGetNetworkIdFromEntity, GetEntityModel, GetDisplayNameFromVehicleModel, IsThisModelABicycle, IsThisModelABike, IsThisModelABoat, IsThisModelACar, IsThisModelAHeli, IsThisModelAJetski, IsThisModelAPlane, IsThisModelAQuadbike, IsThisModelATrain, IsThisModelAnAmphibiousCar, IsThisModelAnAmphibiousQuadbike
	local Player Player =
	{
		Id			=	0,
		Ped			=	0,
		Handle		=	0,
		Coords		=	0,
		Vehicle		=	{
							IsIn	=	0,
							IsOp	=	0,
							Id		=	0,
							Handle	=	0,
							NetId	=	0,
							Model	=	0,
							Name	=	0,
							Type	=	setmetatable({},{__index = function() return false end}),
						},
		Function	=	function()
							Player.Id		= PlayerId() -- GetPlayerIndex()
							local Ped		= PlayerPedId() Player.Ped,Player.Handle=Ped,Ped
							Player.Coords	= GetEntityCoords(Ped, false)
							local IsIn		= IsPedInAnyVehicle(Ped, false) Player.Vehicle.IsIn = IsIn
							if IsIn then
								local Vehicle	= Player.Vehicle
								local Veh		= GetVehiclePedIsIn(Ped, false)
								Vehicle.IsOp	= Ped == GetPedInVehicleSeat(Veh, -1)
								
								if Veh == Vehicle.Id then return end
								
								Vehicle.Id,Vehicle.Handle=Veh,Veh
								Vehicle.NetId	= NetworkGetNetworkIdFromEntity(Veh)
								local VehModel	= GetEntityModel(Veh) Vehicle.Model = VehModel
								Vehicle.Name	= GetDisplayNameFromVehicleModel(VehModel)
								
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
	collectgarbage()
end