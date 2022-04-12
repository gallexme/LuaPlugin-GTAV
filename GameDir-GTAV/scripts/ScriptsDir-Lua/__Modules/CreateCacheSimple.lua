local setmetatable = setmetatable
local mode = "kv"
local call = function(Table, Key) return Table[Key] end
return function()
	return setmetatable({},
		{
			__mode	=	mode,
			__call	=	call,
		}
	)
end
