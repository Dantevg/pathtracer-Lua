local Vector = require "lib.Vector"
local Colour = require "lib.Colour"
local Ray = require "Ray"

local Material = {}



function Material.new()
	local self = {}
	
	return setmetatable(self, {
		__index = Material,
	})
end



return setmetatable(Material, {
	__call = function(_, ...) return Material.new(...) end,
})