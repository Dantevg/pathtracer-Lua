local Vector = require "lib.Vector"
local Colour = require "lib.Colour"
local Ray = require "Ray"

local Material = {}



function Material.new(options)
	local self = {}
	self.roughness = options.roughness or 0.5
	self.metal = options.metal or 0
	self.transparency = options.transparency or 0
	self.emission = options.emission or 0
	self.ior = options.ior or 1.5
	
	return setmetatable(self, {
		__index = Material,
	})
end

function Material.glossy() return Material {roughness = 0} end
function Material.matte() return Material {roughness = 1} end
function Material.transparent() return Material {roughness = 0, transparency = 1} end
function Material.emissive() return Material {emission = 1} end



function Material:specular(ray, colour)
	local dir = ray.dir - (ray.to.normal * 2*ray.to.normal:dot(ray.dir))
	return Ray( ray.to.point + dir*0.001, dir, ray.depth-1, colour )
end

local function sign(x)
	return (x >= 0) and 1 or 0
end

function Material:diffuse(ray, colour)
	local dir = Vector.random3DAngles()
	
	-- Ensure ray goes in right direction
	dir:multiply( -sign(ray.dir:dot(ray.to.normal) * dir:dot(ray.to.normal)) )
	return Ray( ray.to.point + dir*0.001, dir, ray.depth-1, colour )
end

function Material:transmit(ray, colour)
	-- https://www.scratchapixel.com/lessons/3d-basic-rendering/introduction-to-shading/reflection-refraction-fresnel
	-- local n = ((ray.dir.dot(ray.to.normal) < 0) ? ray.ior : 1) / self.ior
	local N = Vector.clone(ray.to.normal)
	local c1 = ray.to.normal:dot(ray.dir)
	local n
	
	if c1 < 0 then -- Ray incoming
		c1 = -c1
		local n = 1 / self.ior
	else -- Ray outgoing
		N = Vector.multiply(N, -1)
		local n = self.ior / 1
	end
	
	local c2 = math.sqrt( 1 - n*n * (1-c1*c1) )
	local dir = ray.dir*n + N*(n*c1 - c2)
	return Ray( ray.to.point + dir*0.001, dir, ray.depth-1, colour )
end

function Material:fresnel(ray)
	local cosi = math.min( math.max(-1, ray.dir:dot(ray.to.normal)), 1 )
	local etai = 1
	local etat = self.ior
	if cosi > 0 then etai, etat = etat, etai end
	
	local sint = etai / etat * math.sqrt(math.max(0, 1-cosi*cosi))
	if sint >= 1 then
		return 1
	else
		local cost = math.sqrt(math.max(0, 1 - sint*sint))
		cosi = math.abs(cosi)
		local rs = (etat*cosi - etai*cost) / (etat*cosi + etai*cost)
		local rp = (etai*cosi - etat*cost) / (etai*cosi + etat*cost)
		return (rs*rs + rp*rp) / 2
	end
end

-- https://stackoverflow.com/a/33002487
function Material:schlick(ray)
	return math.pow( 1 - math.abs(Vector.dot(ray.to.normal,ray.dir)), 5 )
end

function Material:bounce(ray)
	if self.emission == 1 then
		return -- Don't reflect off fully emissive objects
	elseif math.random() < self:fresnel(ray)*(1-self.roughness) then
		return self:specular(ray, colour)
	elseif math.random() < self.transparency then
		return self:transmit(ray, colour)
	else
		return self:diffuse(ray, colour)
	end
end



return setmetatable(Material, {
	__call = function(_, ...) return Material.new(...) end,
})