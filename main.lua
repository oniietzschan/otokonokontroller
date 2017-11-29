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

  local joystick = love.joystick.getJoystickCount() >= 1 and love.joystick.getJoysticks()[1] or nil

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
    -- Totally optional: specify a specific joystick to be used with this controller.
    -- If this is omitted, then _all_ joysticks will be used with this controller.
    :setJoystick(joystick)
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
