otokonokontroller
=================

[![Build Status](https://travis-ci.org/oniietzschan/otokonokontroller.svg?branch=master)](https://travis-ci.org/oniietzschan/otokonokontroller)
[![Codecov](https://codecov.io/gh/oniietzschan/otokonokontroller/branch/master/graph/badge.svg)](https://codecov.io/gh/oniietzschan/otokonokontroller)

Otokonokontroller is an input library for Love2d. It aims to support multiple paradigms, and allows one to use both pressed and release callbacks and realtime checks like `pressed()`, `released()`, and `down()`.

Example
-------

```lua
local Otokonokontroller = require 'otokonokontroller'()
local player

function love.load()
  Otokonokontroller:registerCallbacks()

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
  local relX = (player.input:get('walkRight') - player.input:get('walkLeft')) * player.speed * dt
  player.x = player.x + relX
  player.input:endFrame()
end

function love.draw()
  love.graphics.rectangle('fill', player.x, player.y, 32, 32)
end
```

Todo
----

* axis
* mousewheel
* Ignore joystick input if none has been set.
* `setJoystick('all')`
