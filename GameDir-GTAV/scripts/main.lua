--[[ Config Area ]]
DebugMode		= false
Scripts_Path	= "scripts\\ScriptsDir-Lua\\" or "C:\\Path\\To\\ScriptsDir-Lua\\"



--[[ Script/Code Area ]]
Info = { Enabled=false, Time=0, Player=0 } local Info = Info
local Scripts_Init, Scripts_Loop, Scripts_Stop
do
	Scripts_Init = setmetatable({},{
		__call	=	function(Self)
						if Info.Enabled then Scripts_Stop() end
						
						local Scripts_List, Scripts_NMBR = {}, 0
						do
							local string_gsub, string_endsWith, lfs_dir
								= string.gsub, string.endsWith, lfs.dir
							for Script in lfs_dir(Script_Modules) do
								if string_endsWith(Script, ".lua") then
									Scripts_NMBR = Scripts_NMBR+1
									Scripts_List[Scripts_NMBR] = string_gsub(Script, ".lua", "")
								end
							end
						end
						
						table.sort(Scripts_List)
						Scripts_List.Num = Scripts_NMBR
						Self.List = Scripts_List
						
						do
							local Scripts_Loop, Scripts_Stop
								= Scripts_Loop, Scripts_Stop
							local print, type, pcall, require
								= print, type, pcall, require
							for i=1, Scripts_NMBR do
								local Successful, Script = pcall(require, Scripts_List[i])
								if Successful then
									if type(Script)=='table' then
										Self[#Self+1] = Script.init
										Scripts_Loop[#Scripts_Loop+1]=Script.loop
										Scripts_Stop[#Scripts_Stop+1]=Script.stop
										--Support older/existing LuaPlugin format scripts
										Scripts_Stop[#Scripts_Stop+1]=script.unload
										Scripts_Loop[#Scripts_Loop+1]=script.tick
									end
								else
									print(Script)
								end
							end
						end
						do
							local print, pcall = print, pcall
							for i=1, #Self do
								local Successful, Error = pcall(Self[i], Info) if not Successful then print(Error) end
							end
						end
						
						Info.Enabled = true
					end
	})
end
Scripts_Loop = {} -- Merge with tick using metatables?
do
	Scripts_Stop = setmetatable({},{
		__call  =   function(Self)
						Info.Enabled = false
						
						do
							local Scripts_Init = Scripts_Init
							do
								local unrequire = unrequire
								local Scripts_List = Scripts_Init.List
								for i=1, Scripts_List.Num do
									unrequire(Scripts_List[i])
								end
							end
							
							for i=1, #Scripts_Init do
								Scripts_Init[i]=nil
							end
						end
						
						for i=1, #Scripts_Loop do
							Scripts_Loop[i]=nil
						end
						
						do
							local print, pcall = print, pcall
							for i=1, #Self do
								local Successful, Error = pcall(Self[i], Info) if not Successful then print(Error) end Self[i]=nil
							end
						end
						
						collectgarbage()
					end
	})
end
_G.Scripts_Init, _G.Scripts_Stop = Scripts_Init, Scripts_Stop



do
	local GetTime
	do
		local os_clock = os.clock
		GetTime = function()
			return os_clock()*1000
		end
	end
	do
		local Info_Update_Delay = Info_Update_Delay or 0
		local UpdateInfoTime = 0
		local Scripts_Loop = Scripts_Loop
		local Info = Info
		if DebugMode then
			local print, pcall = print, pcall
			tick = function()
				local Time = GetTime()
				Info.Time = Time
				if Time >= UpdateInfoTime then
					local Functions = Info.Functions
					for i=1, #Functions do
						Functions[i](Info)
					end
					UpdateInfoTime = Time + Info_Update_Delay
				end
				for i=1, #Scripts_Loop do
					if not Info.Enabled and i~=1 then break end
					--if not Info.Enabled then break end
					local Successful, Error = pcall(Scripts_Loop[i], Info) if not Successful then print(Error) end
				end
			end
		else
			tick = function()
				if Info.Enabled then
					local Time = GetTime()
					Info.Time = Time
					if Time >= UpdateInfoTime then
						local Functions = Info.Functions
						for i=1, #Functions do
							Functions[i](Info)
						end
						UpdateInfoTime = Time + Info_Update_Delay
					end
					for i=1, #Scripts_Loop do
						Scripts_Loop[i](Info)
					end
				end
			end
		end
	end
end

do
	--[[ Introduce some new useful string functions ]]
	do
		local string = string
		
		do
			local string_gmatch = string.gmatch
			string.split = function(inputstr,sep) -- Split strings into chunks or arguments (in tables)
				sep = sep or "%s" local t,n={},0
				for str in string_gmatch(inputstr, "([^"..sep.."]+)") do
					n=n+1 t[n]=str
				end
				return t
			end
		end
		
		string.upperFirst = function(s) -- Make the first letter of a string uppercase
			return s:sub(1,1):upper()..s:sub(2)
		end
		
		string.startsWith = function(str, start) -- Check if a string starts with something
			return str:sub(1, #start) == start
		end
		
		string.endsWith = function(str, ending) -- Check if a string ends with something
			return ending == "" or str:sub(-#ending) == ending
		end
	end
	
	--[[ Introduce/Create a new Secondary Global Environment Variable ]]
	local setmetatable = setmetatable
	local _G2
	do
		_G2 = { _G2=0,JM36_GTAV_LuaPlugin_Version=20220412.0 }
		_G2._G2=_G2
		setmetatable(_G,{__index=_G2})
	end
	
	--[[ Introduce some new useful core functions ]]
	do
		local package_loaded = package.loaded
		function _G2.unrequire(script) -- Very useful for script resets/reloads/cleanup
			package_loaded[script]=nil
		end
	end
	do
		local io_open, string_split, string_gsub, string_endsWith, string_startsWith, io_lines
			= io.open, string.split, string.gsub, string.endsWith, string.startsWith, io.lines
		function _G2.configFileRead(file, sep) -- Read simple config file
			file, sep = Scripts_Path..file, sep or "="
			local config, configFile = {}, io_open(file)
			if configFile then
				for line in io_lines(file) do
					if not (string_startsWith(line, "[") and string_endsWith(line, "]")) then
						line = string_gsub(line, "\n", "") line = string_gsub(line, "\r", "")
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
	end
	do
		local io_open, string_format, tostring, pairs
			= io.open, string.format, tostring, pairs
		function _G2.configFileWrite(file, config, sep) -- Write simple config file
			local configFile, sep = io_open(Scripts_Path..file, "w"), sep or "="
			for k,v in pairs(config) do
				configFile:write(string_format("%s%s%s\n", k, sep, tostring(v)))
			end
		end
	end
	
	--[[ Fix Scripts_Path string variable if missing the trailing "//" on the end ]]
	if not string.endsWith(Scripts_Path, "//") then
		Scripts_Path = Scripts_Path.."//"
	end
	
	--[[ Define other additional Script Paths ]]
	Script_Modules = Scripts_Path.."Modules//" -- Modular Script Components/Parts
	__Script_Modules = Scripts_Path.."__Modules//" -- Shared Script Components/Resources
	Script_Libs = Scripts_Path.."libs//" -- Standard libs Directory For Environment
	__Script_Libs = Scripts_Path.."__libs//" -- Automatically Loaded libs On Startup
	__Internal_Path = Scripts_Path.."__Internal//"
	
	--[[ Update the search path ]]
	do
		local package_path = package.path
		local string_format = string.format
		local _G = _G
		local DirectoriesList = {"Scripts_Path","Script_Modules","__Script_Modules","Script_Libs","__Script_Libs"}
		for i=1,5 do
			local Directory = _G[DirectoriesList[i]]
			package_path = string_format(".\\?.dll;%s?.dll;%slibs\\?.dll;%slibs\\?\\init.dll;%s", Directory, Directory, Directory, package_path) -- DLL
			package_path = string_format(".\\?.lua;%s?.lua;%slibs\\?.lua;%slibs\\?\\init.lua;%s", Directory, Directory, Directory, package_path) -- Lua
			package_path = string_format(".\\?;%s?;%slibs\\?;%slibs\\?\\init;%s", Directory, Directory, Directory, package_path) -- NoExtension
		end
		package.path = package_path
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
	
	local table_concat, string_upperFirst, string_lower, string_split, string_startsWith, _G, pairs
        = table.concat, string.upperFirst, string.lower, string.split, string.startsWith, _G, pairs
	for k,v in pairs(_G) do
		if Namespaces[k] then
			for k,v in pairs(_G[k]) do
				if string_startsWith(k, "_0x") then
					_G2[k] = v
				else
					k = string_split(k, "_")
					for i=1, #k do
						k[i] = string_upperFirst(string_lower(k[i]))
					end
					_G2[table_concat(k)] = v
				end
			end
		end
	end
	Namespaces = nil
	_G2.IsKeyPressed=get_key_pressed
	_G2.Wait=wait
	
	--[[ Automatically load __Internal ]]
	do
		local Info = Info
		
		local Functions = setmetatable({},{
			__call  =   function(Self)
							local Info = Info
							for i=1, #Self do
								Self[i](Info)
							end
						end
		})
		Info.Functions = Functions
		
		local package = package
		local package_path_orig = package.path
		
		local __Internal_Path = __Internal_Path
		
		package.path = string.format("%s?.lua", __Internal_Path)
		
		local List, ListNum = {}, 0
		do
			local string_gsub, string_endsWith, lfs_dir
				= string.gsub, string.endsWith, lfs.dir
			for Lib in lfs_dir(__Internal_Path) do
				if string_endsWith(Lib, ".lua") then
					ListNum = ListNum+1
					List[ListNum] = string_gsub(Lib, ".lua", "")
				end
			end
		end
		table.sort(List)
		do
			local pcall, require, type, print
				= pcall, require, type, print
			local FunctionsNum = 0
			for i=1, ListNum do
				local Successful, Function = pcall(require, List[i])
				if Successful then
					local Type = type(Function)
					if Type == "table" then
						if not Function.InfoKeyOnly then
							FunctionsNum = FunctionsNum + 1
							Functions[FunctionsNum] = Function
						end
						local Key = Function.InfoKeyName
						if type(Key) == "string" then
							Info[Key] = Function
						end
					elseif Type == "function" then
						FunctionsNum = FunctionsNum + 1
						Functions[FunctionsNum] = Function
					end
				else
					print(Function)
				end
			end
		end
		
		package.path = package_path_orig
	end
	
	--[[ Automatically load __libs ]]
	do
		local __libs_List, __libs_NMBR = {}, 0
		do
			local string_gsub, string_endsWith, lfs_dir
				= string.gsub, string.endsWith, lfs.dir
			for __lib in lfs_dir(__Script_Libs) do
				if string_endsWith(__lib, ".lua") then
					__libs_NMBR = __libs_NMBR+1
					__libs_List[__libs_NMBR] = string_gsub(__lib, ".lua", "")
				end
			end
		end
		
		table.sort(__libs_List)
		
		do
			local Scripts_Loop, Scripts_Stop
				= Scripts_Loop, Scripts_Stop
			local print, pcall, require
				= print, pcall, require
			for i=1, __libs_NMBR do
				local Successful, __lib = pcall(require, __libs_List[i])
				if not Successful then
					print(__lib)
				end
			end
		end
	end
	
	--[[ Compatability with existing LuaPlugin scripts ]]
	do
		local require = require
		Keys = require("Keys")
		do
			local loaded = package.loaded
			Libs = setmetatable({},{
				__mode		=	"kv",
				__index		=	function(Self, Key)
									local Value = loaded[Key] or require(Key)
									Self[Key] = Value
									return Value
								end,
			})
		end
		if not DisableMigrator then
			local io_popen, string_find, os_execute = io.popen, string.find, os.execute
			local ExecTail = " > nul 2> nul"
			--print("Migration commencing.")
			local Scripts_Path, Script_Modules = Scripts_Path, Script_Modules
			do
				local string_gsub = string.gsub
				Scripts_Path, Script_Modules = string_gsub(Scripts_Path, "//", "\\"), string_gsub(Script_Modules, "//", "\\")
				Scripts_Path, Script_Modules = string_gsub(Scripts_Path, "\\\\", "\\"), string_gsub(Script_Modules, "\\\\", "\\")
			end
			local Scripts_Dir = io_popen("dir scripts /w")
			local _Scripts_Dir = Scripts_Dir:read("*a")
			Scripts_Dir:close()
			if string_find(_Scripts_Dir, "addins") then
				os_execute("del scripts\\addins\\basemodule.lua"..ExecTail)
				os_execute("del scripts\\addins\\exampleGUI.lua"..ExecTail)
				os_execute("robocopy scripts\\addins "..Script_Modules.." /mt /s /move"..ExecTail)
				os_execute("rd scripts\\addins /s /q"..ExecTail)
				print('Migrated "scripts\\addins" to "'..Script_Modules..'".')
			end
			if string_find(_Scripts_Dir, "libs") then
				os_execute("del scripts\\libs\\GUI.lua"..ExecTail)
				os_execute("robocopy scripts\\libs "..Script_Libs.." /mt /s /move"..ExecTail)
				os_execute("rd scripts\\libs /s /q"..ExecTail)
				print('Migrated "scripts\\libs" to "'..Script_Libs..'".')
			end
			if string_find(_Scripts_Dir, "keys.lua") then
				os_execute("del scripts\\keys.lua"..ExecTail)
				print('Removed (legacy) "scripts\\keys.lua"')
			end
			if string_find(_Scripts_Dir, "utils.lua") then
				os_execute("del scripts\\utils.lua"..ExecTail)
				print('Removed (legacy) "scripts\\utils.lua"')
			end
			--print("Migration concluded.")
		end
	end
	
	--[[ Compatability with existing JM36 Lua Plugin scripts ]]
	do
		if not DisableMigrator then
			local io_popen, string_find, os_execute = io.popen, string.find, os.execute
			local ExecTail = " > nul 2> nul"
			--print("Migration commencing.")
			local Scripts_Path, Script_Modules = Scripts_Path, Script_Modules
			do
				local string_gsub = string.gsub
				Scripts_Path, Script_Modules = string_gsub(Scripts_Path, "//", "\\"), string_gsub(Script_Modules, "//", "\\")
				Scripts_Path, Script_Modules = string_gsub(Scripts_Path, "\\\\", "\\"), string_gsub(Script_Modules, "\\\\", "\\")
			end
			local Scripts_Dir = io_popen('dir "'..Scripts_Path..'" /w')
			local _Scripts_Dir = Scripts_Dir:read("*a")
			Scripts_Dir:close()
			if string_find(_Scripts_Dir, ".lua") then
				os_execute('robocopy "'..Scripts_Path..'\\" "'..Script_Modules..'\\" "*.lua" /mt /move'..ExecTail)
				--os_execute('DEL /Q /F "'..Scripts_Path..'*.lua"'..ExecTail)
				--print('Migrated '..Scripts_Path..' to "'..Script_Modules..'".')
				--print('Legacy JM36 LP Scripts Migrated.')
			end
			--print("Migration concluded.")
		end
	end
end

do
	local Scripts_Init, collectgarbage
		= Scripts_Init, collectgarbage
	init = function()
		collectgarbage()
		Scripts_Init()
	end
end
