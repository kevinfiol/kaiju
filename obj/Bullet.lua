local Entity = require 'engine.Entity'

local Bullet = Entity:extend()

local CLASS = 'BULLET'
local SPEED = 4

function Bullet:new(opts)
  opts = opts or {}
  opts.width = 16
  opts.height = 16
  self.vector = opts.vector
  Bullet.super.new(self, CLASS, opts)

  self.collision = {
    class = CLASS
  }

  self.offscreen_death = true

  -- self.physics_ = {
  --   vel = { x = self.vector.x * SPEED, y = self.vector.y * SPEED },
  --   accel = { x = 0, y = 0 },
  --   max_vel = { x = 100, y = 100 },
  --   drag = { x = 0, y = 0 },
  --   angle = 0,
  --   angular_vel = 0
  -- }

  self.sprite = self:loadSprite('assets/sprite/fireball_spitting.png', {
    animated = true,
    width = 16,
    height = 16,
    initial = 'default',
    animations = {
      default = { frames = { {1, 1, 6, 1, 0.15} } }
    }
  })
end

function Bullet:update(dt)
  Bullet.super.update(self, dt)

  if self.vector then
    self.x = self.x + (SPEED * self.vector.x)
    self.y = self.y + (SPEED * self.vector.y)
  end
end

function Bullet:draw()
  if self.sprite then
    self.sprite:draw({
      -- radians = self.physics_.angle
    })
  end
end

return Bullet