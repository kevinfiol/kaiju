local Object = require 'lib.classic'
local Rectangle = require 'engine.Rectangle'
local nata = require 'lib.nata'
local lume = require 'lib.lume'
local cartographer = require 'lib.cartographer'

local Area = Object:extend()

local function shouldRemove(entity)
  return entity and entity.dead
end

local function onRemove(entity)
  if entity.destroy then
    entity:destroy()
  end
end

function Area:new(...)
  self.map = nil

  local args = {...}
  local groups = {}
  local systems = {}

  for _, system in ipairs(args) do
    groups = lume.merge(groups, system.group)
    table.insert(systems, system)
  end

  self.pool = nata.new({
    groups = groups,
    systems = {
      nata.oop(),
      unpack(systems)
    }
  })

  -- destroys dead entities
  self.pool:on('remove', onRemove)
end

function Area:update(dt)
  self.pool:flush()
  self.pool:emit('update', dt)

  if self.map then
    self.map:update(dt)
  end

  -- define when to remove entities
  self.pool:remove(shouldRemove)
end

function Area:draw()
  -- draw tilemaps before drawing other entities
  if self.map then
    self.map:draw()
  end

  self.pool:emit('draw')
end

function Area:destroy()
  for _, entity in ipairs(self.pool.entities) do
    entity:destroy()
  end

  self.pool = nil
end

function Area:queue(entities)
  for _, entity in pairs(entities) do
    self.pool:queue(entity)
  end
end

function Area:loadTilemap(filename)
  if self.map then
    self.map = nil
  end

  local map = cartographer.load(filename)
  local tile_width = map.tilewidth
  local tile_height = map.tileheight
  -- local width = map.width -- width in tiles
  -- local height = map.height -- height in tiles
  local collidables = {}

  for _, layer in ipairs(map.layers) do
    if layer.class == 'collide' or layer.class == 'wall' then
      for _i, _gid, _tilex, _tiley, x, y in layer:getTiles() do
        local rectangle = Rectangle(x, y, tile_width, tile_height)

        -- add collision system to rectangle
        rectangle.collision = {
          class = 'WALL',
          immovable = true
        }

        table.insert(collidables, rectangle)
      end
    end
  end

  if #collidables > 1 then
    -- add the newly created collidable tiles to the entity pool
    self:queue(collidables)
  end

  self.map = map
end

return Area