local Plane = {}



function Plane.new()
	local self = {}
	
	return setmetatable(self, {
		__index = Plane,
	})
end



return setmetatable(Plane, {
	__call = function(_, ...) return Plane.new(...) end,
})