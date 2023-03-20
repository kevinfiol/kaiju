local vars = require 'vars'
local Object = require 'lib.classic'
local Area = require 'engine.Area'

local Collision = require 'systems.Collision'
local Move2D = require 'systems.Move2D'
local Player = require 'obj.Player'

local Room = Object:extend()

function Room:new()
  self.area = Area(Collision, Move2D)
  self.canvas = love.graphics.newCanvas(vars.gw, vars.gh)

  self.area:queue({
    Player({ x = 100, y = 100 })
  })
end

function Room:update(dt)
  if not self.area then return end
  self.area:update(dt)
end

function Room:draw()
  if not self.area then return end

  love.graphics.setCanvas(self.canvas)
  love.graphics.clear()

  self.area:draw()
  -- draw end
  love.graphics.setCanvas()
  love.graphics.draw(self.canvas, 0, 0, 0, vars.sx, vars.sy)
end

function Room:destroy()
  -- self.canvas:release()
  self.canvas = nil
  self.area:destroy()
  self.area = nil
end

return Room