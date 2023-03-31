local Object = require 'lib.classic'

local Background = Object:extend()

function Background:new()
  local img = love.graphics.newImage('assets/sprite/bg.png')
  local quad = love.graphics.newQuad(0, 0, 64, 64, img:getDimensions())

  local tile_height = 64
  local tile_width = 64
  local bg_width = 9
  local bg_height = 5
  local batch = love.graphics.newSpriteBatch(img, bg_width * bg_height)

  self.bg = {
    tile = { img = img, height = tile_height, width = tile_width },
    offset = { x = 0, y = 0 },
    quad = quad,
    batch = batch,
    x = 0,
    y = 0,
    width = bg_width, -- width in tiles
    height = bg_height, -- height in tiles,
    pixel_width = bg_width * tile_width,
    pixel_height = bg_height * tile_height
  }
end

function Background:draw()
  local bg = self.bg
  local half_tile_width = bg.tile.width / 2
  local increment = -(half_tile_width / (bg.tile.width)) * 1

  if bg.x == -(bg.pixel_width) then
    bg.x = 0
  end

  bg.x = bg.x + increment
  bg.batch:clear()
  local bg_double_width = bg.width * 2 -- let's draw the bg twice, one next to the other

  for i = 1, bg_double_width do
    for j = 1, bg.height do
      local x = (64 * i) - 64 + bg.offset.x + bg.x
      local y = (64 * j) - 64 + bg.offset.y + bg.y
      bg.batch:add(bg.quad, x, y)
    end
  end

  bg.batch:flush()
  love.graphics.draw(bg.batch)
end

function Background:destroy()
  self.bg.quad:release()
  self.bg.tile.img:release()
  self.bg = nil
end

return Background