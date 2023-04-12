local vars = require 'vars'
local Entity = require 'engine.Entity'
local Timer = require 'lib.timer'
local util = require 'engine.util'
local vector = require 'engine.vector'
local Bullet = require 'obj.Bullet'

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

  self.timer = Timer.new()
  self.spawn = nil
  self.shoot_timer = nil
  self.spawning_state = true
  self.is_shooting = false

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
      idle = { frames = { {1, 1, 4, 1, 0.15} } },
      idle_up = { frames = { {21, 1, 24, 1, 0.15} } },
      idle_down = { frames = { {41, 1, 44, 1, 0.15} } },
      walk = { frames = { {5, 1, 12, 1, 0.15} } },
      walk_up = { frames = { {25, 1, 32, 1, 0.15} } },
      walk_down = { frames = { {45, 1, 52, 1, 0.15} } },
      run = { frames = { {13, 1, 20, 1, 0.15} } },
      run_up = { frames = { {33, 1, 40, 1, 0.15} } },
      run_down = { frames = { {53, 1, 60, 1, 0.15} } },
    }
  })

  self.input = self:setControls({
    controls = {
      up = { 'key:w' },
      down = { 'key:s' },
      left = { 'key:a' },
      right = { 'key:d' },
      run = { 'key:n' },
      shoot = { 'mouse:1' }
    }
  })

  self:emitEffect('Circle', { speed = 0.1, enter = 0, exit = 15 }, function ()
    self.spawning_state = false
  end)
end

function Player:update(dt)
  Player.super.update(self, dt)
  if self.timer then self.timer:update(dt) end

  self:shoot(dt)
end

function Player:draw()
  if self.spawning_state then return end
  Player.super.draw(self)
end

function Player:destroy()
  Player.super.destroy(self)
end

function Player:shoot(dt)
  if self.input:down('shoot') then
    if self.is_shooting then return end

    self.is_shooting = true
    self:shootBullet()
    self.shoot_timer = self.timer:every(0.25, util.bind(self, self.shootBullet))
  else
    if not self.is_shooting then return end
    self.is_shooting = false
    self.timer:cancel(self.shoot_timer)
  end
end

function Player:shootBullet()
  -- if (self.sounds.shoot:isPlaying()) then
  --   self.sounds.shoot:stop()
  -- end

  _G.camera:shake(2, 0.2, 60, 'XY')
  -- self.sounds.shoot:play()
  local x, y = love.mouse.getPosition()
  x = x / vars.sx -- have to scale
  y = y / vars.sy -- have to scale

  local v = vector.getUnitVector(self:middleX(), self:middleY(), x, y)

  self.spawn(
    Bullet({
      x = self.x,
      y = self.y,
      vector = v
    })
  )

  self:emitEffect('Rectangle', { speed = 0.2, enter = 10, exit = 0 })
end

return Player