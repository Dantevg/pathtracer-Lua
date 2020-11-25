local Vector = require "lib.Vector"

local Colour = {}



function Colour.new(r, g, b, a)
	local self
	if type(r) == "string" and r:sub(1,1) == "#" then
		self = Vector( table.unpack(Colour.hexStringToRgb(r)) )
		self.a = self.a or 1
	elseif type(r) == "string" then
		local c = {}
		for i in r:gmatch("%d+") do
			table.insert(c, tonumber(i))
		end
		if r:sub(1,3) == "rgb" then
			self = Vector(table.unpack(c))
			self.a = self.a or 1
		elseif r:sub(1,3) == "hsl" then
			self = Vector( table.unpack(Colour.hslToRgb(c[1], c[2], c[3], c[4])) )
			self.a = self.a or 1
		end
	elseif getmetatable(r) and getmetatable(r).__name == "Colour" then
		return Colour(r.r, r.g, r.b, r.a)
	elseif type(r) == "table" then
		self = Vector(r)
		self.r = self.r or 0
		self.g = self.g or self.r
		self.b = self.b or self.g
		self.a = self.a or 1
	else
		self = Vector(r, g, b, a)
		self.r = self.r or 0
		self.g = self.g or self.r
		self.b = self.b or self.g
		self.a = self.a or 1
	end
	
	return setmetatable(self, {
		__index = Colour,
		__tostring = Colour.toRgbString,
	})
end



function Colour:rgb()
	return self.r, self.g, self.b, self.a
end

function Colour:rgb255()
	return self.r*255, self.g*255, self.b*255, self.a*255
end

function Colour:hsl()
	return Colour.rgbToHsl(self.r, self.g, self.b, self.a)
end

function Colour:setAlpha(x)
	self.a = x
	return self
end

function Colour:getBrightness()
	return self:getAverage()
end

function Colour:toRgbString()
	local r = Colour.valueToPercentage(self.r)
	local g = Colour.valueToPercentage(self.g)
	local b = Colour.valueToPercentage(self.b)
	local a = Colour.valueToPercentage(self.a)
	return "rgba("+r+","+g+","+b+","+a+")"
end

function Colour:toHslString()
	local h, s, l, a = self:hsl()
	h = Colour.valueToDegrees(h)
	s = Colour.valueToPercentage(s)
	l = Colour.valueToPercentage(l)
	a = Colour.valueToPercentage(a)
	return "hsla("+h+","+s+","+l+","+a+")"
end



function Colour.random()
	return Colour( math.random(), math.random(), math.random() )
end

function Colour.valueToPercentage(x)
	return math.floor(x*100) + "%"
end

function Colour.valueToDegrees(x)
	return math.floor(x*360) + "deg"
end

function Colour.hexStringToRgb(hex)
	local c = {}
	hex = hex:gsub("^#", ""):gsub("^(%x)(%x)(%x)$", "%1%1%2%2%3%3")
	for i in hex:gmatch("%x%x") do
		table.insert(c, tonumber(i, 16) / 255)
	end
	return c
end

--[[]
	Colour conversion functions, slightly adapted:
		- Input and output is always in range [0,1]
		- Pass on alpha value
		- Adapt coding style
	From: https://axonflux.com/handy-rgb-to-hsl-and-rgb-to-hsv-color-model-c
]]--
function Colour.rgbToHsl(r, g, b, a)
	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local h, s, l = (max + min) / 2, 0, 0

	if max == min then
		h, s = 0, 0 -- achromatic
	else
		local d = max - min
		s = (l > 0.5) and d / (2 - max - min) or d / (max + min)
		if r == max then
			h = (g - b) / d + (g < b and 6 or 0)
		elseif g == max then
			h = (b - r) / d + 2
		elseif b == max then
			h = (r - g) / d + 4
		end
		h = h/6
	end

	return h, s, l, a
end

function Colour.hslToRgb(h, s, l, a)
	local r, g, b

	if s == 0 then
		r, g, b = l, l, l -- achromatic
	else
		local function hue2rgb(p, q, t)
			if t < 0 then t = t+1 end
			if t > 1 then t = t-1 end
			if t < 1/6 then return p + (q - p) * 6 * t end
			if t < 1/2 then return q end
			if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
			return p
		end

		local q = (l < 0.5) and l * (1 + s) or l + s - l * s
		local p = 2 * l - q
		r = hue2rgb(p, q, h + 1/3)
		g = hue2rgb(p, q, h)
		b = hue2rgb(p, q, h - 1/3)
	end

	return r, g, b, a
end

function Colour.WHITE() return Colour(1) end
function Colour.BLACK() return Colour(0) end
function Colour.RED() return Colour(1,0,0) end
function Colour.GREEN() return Colour(0,1,0) end
function Colour.BLUE() return Colour(0,0,1) end
function Colour.YELLOW() return Colour(1,1,0) end
function Colour.CYAN() return Colour(0,1,1) end
function Colour.MAGENTA() return Colour(1,0,1) end
function Colour.TRANSPARENT() return Colour(0,0,0,0) end



return setmetatable(Colour, {
	__call = function(_, ...) return Colour.new(...) end,
	__index = Vector,
	__name = "Colour",
})