local Otokonokontroller = {
  _VERSION     = 'otokonokontroller v0.0.0',
  _URL         = 'https://github.com/oniietzschan/otokonokontroller',
  _DESCRIPTION = 'Input library for love2d',
  _LICENSE     = [[
    Massachusecchu... あれっ！ Massachu... chu... chu... License!

    Copyright (c) 1789 shru

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED 【AS IZ】, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE. PLEASE HAVE A FUN AND BE GENTLE WITH THIS SOFTWARE.
  ]]
}

local Controller = {}



function Otokonokontroller:initialize()
  self._controllers = {}
  return self
end

function Otokonokontroller:registerForLoveCallbacks()
  local noop = function() end
  do
    local originalFn = love.keypressed or noop
    love.keypressed = function(key)
      self:pressed('key:' .. key)
      originalFn(key)
    end
  end
  do
    local originalFn = love.keyreleased or noop
    love.keyreleased = function(key)
      self:released('key:' .. key)
      originalFn(key)
    end
  end
  do
    local originalFn = love.gamepadpressed or noop
    love.gamepadpressed = function(joystick, button)
      self:pressed('pad:' .. button, joystick)
      originalFn(joystick, button)
    end
  end
  do
    local originalFn = love.gamepadreleased or noop
    love.gamepadreleased = function(joystick, button)
      self:released('pad:' .. button, joystick)
      originalFn(joystick, button)
    end
  end
  do
    local originalFn = love.mousepressed or noop
    love.mousepressed = function(x, y, button, isTouch)
      self:pressed('mouse:' .. button)
      originalFn(x, y, button, isTouch)
    end
  end
  do
    local originalFn = love.mousereleased or noop
    love.mousereleased = function(x, y, button, isTouch)
      self:released('mouse:' .. button)
      originalFn(x, y, button, isTouch)
    end
  end
end

function Otokonokontroller:pressed(keycode, joystick)
  for _, controller in ipairs(self._controllers) do
    controller:handlePress(keycode, joystick)
  end
end

function Otokonokontroller:released(keycode, joystick)
  for _, controller in ipairs(self._controllers) do
    controller:handleRelease(keycode, joystick)
  end
end

function Otokonokontroller:update(dt)
  return self
end

function Otokonokontroller:newController(...)
  local controller = setmetatable({}, {__index = Controller})
    :initialize(...)
  self:_attachController(controller)
  return controller
end



function Otokonokontroller:_attachController(controller)
  table.insert(self._controllers, controller)
end

function Controller:initialize(controls)
  controls = controls or {}
  return self
    :setControls(controls)
end

function Controller:setControls(controls)
  assert(type(controls) == 'table', 'Controls must be a table')
  self._controls = controls
  return self
end

function Controller:setJoystick(joystick)
  -- TODO: maybe validate that joystick is a joystick
  self._joystick = joystick
  return self
end

function Controller:setPressedCallback(fn)
  return self:_setControlEventCallback(fn, '_onPressedFn')
end

function Controller:setReleasedCallback(fn)
  return self:_setControlEventCallback(fn, '_onReleasedFn')
end

function Controller:_setControlEventCallback(fn, fnName)
  assert(type(fn) == 'function', 'Pressed callback must be a function')
  self[fnName] = fn
  return self
end

function Controller:handlePress(keycode, joystick)
  self:_handleControlEvent(keycode, joystick, '_onPressedFn')
end

function Controller:handleRelease(keycode, joystick)
  self:_handleControlEvent(keycode, joystick, '_onReleasedFn')
end

function Controller:_handleControlEvent(keycode, joystick, fnName)
  local isMissingCallback = self[fnName] == nil
  local isFromAnotherJoystick = joystick and self._joystick and joystick ~= self._joystick
  if isMissingCallback or isFromAnotherJoystick then
    return
  end
  for control, binds in pairs(self._controls) do
    for _, bind in ipairs(binds) do
      if keycode == bind then
        self[fnName](control)
      end
    end
  end
end

function Controller:get(control)
  return 0
end

function Controller:pressed(control)
  return false
end

function Controller:down(control)
  return false
end

function Controller:released(control)
  return false
end



local OtokonokontrollerMetaTable = {
  __index = Otokonokontroller,
}

return function()
  return setmetatable({}, OtokonokontrollerMetaTable)
    :initialize()
end
