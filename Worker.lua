local Worker = {}



function Worker.new(scene)
	local self = {}
	self.scene = scene
	self.iterations = 0
	
	return setmetatable(self, {
		__index = Worker,
	})
end



function Worker:render(nBounces, batchSize, width, height, sx, sy, sw, sh)
	self.scene.camera:init(width, height, sx, sy, sw, sh)
	
	for i = 1, batchSize do
		self.scene.camera:trace(nBounces)
		self.iterations = self.iterations+1
	end
	
	if self.onresult then
		self.onresult(self.iterations, self.scene.camera.buffer)
	end
end



return setmetatable(Worker, {
	__call = function(_, ...) return Worker.new(...) end,
})