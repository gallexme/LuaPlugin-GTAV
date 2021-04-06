return {
	init	=	nil or function()
					--Stuff that runs only once, on startup of the script
				end,
	loop	=	nil or function()
					--Stuff that runs/loops every frame
				end,
	stop	=	nil or function()
					--Stuff that runs only once, on shutdown of the script
				end,
}