local vars = require 'vars'
local lume = require 'lib.lume'
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
      speed = 'number',
      up = 'string',
      left_right = 'string',
      idle = 'string'
    }
  }
end

function Move2D:onAddToGroup(e)
  e.walking_up = false
  e.walking_down = false
  e.walking = false
  e.running = false
  self:validateEntity(e)
end

function Move2D:onUpdate(e, dt)
  local speed = e[GROUP_NAME].speed
  local current_animation = e.sprite.animation

  local left_right_anim = e[GROUP_NAME].left_right
  local up_anim = e[GROUP_NAME].up
  local down_anim = e[GROUP_NAME].down

  local idle_anim = e[GROUP_NAME].idle
  local idle_up_anim = e[GROUP_NAME].idle_up
  local idle_down_anim = e[GROUP_NAME].idle_down

  if e.input:down('run') then
    e.running = true
  else
    e.running = false
  end

  if e.running then
    speed = speed + 50
    left_right_anim = e[GROUP_NAME].run
    up_anim = e[GROUP_NAME].run_up
    down_anim = e[GROUP_NAME].run_down
  end

  if e.input:down('left') then
    e.x = lume.clamp(
      e.x - speed * dt,
      0, -- min,
      vars.gw - e.width -- max
    )

    if not e.sprite.flipX then
      e:flipX()
    end

    if not e.walking or
      (current_animation ~= left_right_anim and not (e.input:down('down') or e.input:down('up')))
    then
      e.walking = true
      e:animation(left_right_anim)
    end
  elseif e.input:down('right') then
    e.x = lume.clamp(
      e.x + speed * dt,
      0, -- min,
      vars.gw - e.width -- max
    )

    if e.sprite.flipX then
      e:flipX()
    end

    if not e.walking or
      (current_animation ~= left_right_anim and not (e.input:down('down') or e.input:down('up')))
    then
      e.walking = true
      e:animation(left_right_anim)
    end
  end

  if e.input:down('up') then
    e.y = lume.clamp(
      e.y - speed * dt,
      0, -- min,
      vars.gh - e.height -- max
    )

    if not e.walking or not e.walking_up then
      e.walking = true
      e.walking_up = true
      e.walking_down = false
      e:animation(up_anim)
    end
  elseif e.input:down('down') then
    e.y = lume.clamp(
      e.y + speed * dt,
      0, -- min,
      vars.gh - e.height -- max
    )

    if not e.walking or not e.walking_down then
      e.walking = true
      e.walking_down = true
      e.walking_up = false
      e:animation(down_anim)
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
    e.walking_down = false

    if e.input:released('up') then
      e.sprite:switch(idle_up_anim)
    elseif e.input:released('down') then
      e.sprite:switch(idle_down_anim)
    else
      e.sprite:switch(idle_anim)
    end
  end
end

return Move2D