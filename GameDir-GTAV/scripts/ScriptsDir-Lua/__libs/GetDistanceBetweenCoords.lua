local math_sqrt = math.sqrt
local function GetDistanceBetweenCoords(x1 --[[ number ]], y1 --[[ number ]], z1 --[[ number ]], x2 --[[ number ]], y2 --[[ number ]], z2 --[[ number ]], useZ --[[ boolean ]])
	local xDist, yDist = x1 - x2, y1 - y2
	if useZ then
		local zDist = z1 - z2
		return math_sqrt(xDist*xDist+yDist*yDist+zDist*zDist)
	end
	return math_sqrt(xDist*xDist+yDist*yDist)
end
_G.GetDistanceBetweenCoords = GetDistanceBetweenCoords
return GetDistanceBetweenCoords