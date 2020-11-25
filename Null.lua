local Material = require "Material"

local Null = {}

function Null.new()
	local self = Material{}
	
	return setmetatable(self, {
		__index = Null,
	})
end

return setmetatable(Null, {
	__call = function(_, ...) return Null.new(...) end,
	__index = Material,
})