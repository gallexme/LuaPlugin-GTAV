--[[ Config Area ]]
DebugMode		= false
Scripts_Path	= "C:\\Path\\To\\ScriptsDir-Lua\\"



--[[ Script/Code Area ]]
local Scripts_Init, Scripts_Loop, Scripts_Stop
local Enabled = false
Scripts_Init = {
	Function	=	function()
						if Enabled then
							Scripts_Stop.Function()
						end
						for script in lfs.dir(Scripts_Path) do
							if string.endsWith(script, ".lua") then
								script = require(string.gsub(script, ".lua", ""))
								if type(script)=="table" then
									Scripts_Stop[#Scripts_Stop+1]=script.stop
									Scripts_Init[#Scripts_Init+1]=script.init
									Scripts_Loop[#Scripts_Loop+1]=script.loop
									--[[if script.loop then
										Scripts_Loop[#Scripts_Loop+1]=coroutine.wrap(script.loop)
									end]]
									--Compatability with older/existing LuaPlugin format Scripts
									Scripts_Stop[#Scripts_Stop+1]=script.unload
									Scripts_Loop[#Scripts_Loop+1]=script.tick
								end
							end
						end
						Enabled = true
					end
}
Scripts_Loop = {}
Scripts_Stop = {
	Function	=	function()
						Enabled = false
						
						for script in lfs.dir(Scripts_Path) do
							if string.endsWith(script, ".lua") then
								package.loaded[string.gsub(script, ".lua", "")]=nil
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
	-- Update the search path
	--[[package.path = string.format("%s?.lua;%s", Scripts_Path, package.path)
	package.path = string.format("%s?.lua;%s", Scripts_Path.."libs\\", package.path)]]
	--package.path = string.format(".\\?.lua;%s?.lua;%slibs\\?.lua;", Scripts_Path, Scripts_Path)
	--package.path = string.format(".\\?.lua;%s?.lua;%slibs\\?.lua;%s", Scripts_Path, Scripts_Path, package.path)
	package.path = string.format(".\\?.dll;%s?.dll;%slibs\\?.dll;%slibs\\?\\init.dll;%s", Scripts_Path, Scripts_Path, Scripts_Path, package.path)
	package.path = string.format(".\\?.lua;%s?.lua;%slibs\\?.lua;%slibs\\?\\init.lua;%s", Scripts_Path, Scripts_Path, Scripts_Path, package.path)
	package.path = string.format(".\\?;%s?;%slibs\\?;%slibs\\?\\init;%s", Scripts_Path, Scripts_Path, Scripts_Path, package.path)
	
	--local inspect = require('inspect')
	
	--[[
	local luvi = require('luvi')
	print(inspect(luvi))
	local bundle = require('luvi').bundle
	print(inspect(bundle))
	load(bundle.readfile("luvit-loader.lua"), "bundle:luvit-loader.lua")()
	]]
	
	--[[local luviFile = io.open(Scripts_Path.."libs\\luvi.exe")
	print(inspect(luviFile))
	local luviData = luviFile:read("*a")
	print(inspect(luviData))
	local luvi = load(luviData)
	print(inspect(luvi))]]
	
	--require("libuv")
	--require("luvit-loader")
	--dofile(Scripts_Path.."\\libs\\luvit-loader.lua")
	--os.execute("")
	--load(io.open(Scripts_Path.."libs\\luvi.exe"):read("*a"))
	--require('luvi')
	--loadlib(Scripts_Path.."libs\\luvi.exe", "luvi")()
	--dofile(Scripts_Path.."libs\\luvi.exe")
	--[[load(io.open(Scripts_Path.."libs\\luvi.exe"):read("*a"))
	local inspect = require'inspect'
	print(inspect(_G))
	local uv = require('uv')
	Wait = function(ms)
		local thread = coroutine.running()
		local timer = uv.new_timer()
		timer:start(ms, 0, function()
			timer:close()
			coroutine.resume(thread)
		end)
		coroutine.yield()
	end]]
	
	function unrequire(script)
		package.loaded[script]=nil
	end
	
	function string.split(inputstr,sep)
		sep = sep or "%s"
		local t={}
		for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			table.insert(t, str)
		end
	return t end
	function string.upperFirst(s)
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
			--[[if not DebugMode then
				_G[k] = nil
			end]]
		end
	end
	IsKeyPressed=get_key_pressed
	--[[if not DebugMode then
		--get_key_pressed=nil
	end]]
	Wait=wait
	
	Scripts_Init.Function()
end
function init()
	while not IsKeyPressed--[[IsControlPressed]] do
		_init()
		wait(5000)
	end
end