local System = require 'engine.System'

local GROUP_NAME = 'spawn'
local Spawner = System.create(GROUP_NAME)

function Spawner:onInit()
  self.group_name = GROUP_NAME
end

function Spawner:addToGroup(_, e)
  -- monkey patch ability to queue entities to the pool
  e[GROUP_NAME] = function (entity)
    self.pool:queue(entity)
  end
end

function Spawner:removeFromGroup(_, e)
  e[GROUP_NAME] = nil
end

return Spawner