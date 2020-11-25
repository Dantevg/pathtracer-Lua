local Class = {}



function Class.new()
	local self = {}
	
	return setmetatable(self, {
		__index = Class,
	})
end



return setmetatable(Class, {
	__call = function(_, ...) return Class.new(...) end,
})