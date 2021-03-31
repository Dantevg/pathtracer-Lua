local Colour = require "lib.Colour"
local Vector = require "lib.Vector"
local Plane = require "shapes.Plane"
local Null = require "Null"
local Ray = require "Ray"

local Camera = {}



function Camera.new(pos, u, v, wPlane, hPlane, sensitivity, scene)
	local self = Plane(pos, u, v, wPlane, hPlane, Colour.WHITE(), Null())
	self.sensitivity = sensitivity
	self.scene = scene
	
	return setmetatable(self, {
		__index = Camera,
	})
end



function Camera:init(width, height, sx, sy, sw, sh)
	self.width = width
	self.height = height
	self.sx = sx
	self.sy = sy
	self.sw = sw
	self.sh = sh
	
	local horizontal = Vector.multiply(self.u, 0.5*self.w)
	local vertical = Vector.multiply(self.v, 0.5*self.h)
	self.a = Vector.subtract(self.pos, horizontal):subtract(vertical)
	self.normal = self:getNormal()
	self.focusPoint = Vector.multiply(self.normal, -self.w):add(self.pos)
	
	self.iterations = 0
	self.buffer = {}
	for x = 0, self.sw do
		self.buffer[x] = {}
		for y = 0, self.sh do
			self.buffer[x][y] = Colour.BLACK()
		end
	end
end

function Camera:trace(nBounces)
	for x = 0, self.sw do
		for y = 0, self.sh do
			local ox = (x+self.sx) / self.width * self.w
			local oy = (y+self.sy) / self.height * self.h
			
			local pos = self.a:clone():add( Vector.multiply(self.u, ox) ):add(Vector.multiply(self.v, oy))
			local dir = Vector.subtract(pos, self.focusPoint):normalize()
			local ray = Ray(pos, dir, nBounces, self.colour)
			
			self.buffer[x][y]:add(ray:cast(self.scene.objects), true)
		end
	end
	self.iterations = self.iterations+1
end



return setmetatable(Camera, {
	__call = function(_, ...) return Camera.new(...) end,
	__index = Plane,
})