local List = require "lib.List"

local Vector = {}



Vector.map = {
	x = 1, r = 1, h = 1,
	y = 2, g = 2, s = 2,
	z = 3, b = 3, l = 3,
	a = 4,
}



function Vector.new(...)
	local self = {}
	self.items = List{...}
	
	return setmetatable(self, {
		__index = function(t, k)
			if type(k) == "number" then
				return self.items[k]
			elseif Vector.map[k] then
				return self.items[ Vector.map[k] ]
			else
				return Vector[k] -- Default behaviour
			end
		end,
		__newindex = function(t, k, v)
			if type(k) == "number" then
				self.items[k] = v
			elseif Vector.map[k] then
				self.items[ Vector.map[k] ] = v
			else
				self[k] = v -- Default behaviour
			end
		end,
		__tostring = function(self)
			return "Vector ["..table.concat(self.items, ", ").."]"
		end,
	})
end



function Vector:negative()
	self.items = self.items:map(function(val) return -v end)
	return self
end

function Vector:add(v)
	if getmetatable(v).__name == "Vector" then
		self.items = self.items:map(function(val, i) return val+v.items[i] end)
	else
		self.items = self.items:map(function(val) return val+v end)
	end
	return self
end
function Vector:subtract(v)
	if getmetatable(v).__name == "Vector" then
		self.items = self.items:map(function(val, i) return val-v.items[i] end)
	else
		self.items = self.items:map(function(val) return val-v end)
	end
	return self
end
function Vector:multiply(v)
	if getmetatable(v).__name == "Vector" then
		self.items = self.items:map(function(val, i) return val*v.items[i] end)
	else
		self.items = self.items:map(function(val) return val*v end)
	end
	return self
end
function Vector:divide(v)
	if getmetatable(v).__name == "Vector" then
		self.items = self.items:map(function(val, i) return (v.items[i] ~= 0) and val/v.items[i] or val end)
	else
		self.items = self.items:map(function(val) return (v ~= 0) and val/v or val end)
	end
	return self
end
function Vector:equals(v)
	if getmetatable(v).__name ~= "Vector" or #v.items ~= #self.items then
		return false
	end
	return self.items:every(function(val, i) return val == v.items[i] end)
end
function Vector:dot(v)
	return self.items:map(function(val, i) return val*v.items[i] end):reduce(function(a,b) return a+b end)
end
function Vector:cross2(v)
	return self.x * v.y - self.y * v.x
end
function Vector:cross(v)
	local x = self.y * v.z - self.z * v.y
	local y = self.z * v.x - self.x * v.z
	local z = self.x * v.y - self.y * v.x
	return Vector( x, y, z )
end
function Vector:length()
	return math.sqrt( self:dot(self) )
end
function Vector:normalize()
	return self:divide( self:length() )
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
	local sin, cos = math.sin(angle), math.cos(angle)
	self.x, self.y = self.x*cos - self.y*sin, self.x*sin + self.y*cos
	return self
end
function Vector:rotateX(angle)
	local sin, cos = math.sin(angle), math.cos(angle)
	self.x, self.y, self.z = self.x*cos - self.y*sin, self.x*sin + self.y*cos, self.z
	return self
end
function Vector:rotateY(angle)
	local sin, cos = math.sin(angle), math.cos(angle)
	self.x, self.y, self.z = self.x*cos + self.z*sin, self.y, -self.x*sin + self.z*cos
	return self
end
function Vector:rotateZ(angle)
	local sin, cos = math.sin(angle), math.cos(angle)
	self.x, self.y, self.z = self.x, self.y*cos - self.z*sin, self.y*sin + self.z*cos
	return self
end
function Vector:average()
	return self.items:reduce(function(a,b) return a+b end) / #self.items
end



function Vector.negative(v)
	return self( table.unpack(v.items:map(function(val) return -val end)) )
