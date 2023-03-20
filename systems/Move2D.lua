local System = require 'engine.System'

local GROUP_NAME = 'move_2d'
local Move2D = System.create(GROUP_NAME)

function Move2D:onInit()
  self.group_name = GROUP_NAME

  self.schema = {
    x = 'number',
    y = 'number',
    input = 'table',
    sprite = 'table',
    [GROUP_NAME] = {
      speed = 'number'
    }
  }
end

function Move2D:onAddToGroup(e)
  e.walking_up = false
  e.walking = false
  self:validateEntity(e)
end

function Move2D:onUpdate(e, dt)
  local speed = e[GROUP_NAME].speed

  if e.input:down('left') then
    e.x = e.x - speed * dt

    if not e.sprite.flipX then
      e:flipX()
    end

    if not e.walking then
      e.walking = true
      e:animation('walk')
    end
  elseif e.input:down('right') then
    e.x = e.x + speed * dt

    if e.sprite.flipX then
      e:flipX()
    end

    if not e.walking then
      e.walking = true
      e:animation('walk')
    end
  end

  if e.input:down('up') then
    e.y = e.y - speed * dt

    if not e.walking or not e.walking_up then
      e.walking = true
      e.walking_up = true
      e:animation('walk_up')
    end
  elseif e.input:down('down') then
    e.y = e.y + speed * dt

    if not e.walking then
      e.walking = true
      e.walking_up = false
      e:animation('walk')
    end
  end

  local stopped_walking =
    e.input:released('right') or
    e.input:released('left') or
    e.input:released('up') or
    e.input:released('down')
    and not (
      e.input:down('right') or
      e.input:down('left') or
      e.input:down('up') or
      e.input:down('down')
    )

  if stopped_walking then
    e.walking = false
    e.walking_up = false

    if e.input:released('up') then
      e.sprite:switch('idle_up')
    else
      e.sprite:switch('idle')
    end
  end
end

return Move2D