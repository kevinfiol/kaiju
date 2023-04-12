local Object = require 'lib.classic'
local flux = require 'lib.flux'

local Circle = Object:extend()

function Circle:new(opts)
  self.x = opts.x
  self.y = opts.y
  self.radius = opts.enter
  self.host = opts.host
  self.dead = false

  if not self.x and self.host then
    self.x = self.host.x
    self.y = self.host.y
  end

  flux.to(self, opts.speed, { radius = opts.exit })
    :ease('linear')
    :oncomplete(function ()
      self.dead = true
      opts.onComplete()
    end)
end

function Circle:update()
  if self.host then
    self.x = self.host.x + 6
    self.y = self.host.y + 6
  end
end

function Circle:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.circle('fill', self.x, self.y, self.radius)
end

return Circle