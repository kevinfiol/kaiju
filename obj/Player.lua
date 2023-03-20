local Entity = require 'engine.Entity'

local Player = Entity:extend()

local CLASS = 'PLAYER'
local SPEED = 85
local WIDTH = 11
local HEIGHT = 14

function Player:new(opts)
  opts = opts or {}
  opts.width = WIDTH
  opts.height = HEIGHT
  Player.super.new(self, CLASS, opts)

  self.collision = {
    class = CLASS
  }

  self.move_2d = {
    speed = SPEED,
    up = 'walk_up',
    left_right = 'walk',
    idle = 'idle'
  }

  self.sprite = self:loadSprite('assets/sprite/gacko.png', {
    animated = true,
    width = 16,
    height = 16,
    offset = { x = 2, y = 3 },
    initial = 'idle',
    animations = {
      idle = { frames = { {1, 1, 4, 1, 0.1} } },
      idle_up = { frames = { {13, 1, 16, 1, 0.1} } },
      walk = { frames = { {5, 1, 8, 1, 0.1} } },
      walk_up = { frames = { {9, 1, 12, 1, 0.1} } },
    }
  })

  self.input = self:setControls({
    controls = {
      up = { 'key:w' },
      down = { 'key:s' },
      left = { 'key:a' },
      right = { 'key:d' }
    }
  })
end

function Player:update(dt)
  Player.super.update(self, dt)
end

function Player:draw()
  Player.super.draw(self)
end

return Player