otokonokontroller
=================

[![Build Status](https://travis-ci.org/oniietzschan/otokonokontroller.svg?branch=master)](https://travis-ci.org/oniietzschan/otokonokontroller)
[![Codecov](https://codecov.io/gh/oniietzschan/otokonokontroller/branch/master/graph/badge.svg)](https://codecov.io/gh/oniietzschan/otokonokontroller)

An input library for love2d.

Example
-------

```lua
local Otokonokontroller = require 'otokonokontroller'()
local player

function love.load()
  Otokonokontroller:registerForLoveCallbacks()

  local globalInput = Otokonokontroller:newController({
    quit = {'key:escape'},
  })
    :setPressedCallback(function(control)
      if control == 'quit' then
        love.event.push('quit')
      end
    end)

  local joystick = love.joystick.getJoysticks()[1]

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
```

Todo
----

* axis
* mousewheel
* `get()`
* `down()`
* `pressed()`
* `released()`

Registering for Love Callbacks (Verbose)
----------------------------------------

This is faster and maybe more flexible, but tedious. Probably just call `Otokonokontroller:registerForLoveCallbacks()` instead.

Also none of these methods exist right now, so do not do this.

```lua
function love.keypressed(key)
  Otokonokontroller:keypressed(key)
end

function love.keyreleased(key)
  Otokonokontroller:keyreleased(key)
end

function love.mousepressed(...)
  Otokonokontroller:mousepressed(...)
end

function love.mousereleased(...)
  Otokonokontroller:mousereleased(...)
end

function love.mousemoved(...)
  Otokonokontroller:mousemoved(...)
end

function love.mousefocus(...)
  Otokonokontroller:mousefocus(...)
end

function love.wheelmoved(...)
  Otokonokontroller:wheelmoved(...)
end

function love.joystickpressed(...)
  Otokonokontroller:joystickpressed(...)
end

function love.joystickreleased(...)
  Otokonokontroller:joystickreleased(...)
end

function love.joystickaxis(...)
  Otokonokontroller:joystickaxis(...)
end

function love.joystickhat(...)
  Otokonokontroller:joystickhat(...)
end

function love.joystickadded(...)
  Otokonokontroller:joystickadded(...)
end

function love.joystickremoved(...)
  Otokonokontroller:joystickremoved(...)
end

function love.gamepadpressed(joystick, button)
  Otokonokontroller:gamepadpressed(joystick, button)
end

function love.gamepadreleased(joystick, button)
  Otokonokontroller:gamepadreleased(joystick, button)
end

function love.gamepadaxis(...)
  Otokonokontroller:gamepadaxis(...)
end
```
