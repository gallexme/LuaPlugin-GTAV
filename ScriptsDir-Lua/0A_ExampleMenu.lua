local Example Example = {
--[[
	init			=	function()
							Example.Keys		= require("Keys")
							Example.Menu		= require("GUI")
							Example.Menu.Open	= false
							
							--Example.Menu.addButton(ButtonName, Function, (nil or Table of Function Arguments), xPosMin, xPosMax, yPosmin, yPosMax)
							--Example.Menu.addButton("Hello World", SaySomething, {}, 0.0, 0.2, 0.05, 0.05)
							
							Example.Menu.addButton("Hello World1", Example.SaySomethingA, 0.0, 0.2, 0.05, 0.05)
							Example.Menu.addButton("Hello World2", Example.SaySomethingA, nil, 0.0, 0.2, 0.05, 0.05)
							Example.Menu.addButton("Hello World3", Example.SaySomethingA, {}, 0.0, 0.2, 0.05, 0.05)
							Example.Menu.addButton("Hello World4", Example.SaySomethingA, {"Hi", "World", "!"}, 0.0, 0.2, 0.05, 0.05)
						end,
	loop			=	function()
							if IsKeyPressed(Example.Keys.Z) or IsKeyPressed(90) or IsControlPressed(0, 20) then
								Example.Menu.Open = not Example.Menu.Open
							end
							
							if Example.Menu.Open then
								Example.Menu.tick()
							end
						end,
	stop			=	function()
							unrequire("Keys")
							unrequire("GUI")
						end,
	SaySomethingA	=	function(args)
							if args then
								if type(args)=="table" then
									if #args ~= 0 then
										for i=1, #args do
											print(args[i].."3")
										end
									else
										print("Hello World!2")
									end
								end
							else
								print("Hello World!1")
							end
						end,
]]
}
return Example