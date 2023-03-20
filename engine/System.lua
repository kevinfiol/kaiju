local Object = require 'lib.classic'
local mishape = require 'lib.mishape'

local System = Object:extend()

local function createFilter(group_name)
  return {
    [group_name] = { filter = { group_name } }
  }
end

System.create = function (group_name)
  local system = Object:extend()
  system:implement(System)
  system.group = createFilter(group_name)
  return system
end

function System:init()
  self.validator = nil
  self.group_name = nil
  self.group = nil

  if self.onInit then
    self:onInit()
  end

  if not self.group_name then
    error('System must be assigned a group_name property')
  end
end

function System:update(dt)
  if dt == 0 then return end
  if not self.onUpdate then return end

  for _, e in ipairs(self.pool.groups[self.group_name].entities) do
    self:onUpdate(e, dt)
  end
end

function System:draw()
  if not self.onDraw then return end
  for _, e in ipairs(self.pool.groups[self.group_name].entities) do
    self:onDraw(e)
  end
end

function System:validateEntity(e)
  if _G.DEBUG then
    if not self.validator and self.schema then
      self.validator = mishape(self.schema)
    end

    if self.validator then
      local result = self.validator(e)

      if not result.ok then
        p(result)

        local err = '[' .. self.group_name .. '] objects must follow mishape schema.'
          .. '\nentity class_name: ' .. e.class_name .. '\n' .. result.errors[1]

        error(err)
      end
    end
  end
end

function System:addToGroup(group_name, e)
  if group_name == self.group_name then
    if self.onAddToGroup then
      self:onAddToGroup(e)
    end
  end
end

function System:removeFromGroup(group_name, e)
  if group_name == self.group_name then
    if self.onRemoveFromGroup then
      self:onRemoveFromGroup(e)
    end
  end
end

return System