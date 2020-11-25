local Vector = require "lib.Vector"

local Plane = {}



function Plane.new(pos, u, v, w, h, colour, material)
	local self = {}
	self.pos = pos
	self.u = u:normalize()
	self.v = v:normalize()
	self.w = w
	self.h = h
	self.colour = colour
	self.material = material
	
	return setmetatable(self, {
		__index = Plane,
	})
end



function Plane:getIntersection(ray)
	local normal = self:getNormal()
	local denominator = normal:dot(ray.dir)
	if denominator > 2^-50 then return false end -- Parallel
	
	local t = normal:dot(Vector.subtract(self.pos, ray.pos)) / denominator
	if t < 0 then return false end -- Behind ray
	
	local point = Vector.multiply(ray.dir, t):add(ray.pos)
	local u = Vector.subtract(point, self.pos):dot(self.u)
	local v = Vector.subtract(point, self.pos):dot(self.v)
	
	if u >= -self.w/2 and u <= self.w/2 and v >= -self.h/2 and v <= self.h/2 then
		return {
			object = self,
			point = point,
			distSq = t^2,
			normal = normal,
		}
	end
	
	return false
end

function Plane:getNormal()
	return Vector.cross(self.u, self.v):normalize()
end



return setmetatable(Plane, {
	__call = function(_, ...) return Plane.new(...) end,
})