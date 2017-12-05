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
    Otokonokontroller.changed(self, 'key:' .. key, 1)
  end,
  keyreleased = function(self, key)
    Otokonokontroller.changed(self, 'key:' .. key, 0)
  end,
  mousepressed = function(self, x, y, button, isTouch)
    Otokonokontroller.changed(self, 'mouse:' .. button, 1)
  end,
  mousereleased = function(self, x, y, button, isTouch)
    Otokonokontroller.changed(self, 'mouse:' .. button, 0)
  end,
  wheelmoved = function(self, x, y)
    local input = 'mousewheel:'
    if x == 1 then
      input = input .. 'x+'
    elseif x == -1 then
      input = input .. 'x-'
    elseif y == 1 then
      input = input .. 'y+'
    elseif y == -1 then
      input = input .. 'y-'
    end
    Otokonokontroller.changed(self, input, 1)
    Otokonokontroller.changed(self, input, 0)
  end,
  gamepadpressed = function(self, joystick, button)
    Otokonokontroller.changed(self, 'pad:' .. button, 1, joystick)
  end,
  gamepadreleased = function(self, joystick, button)
    Otokonokontroller.changed(self, 'pad:' .. button, 0, joystick)
  end,
  gamepadaxis = function(self, joystick, axis, value)
    local positiveValue = math.max(0, value)
    local negativeValue = math.abs(math.min(0, value))
    Otokonokontroller.changed(self, 'axis:' .. axis .. '+', positiveValue, joystick)
    Otokonokontroller.changed(self, 'axis:' .. axis .. '-', negativeValue, joystick)
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

function Otokonokontroller:changed(keycode, value, joystick)
  for _, controller in ipairs(self._controllers) do
    controller:handleChange(keycode, value, joystick)
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
    :setDeadzone(0.1)
    :setPressedCallback(nil)
    :setReleasedCallback(nil)
end

function Controller:setControls(controls)
  assert(type(controls) == 'table', 'Controls must be a table')
  self._controls = controls
  self._pressed = {}
  self._pressedBy = {}
  self._released = {}
  self:_resetPressedAndReleased()
  self._values = {}
  for control, _ in pairs(self._controls) do
    self._values[control] = 0
  end
  return self
end

function Controller:setDeadzone(deadzone)
  assert(deadzone >= 0 and deadzone <= 1, 'deadzone must be within 0 - 1, was: ' .. deadzone)
  self._deadzone = deadzone
  return self
end

function Controller:setJoystick(joystick)
  local isNilOrJoystick = joystick == nil or (type(joystick.typeOf) == 'function' and joystick:typeOf('Joystick'))
  assert(isNilOrJoystick, 'Joystick must be nil or a love2d Joystick, got object of type: ' .. type(joystick))
  self._joystick = joystick
  return self
end

function Controller:setPressedCallback(fn)
  return self:_setControlEventCallback(fn, '_onPressedFn')
end

function Controller:setReleasedCallback(fn)
  return self:_setControlEventCallback(fn, '_onReleasedFn')
end

local _noop = function() end

function Controller:_setControlEventCallback(fn, fnName)
  assert(type(fn) == 'function' or fn == nil, 'Pressed callback must be a function or nil')
  self[fnName] = fn or _noop
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

local PRESSED = 'pressed'
local RELEASED = 'released'

function Controller:handleChange(keycode, value, joystick)
  assert(value >= 0 and value <= 1, 'value must be within 0 - 1, was: ' .. value)
  if joystick and self._joystick and joystick ~= self._joystick then
    return
  end
  for control, binds in pairs(self._controls) do
    for _, bind in ipairs(binds) do repeat
      if keycode ~= bind then
        break -- Continue if keycode is not bound to this control
      end
      if value < self._deadzone then
        if keycode ~= self._pressedBy[control] then
          -- Continue if value is under deadzone AND this input is from another binding besides the last active one.
          -- This check exists to filter out noise from idle joysticks which are jittering with values near zero.
          break
        end
        value = 0
      else
        self._pressedBy[control] = keycode
      end
      local event
      if     value >= self._deadzone and self._values[control] < self._deadzone then
        event = PRESSED
      elseif value < self._deadzone and self._values[control] >= self._deadzone then
        event = RELEASED
      end
      self._values[control] = value
      if     event == PRESSED then
        self._pressed[control] = true
        self._onPressedFn(control)
      elseif event == RELEASED then
        self._released[control] = true
        self._onReleasedFn(control)
      end
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
  return self._values[control] >= self._deadzone
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
