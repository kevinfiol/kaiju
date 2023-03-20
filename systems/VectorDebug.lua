local System = require 'engine.System'

local GROUP_NAME = 'vector_debug'

local VectorDebug = System.create(GROUP_NAME)
VectorDebug.group = { filter = { 'vector' } }

local LINE_MAGNITUDE = 20

function VectorDebug:onDraw(e)
  local x, y = e:middle()
  love.graphics.line(x, y, (x + e.vector.x * LINE_MAGNITUDE), (y + e.vector.y * LINE_MAGNITUDE))
end

return VectorDebug