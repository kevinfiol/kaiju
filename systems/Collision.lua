local bump = require 'lib.bump'
local System = require 'engine.System'

local GROUP_NAME = 'collision'

local BUMP_COLLISION = {
  TOUCH = 'touch',
  CROSS = 'cross',
  SLIDE = 'slide',
  BOUNCE = 'bounce'
}

local FILTER = {
  PLAYER = { BULLET = false },
  BULLET = { PLAYER = false },
  WALL = { WALL = false }
}

-- a weakMap holding properties for each entity
local props = {}

local Collision = System.create(GROUP_NAME)

-- https://github.com/oniietzschan/bump-niji

local function defaultFilter(item, other)
  local item_class = item[GROUP_NAME].class
  local other_class = other[GROUP_NAME].class
  local collision_mode = FILTER[item_class][other_class]

  if collision_mode == nil then
    -- default to touch if collision mode not specified
    return BUMP_COLLISION.TOUCH
  end

  return collision_mode
end

function Collision:onInit()
  self.world = bump.newWorld(16)
  self.group_name = GROUP_NAME

  -- entities with the Collision system should follow this schema
  self.schema = {
    x = 'number',
    y = 'number',
    width = 'number',
    height = 'number',
    [GROUP_NAME] = {
      -- contain_inscreen = 'boolean|nil',
      class = 'string',
      immovable = 'boolean|nil',
      events = 'object|nil',
      touching = 'object|nil',
      transparent = 'object|nil'
    }
  }
end

function Collision:onAddToGroup(e)
  self:validateEntity(e)
  self.world:add(e, e.x, e.y, e.width, e.height)

  -- initialize props
  props[e] = {
    last = {
      x = e.x,
      y = e.y,
      width = e.width,
      height = e.height
    },
    has_collided = {
      top = false,
      bottom = false,
      left = false,
      right = false
    },
    inside_of = {}
  }
end

function Collision:onRemoveFromGroup(e)
  self.world:remove(e)
  props[e] = nil
end

function Collision:onUpdate(e)
  local x
  local y
  local cols
  local len

  x, y, cols, len = self.world:move(e, e.x, e.y, defaultFilter)

  if len > 0 then
    -- update properties on entity
    e.x = x
    e.y = y
  end

  -- set last position & size
  -- todo: actually use this
  props[e].x = e.x
  props[e].y = e.y
  props[e].width = e.width
  props[e].height = e.height

  for _, col in pairs(cols) do
    local events = e[GROUP_NAME].events

    if events then
      local event = events[col.other[GROUP_NAME].class]

      if event then
        -- determine side of entity that was collided against
        local side = nil
        if col.normalY == 1 then
          side = 'top'
        elseif col.normalY == -1 then
          side = 'bottom'
        elseif col.normalX == 1 then
          side = 'left'
        elseif col.normalX == -1 then
          side = 'right'
        end

        event(col, side)
      end
    end
  end

  self.world.freeCollisions(cols)
end

return Collision