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

local loveCallbacksToWrap = {
  keypressed = function(self, key)
    Otokonokontroller.pressed(self, 'key:' .. key)
  end,
  keyreleased = function(self, key)
    Otokonokontroller.released(self, 'key:' .. key)
  end,
  gamepadpressed = function(self, joystick, button)
    Otokonokontroller.pressed(self, 'pad:' .. button, joystick)
  end,
  gamepadreleased = function(self, joystick, button)
    Otokonokontroller.released(self, 'pad:' .. button, joystick)
  end,
  mousepressed = function(self, x, y, button, isTouch)
    Otokonokontroller.pressed(self, 'mouse:' .. button)
  end,
  mousereleased = function(self, x, y, button, isTouch)
    Otokonokontroller.released(self, 'mouse:' .. button)
  end,
}
function Otokonokontroller:registerCallbacks()
  for callbackName, newFn in pairs(loveCallbacksToWrap) do
    local originalCallbackFn = love[callbackName] or function() end
    love[callbackName] = function(...)
      newFn(self, ...)
      originalCallbackFn(...)
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
  self._pressed = {}
  self._released = {}
  self:_resetPressedAndReleased()
  self._values = {}
  for control, _ in pairs(self._controls) do
    self._values[control] = 0
  end
  return self
end

function Controller:setJoystick(joystick)
  local isJoystick = type(joystick.typeOf) == 'function' and joystick:typeOf('Joystick')
  assert(isJoystick, 'Joystick must be a love2d Joystick, got object of type: ' .. type(joystick))
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

function Controller:endFrame()
  self:_resetPressedAndReleased()
end

function Controller:_resetPressedAndReleased()
  for control, _ in pairs(self._controls) do
    self._pressed[control] = false
    self._released[control] = false
  end
end

function Controller:handlePress(keycode, joystick)
  self:_handleControlEvent(keycode, 1, joystick, '_onPressedFn')
end

function Controller:handleRelease(keycode, joystick)
  self:_handleControlEvent(keycode, 0, joystick, '_onReleasedFn')
end

function Controller:_handleControlEvent(keycode, value, joystick, fnName)
  assert(value >= 0 and value <= 1, 'value must be within 0 - 1, was: ' .. value)
  if joystick and self._joystick and joystick ~= self._joystick then
    return
  end
  for control, binds in pairs(self._controls) do
    for _, bind in ipairs(binds) do repeat
      if keycode ~= bind then
        break
      end
      if self[fnName] then
        self[fnName](control)
      end
      self._values[control] = value
      local key = (value > 0) and '_pressed' or '_released'
      self[key][control] = true
    until true end
  end
end

function Controller:get(control)
  self:_assertControlDefined(control)
  return self._values[control]
end

function Controller:pressed(control)
  self:_assertControlDefined(control)
  return self._pressed[control] == true
end

function Controller:down(control)
  self:_assertControlDefined(control)
  return self._values[control] > 0
end

function Controller:released(control)
  self:_assertControlDefined(control)
  return self._released[control] == true
end

function Controller:_assertControlDefined(control)
  assert(self._controls[control], 'Undefined control: ' .. control)
end



local OtokonokontrollerMetaTable = {
  __index = Otokonokontroller,
}

return function()
  return setmetatable({}, OtokonokontrollerMetaTable)
    :initialize()
end
