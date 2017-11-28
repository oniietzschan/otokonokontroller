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

function Otokonokontroller.registerForLoveCallbacks()
end

function Otokonokontroller.update(dt)
end

local Controller = {}

function Otokonokontroller.newController(...)
  return setmetatable({}, {__index = Controller})
    :initialize(...)
end

function Controller:initialize(controls)
  self._controls = controls
  return self
end

function Controller:get(control)
  return 0
end

function Controller:pressed(control)
  return false
end

function Controller:released(control)
  return false
end

return Otokonokontroller
