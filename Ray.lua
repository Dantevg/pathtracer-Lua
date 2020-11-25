local Ray = {}



function Ray.new(pos, dir, parentOrDepth, colour)
	local self = {}
	self.pos = pos
	self.dir = dir
	self.colour = colour
	self.to = {}
	
	if getmetatable(parentOrDepth) and getmetatable(parentOrDepth).__name == "Ray" then
		self.parent = parentOrDepth
		self.depth = self.parent.depth - 1
	else
		self.depth = parentOrDepth
	end
	
	return setmetatable(self, {
		__index = Ray,
	})
end



function Ray:cast(scene)
	self.to = {distSq = math.huge}
	
	for _, object in ipairs(scene) do
		local hit = object:getIntersection(self)
		if hit and hit.distSq < self.to.distSq then
			self.to = hit
		end
	end
	
	if self.depth >= 0 and self.to.object then
		-- Continue tracing (reflect/transmit)
		self.ray = self.to.object.material:bounce(self)
		local colour = self.ray and self.ray:cast(scene) or Colour.TRANSPARENT()
		return colour:multiply(self.to.object.colour):add(self.to.object.material.emission)
	end
	
	-- No object in path or no continuing ray, don't draw
	return Colour.TRANSPARENT()
end



return setmetatable(Ray, {
	__call = function(_, ...) return Ray.new(...) end,
	__name = "Ray",
})