local argparse = require("argparse")("pathtracer")
argparse:argument "scene"
local args = argparse:parse({...})

local Pathtracer = require "Pathtracer"
local scene = require("scenes/"..args.scene)
