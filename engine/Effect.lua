local flux = require 'lib.flux'

local Effect = {}
local RUNNING = {}

-- https://github.com/rxi/flux

function Effect:update(dt)
  for i = 1, #RUNNING do
    if RUNNING[i] then
      if RUNNING[i].dead then
        RUNNING[i] = nil
      else
        RUNNING[i]:update(dt)
      end
    end
  end

  flux.update(dt)
end

function Effect:draw()
  for i = 1, #RUNNING do
    if RUNNING[i] then
      RUNNING[i]:draw()
    end
  end
end

function Effect:add(effect_name, opts)
  local effect_constructor = require('engine.fx.' .. effect_name)
  local effect = effect_constructor(opts)
  table.insert(RUNNING, effect)
end

function Effect:clear()
  for i = 1, #RUNNING do
    RUNNING[i] = nil
  end
end

return Effect