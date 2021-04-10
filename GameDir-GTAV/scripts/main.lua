--[[ Config Area ]]
DebugMode		= false
Scripts_Path	= "C:\\Path\\To\\ScriptsDir-Lua\\"



--[[ Script/Code Area ]]
local Scripts_Init, Scripts_Loop, Scripts_Stop
local Enabled = false
local print, pcall, lfs_dir, collectgarbage
	= print, pcall, lfs.dir, collectgarbage
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
								--package.loaded[string.gsub(script, ".lua", "")]=nil
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

if DebugMode then
	tick = function()
		local Scripts_Loop = Scripts_Loop
		for i=1, #Scripts_Loop do
			if not Enabled and i>1 then break end
			Scripts_Loop[i]()
		end
	end
else
	tick = function()
		if Enabled then
			local Scripts_Loop = Scripts_Loop
			for i=1, #Scripts_Loop do
				Scripts_Loop[i]()
			end
		end
	end
end
local function _init()
	--[[ Update the search path]]
	package.path = string.format(".\\?.dll;%s?.dll;%slibs\\?.dll;%slibs\\?\\init.dll;%s", Scripts_Path, Scripts_Path, Scripts_Path, package.path) -- DLL
	package.path = string.format(".\\?.lua;%s?.lua;%slibs\\?.lua;%slibs\\?\\init.lua;%s", Scripts_Path, Scripts_Path, Scripts_Path, package.path) -- Lua
	package.path = string.format(".\\?;%s?;%slibs\\?;%slibs\\?\\init;%s", Scripts_Path, Scripts_Path, Scripts_Path, package.path) -- NoExtension
	
	--[[ Introduce some new useful functions ]]
	function unrequire(script) -- Very useful for script resets/reloads/cleanup
		package.loaded[script]=nil
	end
	
	function string.split(inputstr,sep) -- Split strings into chunks or arguments (in tables)
		sep = sep or "%s"
		local t={}
		for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			table.insert(t, str)
		end
	return t end
	function string.upperFirst(s) -- Make the first letter of a string uppercase
		return s:sub(1,1):upper()..s:sub(2)
	end
	function string.endsWith(str, ending)
		return ending == "" or str:sub(-#ending) == ending
	end
	
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
	for k,v in pairs(_G) do
		if Namespaces[k] then
			local FunctionName
			for k,v in pairs(_G[k]) do
				k = string.split(k, "_")
				
				for i=1, #k do
					k[i] = string.upperFirst(string.lower(k[i]))
				end
				
				FunctionName = ""
				for i=1, #k do
					FunctionName = FunctionName..k[i]
				end
				
				_G[FunctionName] = v
			end
		end
	end
	IsKeyPressed=get_key_pressed
	Wait=wait
	
	--Compatability with original LuaPlugin GUI.lua script
	Keys = require("Keys")
	
	Scripts_Init.Function()
end
function init()
	while IsKeyPressed==nil or IsControlPressed==nil or (GetHashKey==nil or _G.GetHashKey==nil) do
		_init()
	end
end