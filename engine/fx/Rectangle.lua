local Object = require 'lib.classic'
local flux = require 'lib.flux'
local id = 1
local Rectangle = Object:extend()

function Rectangle:new(opts)
  self.id = id
  id = id + 1
  self.x = opts.x
  self.y = opts.y
  self.host = opts.host
  self.dead = false
  self.tween = flux.group()

  local size = opts.enter
  local exit_size = opts.exit

  self.width = size
  self.height = size

  if not self.x and self.host then
    self.x, self.y = self:getPos()
  end

  flux.to(self, opts.speed, { width = exit_size, height = exit_size })
    :ease('quadout')
    :oncomplete(function ()
      self.dead = true
      opts.onComplete()
    end)
end

function Rectangle:update()
end

function Rectangle:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

function Rectangle:destroy()

end

function Rectangle:getPos()
  -- right now this is tied too much to Move2D which itself is too tied to Player
  if not self.host then return 0, 0 end
  if self.host and not self.host.sprite then return 0, 0 end

  local a = self.host.sprite.animation -- current animation
  local up = a == 'idle_up' or a == 'walk_up'
  local down = a == 'idle_down' or a == 'walk_down'
  local left = (a == 'idle' or a == 'walk') and self.host.sprite.flipX
  local right = (a == 'idle' or a == 'walk') and not self.host.sprite.flipX

  local x = self.host:middleX()
  local y = self.host:middleY()

  if up then
    x = x - 2
    y = y - 6
  elseif down then
    x = x - 2
    y = y + 6
  elseif left then
    x = x - 2
    y = y - 3
  elseif right then
    x = x + 2
    y = y - 3
  end

  return x, y
end

return Rectangle