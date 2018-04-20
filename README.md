otokonokontroller
=================

[![Build Status](https://travis-ci.org/oniietzschan/otokonokontroller.svg?branch=master)](https://travis-ci.org/oniietzschan/otokonokontroller)
[![Codecov](https://codecov.io/gh/oniietzschan/otokonokontroller/branch/master/graph/badge.svg)](https://codecov.io/gh/oniietzschan/otokonokontroller)
![Love Versions](https://img.shields.io/badge/Love2d-11%2C%200.10-blue.svg)

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
  -- IMPORTANT: Controller:pressed() and Controller:released() will not work correctly unless you call endFrame().
  player.controller:endFrame()
end

function love.draw()
  love.graphics.rectangle('fill', player.x, player.y, 32, 32)
end
```

Methods
-------

#### `Otokonokontroller:registerCallbacks()`

Wraps the following `love` callbacks in order to listen for input: `keypressed`, `keyreleased`, `mousepressed`, `mousereleased`, `wheelmoved`, `gamepadpressed`, `gamepadreleased`, and `gamepadaxis`. This should be generally be called only once in `love.load`.

```lua
function love.load()
  Otokonokontroller:registerCallbacks()
end
```

---

#### `Otokonokontroller:newController()`

Creates a new controller object.

```lua
local controller = Otokonokontroller:newController({
  left  = {'key:left'},
  right = {'key:right'},
  jump  = {'key:z'},
})
```

Arguments:

* `controls = {}` `(table)` A table of controls and bindings.

Returns:

* `controller` `(Controller)` The controller which was created.

---

#### `Controller:enable()` and `Controller:disable()`

Enables or disables this controller. A disabled controller will not have its values updated and will not have its pressed or released callbacks triggered.

New controllers start off enabled.

---

#### `Controller:setControls(controls)`

Overwrites all control bindings for this controller.

Arguments:

* `controls = {}` `(table)` A table of controls and bindings.

---

#### `Controller:setDeadzone(deadzone)`

Set the deadzone for this controller. Input values smaller than the deadzone will be ignored. This is most useful for analog sticks and triggers, which tend to have noisy input even when they're not being physically touched.

Note that you can use `Controller:getRaw(control)` to get the pre-deadzone value for a given control.

Arguments:

* `deadzone` `(number)` Should be within 0 and 1.

---

#### `Controller:setJoystick(joystick)`

Set which joystick this controller should listen to. If set to `"all"`, then all this controller will listen to all available joysticks. If set to `nil`, then this controller will not listen to any joysticks.

New controllers start off not listening to any joysticks.

Arguments:

* `joystick` `(Love Joystick, "all", or nil)` Which joystick to use.

---

#### `Controller:setPressedCallback(fn)` and `Controller:setReleasedCallback(fn)`

```lua
controller
  :setPressedCallback(function(control)
    if control == 'fire' then
      player:tryToFireBullet()
    end
  end)
  :setReleasedCallback(function(control)
    if control == 'fire' then
      player:startReloading()
    end
  end)
```

Arguments:

* `callback` `(function)` The callback which will be invoked whenever any control that this controller knows about is pressed or released.

---

#### `Controller:endFrame()`

Resets the internally stored pressed and released values for this controller. This should generally be called at the end of your `love.update()`, or somewhere similar.

Note that calling this may not be strictly necessary. It only affects `Controller:pressed()` and `Controller:released()`.

---

#### `Controller:get(control)`

---

#### `Controller:getRaw(control)`

---

#### `Controller:pressed(control)`

---

#### `Controller:down(control)`

---

#### `Controller:released(control)`

---

#### `Controller:getActiveDevice()`

Tips and Idiosyncrasies
-----------------------

#### Analog Axis

You may wish to treat an entire analog stick like one control, so that it can easily be used for something like moving the player. This library does not currently have any functionality to directly facilitate this. For now, I'll recommend doing something similar to this.

```lua
local Player = {}

function Player:initialize()
  self._x = 100
  self._y = 100
  self._speed = 20
  self._controller = Otokonokontroller:newController({
    moveUp = {'axis:lefty-', 'pad:dpup', 'key:w', 'key:up'},
    moveDown = {'axis:lefty+', 'pad:dpdown', 'key:s', 'key:down'},
    moveLeft = {'axis:leftx-', 'pad:dpleft', 'key:a', 'key:left'},
    moveRight = {'axis:leftx+', 'pad:dpright', 'key:d', 'key:right'},
  })
end

function Player:update()
  local moveX, moveY = self:_getAxisPair('moveUp', 'moveDown', 'moveLeft', 'moveRight')
  self._x = self._x + (self._speed * moveX)
  self._y = self._y + (self._speed * moveY)
end

local DEADZONE = 0.2

function Player:_getAxisPair(up, down, left, right)
  local x = self:_getAxis(right, left)
  local y = self:_getAxis(down, up)
  local length = math.sqrt((x * x) + (y * y))
  if length >= DEADZONE then
    return x, y
  else
    return 0, 0
  end
end

function Player:_getAxis(positive, negative)
  local val = self._controller:get(positive) - self._controller:get(negative)
  local rawVal = self._controller:getRaw(positive) - self._controller:getRaw(negative)
  if math.abs(val) > math.abs(rawVal) then
    return val
  else
    -- Return the raw value if value is not larger than the deadzone for this axis.
    -- This is so that the direction does not "snap" to 90 degree angles when it gets close.
    return rawVal
  end
end
```

---

#### Mouse Wheel

The mouse wheel is unique in that it does not have any conception of being pressed or released, it only makes complete movements. For this reason, both the pressed and released callbacks will be triggered immediately whenever the mousewheel is moved. `Controller:get()` and `Controller:down()` have undefined behaviour when dealing with the mousewheel.

Todo
----

* Detach controller.
* Single axis.
* Paired axes.
