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

  self.sprite = self:loadSprite('assets/sprite/grakko.png', {
    width = 16,
    height = 16,
    offset = { x = 2, y = 3 },
    initial = 'idle',
    animations = {
      idle = { 1, 1, 4, 1, 0.15 },
      idle_up = { 21, 1, 24, 1, 0.15 },
      idle_down = { 41, 1, 44, 1, 0.15 },
      walk = { 5, 1, 12, 1, 0.15 },
      walk_up = { 25, 1, 32, 1, 0.15 },
      walk_down = { 45, 1, 52, 1, 0.15 }
    }
  })

  self.input = self:setControls({
    up = { 'key:w' },
    down = { 'key:s' },
    left = { 'key:a' },
    right = { 'key:d' },
    run = { 'key:n' },
    shoot = { 'mouse:1' }
  })

  self:emitEffect('Circle', { speed = 0.1, enter = 0, exit = 15 }, function ()
    self.spawning_state = false
  end)
end

function Player:update(dt)
  Player.super.update(self, dt)
  if self.timer then self.timer:update(dt) end

  self:shoot(dt)
  self:move(dt)
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

function Player:move(dt)
  local max_x = vars.gw - self.width
  local max_y = vars.gh - self.height

  local animation = nil

  if self.input:down('left') then
    self.x = math.max(self.x - SPEED * dt, 0)

    if not self.sprite.flipX then
      self:flipX()
    end

    animation = 'walk'
  elseif self.input:down('right') then
    self.x = math.min(self.x + SPEED * dt, max_x)

    if self.sprite.flipX then
      self:flipX()
    end

    animation = 'walk'
  end

  if self.input:down('up') then
    self.y = math.max(self.y - SPEED * dt, 0)
    animation = 'walk_up'
  elseif self.input:down('down') then
    self.y = math.min(self.y + SPEED * dt, max_y)
    animation = 'walk_down'
  end

  if animation then
    self:animation(animation)
  elseif self.input:released('up') then
    self:animation('idle_up')
  elseif self.input:released('down') then
    self:animation('idle_down')
  elseif self.input:anyReleased('right', 'left') then
    self:animation('idle')
  end
end

return Player