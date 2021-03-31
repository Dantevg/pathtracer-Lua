local argparse = require("argparse")("pathtracer")
argparse:argument "scene"
local args = argparse:parse({...})

local Pathtracer = require "Pathtracer"
local scene = require("scenes/"..args.scene)

local SDLWindow = require "SDLWindow"

local window = SDLWindow.new()
local tracer = Pathtracer(scene, window:getWidth(), window:getHeight(), 1)

tracer:render(window, {nIterations = 1})
