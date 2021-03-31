local List = require "lib.List"

local Vector = {}



function Vector.new(...)
	local self = {}
	self.items = List{...}
	
	return setmetatable(self, Vector)
end



function Vector.fromAngle(angle)
	return Vector( math.cos(angle), math.sin(angle) )
end
function Vector.fromAngles3D(theta, phi)
	local x = math.sin(theta) * math.cos(phi)
	local y = math.sin(theta) * math.sin(phi)
	local z = math.cos(theta)
	return Vector(x, y, z)
end
function Vector.random(n)
	return Vector( table.unpack(List.from(n or 2, function() return math.random() end)) )
end
function Vector.random2DAngle()
	return Vector.fromAngle( math.random()*math.pi*2 )
end
function Vector.random3DAngles()
	return Vector.fromAngles3D( math.acos(1 - 2*math.random()), math.random()*math.pi*2 )
end



function Vector:map(fn)
	return Vector( table.unpack(self.items:map(fn)) )
end
function Vector:negative()
	return Vector( table.unpack(self.items:map(function(val) return -val end)) )
end
local function binop(op)
	return function(self, v)
		if type(v) == "table" then
			return Vector( table.unpack(self.items:map(function(val, i) return op(val, v.items[i]) end)) )
		else
			return Vector( table.unpack(self.items:map(function(val, i) return op(val, v) end)) )
		end
	end
end
Vector.add = binop(function(a, b) return a + b end)
Vector.subtract = binop(function(a, b) return a - b end)
Vector.multiply = binop(function(a, b) return a * b end)
Vector.divide = binop(function(a, b) return a / b end)
function Vector:equals(v)
	if type(v) ~= "table" or #self.items ~= #v.items then
		return false
	end
	return self.items:every(function(val, i) return val == v.items[i] end)
end
function Vector:dot(v)
	return self.items:map(function(val, i) return val*v.items[i] end):reduce(function(x,y) return x+y end)
end
function Vector:cross2(v)
	return self.x * v.y - self.y * v.x
end
function Vector:cross(v)
	local x = self.y*v.z - self.z*v.y
	local y = self.z*v.x - self.x*v.z
	local z = self.x*v.y - self.y*v.x
	return Vector( x, y, z )
end
function Vector:length()
	return math.sqrt( self:dot(self) )
end
function Vector:normalize()
	return self:divide( self:length() )
end
function Vector:distSq(v)
	return self.items:map(function(val, i) return (val-v.items[i])^2 end):reduce(function(x,y) return x+y end)
end
function Vector:dist(v)
	return math.sqrt( self:distSq(v) )
end
function Vector:min()
	return math.min(table.unpack(self.items))
end
function Vector:max()
	return math.max(table.unpack(self.items))
end
function Vector:toAngles()
	return -math.atan2( -self.y, self.x )
end
function Vector:getTheta()
	return math.acos( self.z / self:length() )
end
function Vector:getPhi()
	return math.atan2( self.y, self.x )
end
function Vector:angleTo(a)
	return math.acos( self:dot(a) / (self:length() * a:length()) )
end
function Vector:clone()
	return Vector(table.unpack(self.items))
end
function Vector:set(...)
	self.items = {...}
	return self
end
function Vector:rotate(angle)
	local x = self.x * math.cos(angle) - self.y * math.sin(angle)
	local y = self.x * math.sin(angle) + self.y * math.cos(angle)
	return Vector(x, y)
end
function Vector:rotateX(angle)
	local x = self.x * math.cos(angle) - self.y * math.sin(angle)
	local y = self.x * math.sin(angle) + self.y * math.cos(angle)
	local z = self.z
	return Vector(x, y, z)
end
function Vector:rotateY(angle)
	local x = self.x * math.cos(angle) + self.z * math.sin(angle)
	local y = self.y
	local z = -self.x * math.sin(angle) + self.z * math.cos(angle)
	return Vector(x, y, z)
end
function Vector:rotateZ(angle)
	local x = self.x
	local y = self.y * math.cos(angle) - self.z * math.sin(angle)
	local z = self.y * math.sin(angle) + self.z * math.cos(angle)
	return Vector(x, y, z)
end
function Vector:average()
	return self.items:reduce(function(a,b) return a+b end) / #self.items
end



Vector.map = {
	x = 1, r = 1, h = 1,
	y = 2, g = 2, s = 2,
	z = 3, b = 3, l = 3,
	a = 4,
}

Vector.__index = Vector
Vector.__name = "Vector"

Vector.__index = function(self, k)
	if type(k) == "number" then
		return self.items[k]
	elseif Vector.map[k] then
		return self.items[ Vector.map[k] ]
	else
		return Vector[k] -- Default behaviour
	end
end
Vector.__newindex = function(self, k, v)
	if type(k) == "number" then
		self.items[k] = v
	elseif Vector.map[k] then
		self.items[ Vector.map[k] ] = v
	else
		self[k] = v -- Default behaviour
	end
end
Vector.__tostring = function(self)
	return "Vector ["..table.concat(self.items, ", ").."]"
end

Vector.__add = Vector.add
Vector.__sub = Vector.subtract
Vector.__mul = Vector.multiply
Vector.__div = Vector.divide
Vector.__unm = Vector.negative
Vector.__eq = Vector.equals



return setmetatable(Vector, {
	__call = function(_, ...) return Vector.new(...) end,
	__name = "Vector",
})