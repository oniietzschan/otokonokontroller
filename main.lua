local Otokonokontroller = require 'otokonokontroller'()
local player

function love.load()
  Otokonokontroller:registerForLoveCallbacks()

  Otokonokontroller:newController({
    quit = {'key:escape'},
  })
    :setPressedCallback(function(control)
      if control == 'quit' then
        love.event.push('quit')
      end
    end)

  player = {
    x = 400,
    y = 550,
  }
  player.input = Otokonokontroller:newController({
    walkLeft  = {'key:left',  'pad:dpleft', 'axis:leftx-'},
    walkRight = {'key:right', 'pad:dpleft', 'axis:leftx+'},
    climb     = {'key:up',    'pad:dpup'},
    fall      = {'key:down',  'pad:dpdown'},
  })
    :setPressedCallback(function(control)
      if control == 'climb' then
        player.y = player.y - 32
      end
    end)
    :setReleasedCallback(function(control)
      if control == 'fall' then
        player.y = player.y + 32
      end
    end)
end

function love.update(dt)
  Otokonokontroller:update(dt)
  local relativeX = player.input:get('walkRight') - player.input:get('walkLeft')
  player.x = player.x + relativeX
end

function love.draw()
  love.graphics.rectangle('fill', player.x, player.y, 32, 32)
end
