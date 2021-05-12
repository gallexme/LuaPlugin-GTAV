return {
	init	=	function()
					local FunctionsToRemap, _G, _G2 = configFileRead("1_FunctionRemapper.ini"), _G, _G2
					for k,v in pairs(FunctionsToRemap) do
						_G2[k] = _G[v]
					end
				end
}