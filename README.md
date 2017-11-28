otokonokontroller
=================

[![Build Status](https://travis-ci.org/oniietzschan/otokonokontroller.svg?branch=master)](https://travis-ci.org/oniietzschan/otokonokontroller)
[![Codecov](https://codecov.io/gh/oniietzschan/otokonokontroller/branch/master/graph/badge.svg)](https://codecov.io/gh/oniietzschan/otokonokontroller)

An input library for love2d.

Example
-------

```lua
local Otokonokontroller = require 'otokonokontroller'
local input
local player

function love.load()
  Otokonokontroller.registerForLoveCallbacks()
  local controls = {
    'walkLeft'  => {'key:left',  'pad:dpleft', 'axis:leftx-'},
    'walkRight' => {'key:right', 'pad:dpleft', 'axis:leftx+'},
    'jump'      => {'key:z',     'pad:a'},
  }
  input = Otokonokontroller.newController(controls)

  player = {
    x = 0,
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
```

Registering for Love Callbacks (Verbose)
-------

This is faster, but tedious.

```lua
function love.keypressed(...)
  Otokonokontroller.keypressed(...)
end

function love.keyreleased(...)
  Otokonokontroller.keyreleased(...)
end

function love.mousepressed(...)
  Otokonokontroller.mousepressed(...)
end

function love.mousereleased(...)
  Otokonokontroller.mousereleased(...)
end

function love.mousemoved(...)
  Otokonokontroller.mousemoved(...)
end

function love.mousefocus(...)
  Otokonokontroller.mousefocus(...)
end

function love.wheelmoved(...)
  Otokonokontroller.wheelmoved(...)
end

function love.joystickpressed(...)
  Otokonokontroller.joystickpressed(...)
end

function love.joystickreleased(...)
  Otokonokontroller.joystickreleased(...)
end

function love.joystickaxis(...)
  Otokonokontroller.joystickaxis(...)
end

function love.joystickhat(...)
  Otokonokontroller.joystickhat(...)
end

function love.joystickadded(...)
  Otokonokontroller.joystickadded(...)
end

function love.joystickremoved(...)
  Otokonokontroller.joystickremoved(...)
end

function love.gamepadpressed(...)
  Otokonokontroller.gamepadpressed(...)
end

function love.gamepadreleased(...)
  Otokonokontroller.gamepadreleased(...)
end

function love.gamepadaxis(...)
  Otokonokontroller.gamepadaxis(...)
end
```
