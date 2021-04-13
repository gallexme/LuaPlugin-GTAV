if DebugMode then
	return {
		loop	=	function()
						--[[If Tab Key Pressed and not Alt Key Pressed then]]
						if get_key_pressed(9) and not IsControlPressed(0, 19) then
							print('Reloading Scripts')
							Scripts_Init()
							wait(2499)
						end
					end
	}
end