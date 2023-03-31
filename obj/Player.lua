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
    left_right = 'walk',
    up = 'walk_up',
    down = 'walk_down',
    idle = 'idle',
    idle_up = 'idle_up',
    idle_down = 'idle_down',
    run = 'run',
    run_up = 'run_up',
    run_down = 'run_down'
  }

  self.sprite = self:loadSprite('assets/sprite/grakko.png', {
    animated = true,
    width = 16,
    height = 16,
    offset = { x = 2, y = 3 },
    initial = 'idle',
    animations = {
      idle = { frames = { {1, 1, 4, 1, 0.1} } },
      idle_up = { frames = { {21, 1, 24, 1, 0.1} } },
      idle_down = { frames = { {41, 1, 44, 1, 0.1} } },
      walk = { frames = { {5, 1, 12, 1, 0.1} } },
      walk_up = { frames = { {25, 1, 32, 1, 0.1} } },
      walk_down = { frames = { {45, 1, 52, 1, 0.1} } },
      run = { frames = { {13, 1, 20, 1, 0.1} } },
      run_up = { frames = { {33, 1, 40, 1, 0.1} } },
      run_down = { frames = { {53, 1, 60, 1, 0.1} } },
    }
  })

  self.input = self:setControls({
    controls = {
      up = { 'key:w' },
      down = { 'key:s' },
      left = { 'key:a' },
      right = { 'key:d' },
      run = { 'key:n' }
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