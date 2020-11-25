local List = {}



function List.new(tbl)
	return setmetatable(tbl or {}, {
		__index = List,
	})
end

function List.from(n, fn)
	local tbl = List.new()
	for i = 1, n do
		tbl[i] = fn(i)
	end
	return tbl
end

function List:map(fn)
	local newtbl = List.new()
	for i, v in ipairs(self) do
		newtbl[i] = fn(v, i)
	end
	return newtbl
end

function List:every(fn)
	for i, v in ipairs(self) do
		if not fn(v, i) then return false end
	end
	return true
end

function List:reduce(fn, start)
	local acc = start or 0
	for i, v in ipairs(self) do
		acc = fn(acc, v, i)
	end
	return acc
end



return setmetatable(List, {
	__index = table,
	__call = function(_, ...) return List.new(...) end,
})