end
function Vector.add( a, b )
	if getmetatable(b).__name == "Vector" then
		return self( table.unpack(a.items:map(function(val, i) return val + b.items[i] end)) )
	else
		return self( table.unpack(a.items:map(function(val) return val + b end)) )
	end
end
function Vector.subtract( a, b )
	if getmetatable(b).__name == "Vector" then
		return self( table.unpack(a.items:map(function(val, i) return val - b.items[i] end)) )
	else
		return self( table.unpack(a.items:map(function(val) return val - b end)) )
	end
end
function Vector.multiply( a, b )
	if getmetatable(b).__name == "Vector" then
		return self( table.unpack(a.items:map(function(val, i) return val * b.items[i] end)) )
	else
		return self( table.unpack(a.items:map(function(val) return val * b end)) )
	end
end
function Vector.divide( a, b )
	if getmetatable(b).__name == "Vector" then
		return self( table.unpack(a.items:map(function(val, i) return val / b.items[i] end)) )
	else
		return self( table.unpack(a.items:map(function(val) return val / b end)) )
	end
end
function Vector.equals( a, b )
	if getmetatable(b).__name ~= "Vector" or getmetatable(b).__name ~= "Vector" or #a.items ~= #b.items then
		return false
	end
	return a.items:every(function(val, i) return val == b.items[i] end)
end
function Vector.dot( a, b )
	return a.items:map(function(val, i) return val*b.items[i] end):reduce(function(a,b) return a+b end)
end
function Vector.cross2( a, b )
	return a.x * b.y - a.y * b.x
end
function Vector.cross( a, b )
	local x = a.y*b.z - a.z*b.y
	local y = a.z*b.x - a.x*b.z
	local z = a.x*b.y - a.y*b.x
	return Vector( x, y, z )
end
function Vector.normalize(v)
	return self.divide( v, v:length() )
end
function Vector.distSq( a, b )
	return a.items:map(function(val, i) return (val-b.items[i])^2 end):reduce(function(a,b) return a+b end)
end
function Vector.dist( a, b )
	return math.sqrt( self:distSq(a, b) )
end
function Vector.clone(v)
	return self( table.unpack(v.items) )
end
function Vector.rotate( v, angle )
	local x = v.x * math.cos(angle) - v.y * math.sin(angle)
	local y = v.x * math.sin(angle) + v.y * math.cos(angle)
	return self( x, y )
end
function Vector.rotateX( v, angle )
	local x = v.x * math.cos(angle) - v.y * math.sin(angle)
	local y = v.x * math.sin(angle) + v.y * math.cos(angle)
	local z = v.z
	return self( x, y, z )
end
function Vector.rotateY( v, angle )
	local x = v.x * math.cos(angle) + v.z * math.sin(angle)
	local y = v.y
	local z = -v.x * math.sin(angle) + v.z * math.cos(angle)
	return self( x, y, z )
end
function Vector.rotateZ( v, angle )
	local x = v.x
	local y = v.y * math.cos(angle) - v.z * math.sin(angle)
	local z = v.y * math.sin(angle) + v.z * math.cos(angle)
	return self( x, y, z )
end
function Vector.average(v)
	return v.items:reduce(function(a,b) return a+b end) / #v.items
end
function Vector.fromAngle(angle)
	return self( math.cos(angle), math.sin(angle) )
end
function Vector.fromAngles3D( theta, phi )
	local x = math.sin(theta) * math.cos(phi)
	local y = math.sin(theta) * math.sin(phi)
	local z = math.cos(theta)
	return self( x, y, z )
end
function Vector.random(n)
	return self( table.unpack(List.from(n or 2, function() return math.random() end)) )
end
function Vector.random2DAngle()
	return self.fromAngle( math.random()*math.pi*2 )
end
function Vector.random3DAngles()
	return self.fromAngles3D( math.acos( 1 - 2*math.random() ), math.random()*math.pi*2 )
end



return setmetatable(Vector, {
	__call = function(_, ...) return Vector.new(...) end,
	__name = "Vector",
})