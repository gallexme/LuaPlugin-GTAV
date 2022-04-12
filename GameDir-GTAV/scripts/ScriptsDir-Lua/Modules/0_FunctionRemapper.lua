if not JM36_GTAV_LuaPlugin_Version or JM36_GTAV_LuaPlugin_Version < 20220412.0 then
	error("You are attempting to use an incompatible or an outdated version of Lua Plugin with Function (Re)Mapper; please update to the latest version of JM36 GTAV Lua Plugin first - https://github.com/JayMontana36/LuaPlugin-GTAV/releases")
	return
else
	local FunctionsReplaced = {}
	
	local pairs, configFileRead, print, _G2, _G, type, pcall, require, string_gsub, string_endsWith, lfs_dir
		= pairs, configFileRead, print, _G2, _G, type, pcall, require, string.gsub, string.endsWith, lfs.dir
	
	local FunctionRemapperDirShort = "Modules\\0_FunctionRemapper\\"
	local FunctionRemapperDirLong = Scripts_Path..FunctionRemapperDirShort
	
	for File in lfs_dir(FunctionRemapperDirLong) do
		if string_endsWith(File, ".lua") then
			local FileName = string_gsub(File, ".lua", "")
			local RequiredName = FunctionRemapperDirShort..FileName
			local Successful, File = pcall(require, RequiredName)
			if Successful then
				if type(File)=="function" then
					FunctionsReplaced[RequiredName] = {FileName, _G[FileName]}
					_G[FileName] = nil
					_G2[FileName] = File
				end
			else
				print(File)
			end
		elseif string_endsWith(File, ".ini") then
			local FunctionsToRemap = configFileRead(FunctionRemapperDirShort..File)
			for k,v in pairs(FunctionsToRemap) do
				_G2[k] = _G[v]
			end
			FunctionsToRemap = nil
		end
	end



	_G2.JM36_GTAV_LuaPlugin_FunctionRemapper_Version = 20220412.0



	return {
		stop	=	function()
						if JM36_GTAV_LuaPlugin_FunctionRemapper_Version then
							local unrequire = unrequire
							for k,v in pairs(FunctionsReplaced) do
								unrequire(k)
								_G2[v[1]] = FunctionsReplaced[v[2]]
							end
							FunctionsReplaced = nil
							
							_G2.JM36_GTAV_LuaPlugin_FunctionRemapper_Version = nil
						end
					end
	}
end