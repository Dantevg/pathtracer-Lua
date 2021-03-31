local Canvas = {}



function Canvas.draw(buffer, canvas, map, scale, sx, sy, sw, sh)
	map = map or function(x) return x end
	scale = scale or 1
	sx, sy, sw, sh = sx or 0, sy or 0, sw or #buffer, sh or #buffer[1]
	
	
end



return Canvas