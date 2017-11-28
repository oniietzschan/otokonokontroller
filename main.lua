local Otokonokontroller = require 'otokonokontroller'
local input
local player

function love.load()
  Otokonokontroller.registerForLoveCallbacks()
  local controls = {
    walkLeft  = {'key:left',  'pad:dpleft', 'axis:leftx-'},
    walkRight = {'key:right', 'pad:dpleft', 'axis:leftx+'},
    jump      = {'key:z',     'pad:a'},
  }
  input = Otokonokontroller.newController(controls)

  player = {
    x = 0,
    y = 550,
    jump = function() end,
  }
end

function love.update(dt)
  Otokonokontroller.update(dt)
  local relativeX = input:get('walkRight') - input:get('walkLeft')
  player.x = player.x + relativeX
  if input:pressed('jump') then
    player:jump()
  end
end

function love.draw()
  love.graphics.rectangle('fill', player.x, player.y, 32, 32)
end
