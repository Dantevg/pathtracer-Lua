local Vector = require "lib.Vector"
local Colour = require "lib.Colour"
local Material = require "Material"
local Camera = require "Camera"
local Plane = require "shapes.Plane"
-- local Sphere = require "shapes.Sphere"

local scene = {}

scene.camera = Camera( Vector(0, -350, 0), Vector(1,0,0), Vector(0,0,-1), 20, 20, 1, scene )

-- Ceiling
table.insert( scene, Plane( Vector(0, 0, 128), Vector(1,0,0), Vector(0,-1,0), 256, 256, Colour.WHITE(), Material.emissive() ) )
-- Floor
table.insert( scene, Plane( Vector(0, 0, -128), Vector(1,0,0), Vector(0,1,0), 256, 256, Colour.WHITE(), Material.matte() ) )
-- Back wall
table.insert( scene, Plane( Vector(0, 128, 0), Vector(1,0,0), Vector(0,0,1), 256, 256, Colour.WHITE(), Material.matte() ) )
-- Left wall
table.insert( scene, Plane( Vector(-128, 0, 0), Vector(0,1,0), Vector(0,0,1), 256, 256, Colour.RED(), Material.matte() ) )
-- Right wall
table.insert( scene, Plane( Vector(128, 0, 0), Vector(0,-1,0), Vector(0,0,1), 256, 256, Colour.GREEN(), Material.matte() ) )

-- table.insert( scene, Sphere( Vector(0, 0, -100), 50, Colour.WHITE(), Material.matte() ) )

return scene