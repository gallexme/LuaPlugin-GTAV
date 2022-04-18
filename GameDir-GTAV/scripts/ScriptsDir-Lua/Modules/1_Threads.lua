if not JM36_GTAV_LuaPlugin_Version or JM36_GTAV_LuaPlugin_Version < 20220412.0 then error("You are attempting to use an incompatible or an outdated version of Lua Plugin; please update to the latest version of JM36 GTAV Lua Plugin first - https://github.com/JayMontana36/LuaPlugin-GTAV/releases") return end

local coroutine = coroutine

JM36 = {CreateThread=0,Wait=0,yield=0} local JM36 = JM36

do
	local Halt
	do
		local Info = Info
		local yield = coroutine.yield
		Halt = function(ms)
			local TimeResume = Info.Time+(ms or 0)
			repeat
				yield()
			until Info.Time > TimeResume
		end
	end
	JM36.Wait, JM36.yield = Halt, Halt
end

local Threads = {}

do
	local CreateThread
	do
		local table_insert = table.insert
		local Info = Info
		local create = coroutine.create
		CreateThread = function(func, ...)
			table_insert(Threads, create(func, Info, ...))
		end
	end
	JM36.CreateThread = CreateThread
end



local resume = coroutine.resume
local CR = coroutine.create(function()
	local print = print
	local yield = JM36.yield
	local resume = resume
	local status = coroutine.status
	while true do
		local j, n = 1, #Threads
		for i=1,n do
			local Thread = Threads[i]
			if status(Thread)~="dead" then
				do
					local Successful, Error = resume(Thread)
					if not Successful then print(Error) end
				end
				if i ~= j then
					Threads[j] = Threads[i]
					Threads[i] = nil
				end
				j = j + 1
			else
				Threads[i] = nil
			end
		end
		yield()
	end
end)



return{
	loop	=	function()
					resume(CR)
				end,
}