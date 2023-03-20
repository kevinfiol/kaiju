local vars = require 'vars'
local System = require 'engine.System'

local GROUP_NAME = 'offscreen_death'
local OffscreenDeath = System.create(GROUP_NAME)

function OffscreenDeath:onInit()
  self.group_name = GROUP_NAME

  self.schema = {
    speed = 'number',
    dead = 'boolean',
    vector = { x = 'number', y = 'number' },
    [GROUP_NAME] = 'table'
  }
end

function OffscreenDeath:onAddToGroup(e)
  self:validateEntity(e)
end

function OffscreenDeath:onUpdate(e)
  if
    e.x > vars.gw
    or e.x + e.width < 0
    or e.y > vars.gh
    or e.y + e.height < 0
  then
    e.dead = true
  end
end

return OffscreenDeath