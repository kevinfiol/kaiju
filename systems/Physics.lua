local Rectangle = require 'engine.Rectangle'
local lume = require 'lib.lume'
local System = require 'engine.System'

local GROUP_NAME = 'physics'
local Physics = System.create(GROUP_NAME)

function Physics:onInit()
  self.group_name = GROUP_NAME

  self.schema = {
    x = 'number',
    y = 'number',
    width = 'number',
    height = 'number',
    last = 'object|nil',
    [GROUP_NAME] = {
      angle = 'number',
      angular_vel = 'number',
      vel = { x = 'number', y = 'number' },
      accel = { x = 'number', y = 'number' },
      max_vel = { x = 'number', y = 'number' },
      drag = { x = 'number', y = 'number' }
    }
  }
end

function Physics:onAddToGroup(e)
  self:validateEntity(e)

  if not e.last then
    e.last = Rectangle(e.x, e.y, e.width, e.height)
  end
end

function Physics:onUpdate(e, dt)
  local vel = e[GROUP_NAME].vel
  local accel = e[GROUP_NAME].accel
  local max_vel = e[GROUP_NAME].max_vel
  local drag = e[GROUP_NAME].drag

  -- store last position
  -- e.last is an instance of Rectangle
  e.last:set(e.x, e.y, e.width, e.height)

  -- update velocity
  vel.x = vel.x + accel.x * dt
  vel.y = vel.y + accel.y * dt

  -- check max velocity
  if math.abs(vel.x) > max_vel.x  then
    vel.x = max_vel.x * lume.sign(vel.x)
  end

  if math.abs(vel.y) > max_vel.y  then
    vel.y = max_vel.y * lume.sign(vel.y)
  end

  -- update position
  e.x = e.x + vel.x * dt
  e.y = e.y + vel.y * dt

  -- check drag
  if accel.x == 0 and drag.x > 0 then
    local sign = lume.sign(vel.x)
    vel.x = vel.x - drag.x * dt * sign
    if (vel.x < 0) ~= (sign < 0) then
      vel.x = 0
    end
  end

  if accel.y == 0 and drag.y > 0 then
    local sign = lume.sign(vel.y)
    vel.y = vel.y - drag.y * dt * sign
    if (vel.y < 0) ~= (sign < 0) then
      vel.y = 0
    end
  end

  -- update angle
  e[GROUP_NAME].angle = e[GROUP_NAME].angle + e[GROUP_NAME].angular_vel * dt
end

return Physics