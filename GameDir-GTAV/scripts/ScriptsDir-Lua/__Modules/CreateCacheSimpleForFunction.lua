local setmetatable = setmetatable
local mode = "kv"
local call = function(Table, Key) return Table[Key] end
return function(Function)
	local Function = Function
	return setmetatable({},
		{
			__mode	=	mode,
			__index	=	function(Table, Key)
							local Value = Function(Key)
							Table[Key] = Value
							return Value
						end,
			__call	=	call,
		}
	)
end
