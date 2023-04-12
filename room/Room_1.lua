local vars = require 'vars'
local Object = require 'lib.classic'
local Area = require 'engine.Area'
local Effect = require 'engine.Effect'

local Collision = require 'systems.Collision'
local Physics = require 'systems.Physics'
local Spawner = require 'systems.Spawner'
local OffscreenDeath = require 'systems.OffscreenDeath'

local Player = require 'obj.Player'

local Room = Object:extend()

function Room:new()
  self.area = Area(
    Collision,
    Spawner,
    Physics,
    OffscreenDeath
  )

  self.canvas = love.graphics.newCanvas(vars.gw, vars.gh)

  -- self.area:loadTilemap('assets/maps/map.lua')

  self.area:queue({
    Player({ x = 82, y = 82 })
  })
end

function Room:update(dt)
  if not self.area then return end
  self.area:update(dt)

  Effect:update(dt)
end

function Room:draw()
  if not self.area then return end

  love.graphics.setCanvas(self.canvas)
  love.graphics.clear()
  --draw start
  _G.camera:attach(0, 0, vars.gw, vars.gh)

  red   = 20 / 255
  green = 10 / 255
  blue  = 30 / 255
  alpha = 100 / 100
  love.graphics.setBackgroundColor(red, green, blue, alpha)

  self.area:draw()
  Effect:draw()

  _G.camera:detach()
  -- draw end
  love.graphics.setCanvas()
  love.graphics.draw(self.canvas, 0, 0, 0, vars.sx, vars.sy)
end

function Room:destroy()
  self.canvas:release()
  self.canvas = nil
  self.area:destroy()
  self.area = nil
end

return Room