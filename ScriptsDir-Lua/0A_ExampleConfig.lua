--[[
local config
return {
	init	=	function()
					config = configFileRead("SomeConfig.ini")
				end,
	stop	=	function()
					configFileWrite("SomeConfig.ini", config)
				end,
}
]]