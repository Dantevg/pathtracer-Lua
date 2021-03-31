local Worker = require "Worker"
local Colour = require "lib.Colour"
local Canvas = require "lib.Canvas"

local Pathtracer = {}



function Pathtracer.new(scene, width, height, nWorkers)
	local self = {}
	self.width = width
	self.height = height
	self.running = 0
	self.iterations = 0
	
	self.workers = {}
	for i = 1, (nWorkers or 1) do
		table.insert(self.workers, Worker(scene))
	end
	
	self.buffer = {}
	for x = 0, self.width do
		self.buffer[x] = {}
		for y = 0, self.height do
			self.buffer[x][y] = Colour.BLACK()
		end
	end
	
	return setmetatable(self, {
		__index = Pathtracer
	})
end

function Pathtracer.findTiling(n)
	local rows = math.floor( math.sqrt(n) )
	while (n/rows) % 1 ~= 0 and rows > 1 do
		rows = rows-1
	end
	return rows
end



function Pathtracer:render(canvas, options)
	local rows = Pathtracer.findTiling(#self.workers)
	local w = math.floor(self.width / #self.workers * rows)
	local h = math.floor(self.height / rows)
	
	-- Initialize worker callbacks
	for i, worker in ipairs(self.workers) do
		local sx, sy = w*math.floor(i/rows), h*(i%rows)
		
		worker.onresult = function(iterations, data)
			print "Render result"
			self.iterations = self.iterations+1
			self.running = self.running-1
			self:displayProgress(options.nIterations)
			
			-- Restart worker if limit not reached, or if no limit set
			if not options.nIterations or iterations < options.nIterations then
				worker:render(options.nBounces or 0, options.batchSize or 1, sx, sy, w, h)
				self.running = self.running+1
			end
			
			-- Add the data to the buffer
			self:result(data, sx, sy)
			
			-- Draw the buffer to the canvas
			if options.onlyFinal and self.running == 0 then
				self:draw(canvas, options.scale, self.iterations/self.workers.length) -- Do a full draw
			elseif not options.onlyFinal then
				self:draw(canvas, options.scale, data.iterations, sx, sy, w, h)
			end
		end
		
		print "Starting worker"
		worker:render(options.nBounces or 0, options.batchSize or 1, sx, sy, w, h)
		self.running = self.running+1
	end
end

function Pathtracer:stop()
	for _, worker in ipairs(self.workers) do
		worker:stop()
	end
end

function Pathtracer:result(buffer, ox, oy)
	for x = 1, #buffer do
		for y = 1, #buffer[x] do
			self.buffer[x+ox][y+oy].add(Colour(buffer[x][y].items))
		end
	end
end

function Pathtracer:draw(canvas, scale, iterations, sx, sy, sw, sh)
	local weight = Colour(1 / iterations)
	Canvas.draw(
		self.buffer, canvas,
		function(pixel) return Colour.multiply(pixel, weight).rgb255() end,
		scale, sx or 0, sy or 0, sw or self.width, sh or self.height
	)
end

function Pathtracer:displayProgress(nIterations)
	local str = self.iterations.." i"
	if nIterations then
		str = str.." - "..math.floor(self.iterations / nIterations / #self.workers * 100).."%"
	end
	print(str)
end



return setmetatable(Pathtracer, {
	__call = function(_, ...) return Pathtracer.new(...) end,
})