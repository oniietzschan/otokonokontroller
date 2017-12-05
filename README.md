otokonokontroller
=================

[![Build Status](https://travis-ci.org/oniietzschan/otokonokontroller.svg?branch=master)](https://travis-ci.org/oniietzschan/otokonokontroller)
[![Codecov](https://codecov.io/gh/oniietzschan/otokonokontroller/branch/master/graph/badge.svg)](https://codecov.io/gh/oniietzschan/otokonokontroller)

Otokonokontroller is an input library for Love2d. It aims to support multiple paradigms, allowing one to use both input event callbacks and realtime checks like `pressed()`, `released()`, and `down()`.

Example
-------

```lua
local Otokonokontroller = require 'otokonokontroller'()
local player

function love.load()
  Otokonokontroller:registerCallbacks()

  local globalController = Otokonokontroller:newController({
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
    y = 300,
    speed = 100,
  }
  player.controller = Otokonokontroller:newController({
    walkLeft  = {'key:a', 'key:left',  'pad:dpleft', 'axis:leftx-'},
    walkRight = {'key:d', 'key:right', 'pad:dpright', 'axis:leftx+'},
    climb     = {'key:w', 'key:up',    'pad:dpup'},
    fall      = {'key:s', 'key:down',  'pad:dpdown'},
  })
    -- Specify a specific joystick to be used with this controller.
    -- You can specify the string "all" in order to use every available joystick with this controller.
    -- If this is omitted or set to nil, then no joysticks will be used with this controller.
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
  local x = player.controller:get('walkRight') - player.controller:get('walkLeft')
  player.x = player.x + (x * player.speed * dt)
  player.controller:endFrame()
end

function love.draw()
  love.graphics.rectangle('fill', player.x, player.y, 32, 32)
end
```

Tips and Idiosyncrasies
-----------------------

h4. Mouse Wheel

The mouse wheel is unique in that it does not have any conception of being pressed or released, it only makes complete movements. For this reason, both the pressed and released callbacks will be triggered immediately whenever the mousewheel is moved. `Controller:get()` and `Controller:down()` have undefined behaviour when dealing with the mousewheel.

Todo
----

* Disable controller.
* Detach controller.
