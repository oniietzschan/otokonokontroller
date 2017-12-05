require 'busted'

local OtokonokontrollerFactory = require 'otokonokontroller'

describe('Otokonokontroller:', function()
  local Otokonokontroller
  local joystick
  local anotherJoystick

  before_each(function()
    Otokonokontroller = OtokonokontrollerFactory()
    _G.love = {}
    joystick        = {typeOf = function(self, t) return t == 'Joystick' end}
    anotherJoystick = {typeOf = function(self, t) return t == 'Joystick' end}
  end)

  describe('When creating a new controller', function()
    local controller

    before_each(function()
      controller = Otokonokontroller:newController()
    end)

    it('Should initialize successfully', function()
      -- Maybe check something here later.
    end)

    it('Public methods should error with invalid arguments', function()
      assert.error(function() controller:setControls('(๑・∀・๑)') end)
      assert.error(function() controller:setJoystick({typeOf = '(◡‿◡✿)'}) end)
      assert.error(function() controller:setPressedCallback('★~(◡﹏◕✿)') end)
      assert.error(function() controller:setReleasedCallback('(づ｡◕‿‿◕｡)づ') end)
    end)
  end)

  describe('When calling Otokonokontroller:registerCallbacks()', function()
    describe('When no functions exist yet', function()
      it('Should define new functions', function()
        Otokonokontroller:registerCallbacks()
        assert.same('function', type(_G.love.keypressed))
        assert.same('function', type(_G.love.keyreleased))
        assert.same('function', type(_G.love.mousepressed))
        assert.same('function', type(_G.love.mousereleased))
        assert.same('function', type(_G.love.wheelmoved))
        assert.same('function', type(_G.love.gamepadpressed))
        assert.same('function', type(_G.love.gamepadreleased))
        assert.same('function', type(_G.love.gamepadaxis))
      end)
    end)

    describe('When existing functions are present', function()
      local originalKeypressedSpy
      local originalKeyreleasedSpy
      local originalMousepressedSpy
      local originalMousereleasedSpy
      local originalWheelmovedSpy
      local originalGamepadpressedSpy
      local originalGamepadreleasedSpy
      local originalGamepadaxisSpy

      before_each(function()
        originalKeypressedSpy      = spy.new(function() end)
        originalKeyreleasedSpy     = spy.new(function() end)
        originalMousepressedSpy    = spy.new(function() end)
        originalMousereleasedSpy   = spy.new(function() end)
        originalWheelmovedSpy      = spy.new(function() end)
        originalGamepadpressedSpy  = spy.new(function() end)
        originalGamepadreleasedSpy = spy.new(function() end)
        originalGamepadaxisSpy     = spy.new(function() end)
        _G.love = {
          keypressed      = originalKeypressedSpy,
          keyreleased     = originalKeyreleasedSpy,
          mousepressed    = originalMousepressedSpy,
          mousereleased   = originalMousereleasedSpy,
          wheelmoved      = originalWheelmovedSpy,
          gamepadpressed  = originalGamepadpressedSpy,
          gamepadreleased = originalGamepadreleasedSpy,
          gamepadaxis     = originalGamepadaxisSpy,
        }
        Otokonokontroller:registerCallbacks()
      end)

      it('Should replace and wrap all original functions', function()
        assert.not_same(originalKeypressedSpy, _G.love.keypressed)
        assert.not_same(originalKeyreleasedSpy, _G.love.keyreleased)
        assert.not_same(originalMousepressedSpy, _G.love.mousepressed)
        assert.not_same(originalMousereleasedSpy, _G.love.mousereleased)
        assert.not_same(originalWheelmovedSpy, _G.love.wheelmoved)
        assert.not_same(originalGamepadpressedSpy, _G.love.gamepadpressed)
        assert.not_same(originalGamepadreleasedSpy, _G.love.gamepadreleased)
        assert.not_same(originalGamepadaxisSpy, _G.love.gamepadaxis)
      end)

      it('Should call original function when calling the wrapped version', function()
        _G.love.keypressed('a')
        assert.spy(originalKeypressedSpy).was_called_with('a')
        _G.love.keyreleased('b')
        assert.spy(originalKeyreleasedSpy).was_called_with('b')
        _G.love.mousepressed(0, 0, 1, false)
        assert.spy(originalMousepressedSpy).was_called_with(0, 0, 1, false)
        _G.love.mousereleased(0, 0, 1, false)
        assert.spy(originalMousereleasedSpy).was_called_with(0, 0, 1, false)
        _G.love.wheelmoved(1, 0)
        assert.spy(originalWheelmovedSpy).was_called_with(1, 0)
        _G.love.gamepadpressed(joystick, 'dpup')
        assert.spy(originalGamepadpressedSpy).was_called_with(joystick, 'dpup')
        _G.love.gamepadreleased(joystick, 'dpdown')
        assert.spy(originalGamepadreleasedSpy).was_called_with(joystick, 'dpdown')
        _G.love.gamepadaxis(joystick, 'leftx', 0.5)
        assert.spy(originalGamepadaxisSpy).was_called_with(joystick, 'leftx', 0.5)
      end)
    end)
  end)

  describe('When triggering input callbacks', function()
    local controller
    local callbackSpy
    local callback

    before_each(function()
      Otokonokontroller:registerCallbacks()
      controller = Otokonokontroller:newController()
      callbackSpy = spy.new(function() end)
      callback = function(...) callbackSpy(...) end
    end)

    it('Should do nothing when input events happen without any defined callbacks', function()
      controller:setControls({
        one = {'key:a', 'pad:x', 'mouse:1'},
      })
      _G.love.keypressed('a')
      _G.love.keyreleased('a')
      _G.love.gamepadpressed(joystick, 'x')
      _G.love.gamepadreleased(joystick, 'x')
      _G.love.mousepressed(0, 0, 1, false)
      _G.love.mousereleased(0, 0, 1, false)
    end)

    describe('When handling keyboard events', function()
      before_each(function()
        controller:setControls({
          one = {'key:a'},
          two = {'key:b', 'key:c'},
        })
      end)

      it('Should execute pressed callback when key is pressed', function()
        controller:setPressedCallback(callback)
        _G.love.keypressed('a')
        assert.spy(callbackSpy).was_called_with('one')
        _G.love.keypressed('c')
        assert.spy(callbackSpy).was_called_with('two')
      end)

      it('Should execute released callback when key is released', function()
        controller:setReleasedCallback(callback)
        _G.love.keypressed('a')
        _G.love.keyreleased('a')
        assert.spy(callbackSpy).was_called_with('one')
        _G.love.keypressed('c')
        _G.love.keyreleased('c')
        assert.spy(callbackSpy).was_called_with('two')
      end)

      it('get(), pressed(), down(), and released() should return expected values', function()
        assert.same(0,     controller:get('one'))
        assert.same(false, controller:pressed('one'))
        assert.same(false, controller:down('one'))
        assert.same(false, controller:released('one'))
        controller:endFrame()

        _G.love.keypressed('a')
        assert.same(1,     controller:get('one'))
        assert.same(true,  controller:pressed('one'))
        assert.same(true,  controller:down('one'))
        assert.same(false, controller:released('one'))
        controller:endFrame()

        assert.same(1,     controller:get('one'))
        assert.same(false, controller:pressed('one'))
        assert.same(true,  controller:down('one'))
        assert.same(false, controller:released('one'))
        controller:endFrame()

        _G.love.keyreleased('a')
        assert.same(0,     controller:get('one'))
        assert.same(false, controller:pressed('one'))
        assert.same(false, controller:down('one'))
        assert.same(true,  controller:released('one'))
        controller:endFrame()

        _G.love.keypressed('a')
        _G.love.keyreleased('a')
        assert.same(0,     controller:get('one'))
        assert.same(true,  controller:pressed('one'))
        assert.same(false, controller:down('one'))
        assert.same(true,  controller:released('one'))
        controller:endFrame()
      end)
    end)

    describe('When handling mouse events', function()
      before_each(function()
        controller:setControls({
          one = {'mouse:1'},
          two = {'mouse:2', 'mouse:3'},
        })
      end)

      it('Should execute pressed callback when button is pressed', function()
        controller:setPressedCallback(callback)
        _G.love.mousepressed(0, 0, 1, false)
        assert.spy(callbackSpy).was_called_with('one')
        _G.love.mousepressed(0, 0, 3, false)
        assert.spy(callbackSpy).was_called_with('two')
      end)

      it('Should execute released callback when button is released', function()
        controller:setReleasedCallback(callback)
        _G.love.mousepressed(0, 0, 1, false)
        _G.love.mousereleased(0, 0, 1, false)
        assert.spy(callbackSpy).was_called_with('one')
        _G.love.mousepressed(0, 0, 3, false)
        _G.love.mousereleased(0, 0, 3, false)
        assert.spy(callbackSpy).was_called_with('two')
      end)

      it('get(), pressed(), down(), and released() should return expected values', function()
        assert.same(0,     controller:get('one'))
        assert.same(false, controller:pressed('one'))
        assert.same(false, controller:down('one'))
        assert.same(false, controller:released('one'))
        controller:endFrame()

        _G.love.mousepressed(0, 0, 1, false)
        assert.same(1,     controller:get('one'))
        assert.same(true,  controller:pressed('one'))
        assert.same(true,  controller:down('one'))
        assert.same(false, controller:released('one'))
        controller:endFrame()

        assert.same(1,     controller:get('one'))
        assert.same(false, controller:pressed('one'))
        assert.same(true,  controller:down('one'))
        assert.same(false, controller:released('one'))
        controller:endFrame()

        _G.love.mousereleased(0, 0, 1, false)
        assert.same(0,     controller:get('one'))
        assert.same(false, controller:pressed('one'))
        assert.same(false, controller:down('one'))
        assert.same(true,  controller:released('one'))
        controller:endFrame()

        _G.love.mousepressed(0, 0, 1, false)
        _G.love.mousereleased(0, 0, 1, false)
        assert.same(0,     controller:get('one'))
        assert.same(true,  controller:pressed('one'))
        assert.same(false, controller:down('one'))
        assert.same(true,  controller:released('one'))
        controller:endFrame()
      end)
    end)

    describe('When handling mousewheel events', function()
      before_each(function()
        controller:setControls({
          xpos = {'mousewheel:x+'},
          xneg = {'mousewheel:x-'},
          ypos = {'mousewheel:y+'},
          yneg = {'mousewheel:y-'},
        })
      end)

      it('Should execute both pressed and released callback when wheel is moved', function()
        local pressedCallbackSpy = spy.new(function() end)
        local releasedCallbackSpy = spy.new(function() end)
        local pressedCallback = function(...) pressedCallbackSpy(...) end
        local releasedCallback = function(...) releasedCallbackSpy(...) end
        controller:setPressedCallback(pressedCallback)
        controller:setReleasedCallback(releasedCallback)

        _G.love.wheelmoved(1, 0)
        assert.spy(pressedCallbackSpy).was_called(1)
        assert.spy(releasedCallbackSpy).was_called(1)
        assert.spy(pressedCallbackSpy).was_called_with('xpos')
        assert.spy(releasedCallbackSpy).was_called_with('xpos')
        _G.love.wheelmoved(-1, 0)
        assert.spy(pressedCallbackSpy).was_called(2)
        assert.spy(releasedCallbackSpy).was_called(2)
        assert.spy(pressedCallbackSpy).was_called_with('xneg')
        assert.spy(releasedCallbackSpy).was_called_with('xneg')
        _G.love.wheelmoved(0, 1)
        assert.spy(pressedCallbackSpy).was_called(3)
        assert.spy(releasedCallbackSpy).was_called(3)
        assert.spy(pressedCallbackSpy).was_called_with('ypos')
        assert.spy(releasedCallbackSpy).was_called_with('ypos')
        _G.love.wheelmoved(0, -1)
        assert.spy(pressedCallbackSpy).was_called(4)
        assert.spy(releasedCallbackSpy).was_called(4)
        assert.spy(pressedCallbackSpy).was_called_with('yneg')
        assert.spy(releasedCallbackSpy).was_called_with('yneg')
        _G.love.wheelmoved(0, -1)
        assert.spy(pressedCallbackSpy).was_called(5)
        assert.spy(releasedCallbackSpy).was_called(5)
      end)

      it('pressed() should return expected value', function()
        -- Note: get(), down(), and released() have undefined behaviour right now.
        assert.same(false, controller:pressed('xpos'))
        assert.same(false, controller:released('xpos'))
        assert.same(false, controller:pressed('xneg'))
        assert.same(false, controller:released('xneg'))
        assert.same(false, controller:pressed('ypos'))
        assert.same(false, controller:released('ypos'))
        assert.same(false, controller:pressed('yneg'))
        assert.same(false, controller:released('yneg'))
        controller:endFrame()

        _G.love.wheelmoved(1, 0)
        assert.same(true, controller:pressed('xpos'))
        assert.same(true, controller:released('xpos'))
        assert.same(false, controller:pressed('xneg'))
        assert.same(false, controller:released('xneg'))
        assert.same(false, controller:pressed('ypos'))
        assert.same(false, controller:released('ypos'))
        assert.same(false, controller:pressed('yneg'))
        assert.same(false, controller:released('yneg'))
        controller:endFrame()

        _G.love.wheelmoved(1, 0)
        assert.same(true, controller:pressed('xpos'))
        assert.same(true, controller:released('xpos'))
        assert.same(false, controller:pressed('xneg'))
        assert.same(false, controller:released('xneg'))
        assert.same(false, controller:pressed('ypos'))
        assert.same(false, controller:released('ypos'))
        assert.same(false, controller:pressed('yneg'))
        assert.same(false, controller:released('yneg'))
        controller:endFrame()

        _G.love.wheelmoved(-1, 0)
        assert.same(false, controller:pressed('xpos'))
        assert.same(false, controller:released('xpos'))
        assert.same(true, controller:pressed('xneg'))
        assert.same(true, controller:released('xneg'))
        assert.same(false, controller:pressed('ypos'))
        assert.same(false, controller:released('ypos'))
        assert.same(false, controller:pressed('yneg'))
        assert.same(false, controller:released('yneg'))
        controller:endFrame()

        _G.love.wheelmoved(0, 1)
        _G.love.wheelmoved(0, -1)
        assert.same(false, controller:pressed('xpos'))
        assert.same(false, controller:released('xpos'))
        assert.same(false, controller:pressed('xneg'))
        assert.same(false, controller:released('xneg'))
        assert.same(true, controller:pressed('ypos'))
        assert.same(true, controller:released('ypos'))
        assert.same(true, controller:pressed('yneg'))
        assert.same(true, controller:released('yneg'))
        controller:endFrame()
      end)
    end)

    describe('When handling gamepad button events', function()
      before_each(function()
        controller
          :setControls({
            one = {'pad:a'},
            two = {'pad:x', 'pad:y'},
          })
          :setJoystick(joystick)
      end)

      it('Should execute pressed callback when button is pressed', function()
        controller:setPressedCallback(callback)
        _G.love.gamepadpressed(joystick, 'a')
        assert.spy(callbackSpy).was_called_with('one')
        _G.love.gamepadpressed(joystick, 'y')
        assert.spy(callbackSpy).was_called_with('two')
      end)

      it('Should execute released callback when button is released', function()
        controller:setReleasedCallback(callback)
        _G.love.gamepadpressed(joystick, 'a')
        _G.love.gamepadreleased(joystick, 'a')
        assert.spy(callbackSpy).was_called_with('one')
        _G.love.gamepadpressed(joystick, 'y')
        _G.love.gamepadreleased(joystick, 'y')
        assert.spy(callbackSpy).was_called_with('two')
      end)

      it('get(), pressed(), down(), and released() should return expected values', function()
        assert.same(0,     controller:get('one'))
        assert.same(false, controller:pressed('one'))
        assert.same(false, controller:down('one'))
        assert.same(false, controller:released('one'))
        controller:endFrame()

        _G.love.gamepadpressed(joystick, 'a')
        assert.same(1,     controller:get('one'))
        assert.same(true,  controller:pressed('one'))
        assert.same(true,  controller:down('one'))
        assert.same(false, controller:released('one'))
        controller:endFrame()

        assert.same(1,     controller:get('one'))
        assert.same(false, controller:pressed('one'))
        assert.same(true,  controller:down('one'))
        assert.same(false, controller:released('one'))
        controller:endFrame()

        _G.love.gamepadreleased(joystick, 'a')
        assert.same(0,     controller:get('one'))
        assert.same(false, controller:pressed('one'))
        assert.same(false, controller:down('one'))
        assert.same(true,  controller:released('one'))
        controller:endFrame()

        _G.love.gamepadpressed(joystick, 'a')
        _G.love.gamepadreleased(joystick, 'a')
        assert.same(0,     controller:get('one'))
        assert.same(true,  controller:pressed('one'))
        assert.same(false, controller:down('one'))
        assert.same(true,  controller:released('one'))
        controller:endFrame()
      end)

      describe('When controller has no joystick defined', function()
        before_each(function()
          controller:setJoystick(nil)
        end)

        it('Should do nothing when button is pressed on a joystick', function()
          controller:setPressedCallback(callback)
          _G.love.gamepadpressed(joystick, 'a')
          assert.spy(callbackSpy).was_not_called()
          _G.love.gamepadpressed(joystick, 'y')
          assert.spy(callbackSpy).was_not_called()
        end)

        it('Should do nothing when button is released on a joystick', function()
          controller:setReleasedCallback(callback)
          _G.love.gamepadpressed(joystick, 'a')
          _G.love.gamepadreleased(joystick, 'a')
          assert.spy(callbackSpy).was_not_called()
          _G.love.gamepadpressed(joystick, 'y')
          _G.love.gamepadreleased(joystick, 'y')
          assert.spy(callbackSpy).was_not_called()
        end)
      end)

      describe('When controller has a joystick defined', function()
        before_each(function()
          controller:setJoystick(joystick)
        end)

        it('Should do nothing when button is pressed on some other joystick', function()
          controller:setPressedCallback(callback)
          _G.love.gamepadpressed(anotherJoystick, 'a')
          assert.spy(callbackSpy).was_not_called()
          _G.love.gamepadpressed(anotherJoystick, 'y')
          assert.spy(callbackSpy).was_not_called()
        end)

        it('Should do nothing when button is released on some other joystick', function()
          controller:setReleasedCallback(callback)
          _G.love.gamepadpressed(anotherJoystick, 'a')
          _G.love.gamepadreleased(anotherJoystick, 'a')
          assert.spy(callbackSpy).was_not_called()
          _G.love.gamepadpressed(anotherJoystick, 'y')
          _G.love.gamepadreleased(anotherJoystick, 'y')
          assert.spy(callbackSpy).was_not_called()
        end)
      end)

      describe('When controller has joystick set to "all"', function()
        before_each(function()
          controller:setJoystick('all')
        end)

        it('Should call pressed callback when button is pressed on any joystick', function()
          controller:setPressedCallback(callback)
          _G.love.gamepadpressed(joystick, 'a')
          assert.spy(callbackSpy).was_called(1)
          _G.love.gamepadpressed(anotherJoystick, 'y')
          assert.spy(callbackSpy).was_called(2)
        end)

        it('Should call released callback when button is released on any joystick', function()
          controller:setReleasedCallback(callback)
          _G.love.gamepadpressed(joystick, 'a')
          _G.love.gamepadreleased(joystick, 'a')
          assert.spy(callbackSpy).was_called(1)
          _G.love.gamepadpressed(anotherJoystick, 'y')
          _G.love.gamepadreleased(anotherJoystick, 'y')
          assert.spy(callbackSpy).was_called(2)
        end)
      end)
    end)

    describe('When handling gamepad axis events', function()
      local neutral        = 0
      local beforeDeadzone = 0.05
      local afterDeadzone  = 0.2
      local fullOn         = 1
      local leftBeforeDeadzone = beforeDeadzone * -1
      local leftAfterDeadzone  = afterDeadzone  * -1
      local leftFullOn         = fullOn         * -1
      local rightBeforeDeadzone = beforeDeadzone
      local rightAfterDeadzone  = afterDeadzone
      local rightFullOn         = fullOn

      before_each(function()
        controller
          :setControls({
            left = {'axis:leftx-'},
            right = {'axis:leftx+'},
          })
          :setJoystick(joystick)
      end)

      it('Should execute pressed callback when axis is moved past deadzone', function()
        controller:setPressedCallback(callback)
        _G.love.gamepadaxis(joystick, 'leftx', leftBeforeDeadzone)
        assert.spy(callbackSpy).was_called(0)
        _G.love.gamepadaxis(joystick, 'leftx', leftAfterDeadzone)
        assert.spy(callbackSpy).was_called(1)
        assert.spy(callbackSpy).was_called_with('left')
        _G.love.gamepadaxis(joystick, 'leftx', neutral)
        assert.spy(callbackSpy).was_called(1)
        _G.love.gamepadaxis(joystick, 'leftx', rightBeforeDeadzone)
        assert.spy(callbackSpy).was_called(1)
        _G.love.gamepadaxis(joystick, 'leftx', rightAfterDeadzone)
        assert.spy(callbackSpy).was_called(2)
        assert.spy(callbackSpy).was_called_with('right')
      end)

      it('Should execute released callback when axis is released', function()
        controller:setReleasedCallback(callback)
        _G.love.gamepadaxis(joystick, 'leftx', leftAfterDeadzone)
        assert.spy(callbackSpy).was_called(0)
        _G.love.gamepadaxis(joystick, 'leftx', leftBeforeDeadzone)
        assert.spy(callbackSpy).was_called(1)
        assert.spy(callbackSpy).was_called_with('left')
        _G.love.gamepadaxis(joystick, 'leftx', neutral)
        assert.spy(callbackSpy).was_called(1)
        _G.love.gamepadaxis(joystick, 'leftx', rightAfterDeadzone)
        assert.spy(callbackSpy).was_called(1)
        _G.love.gamepadaxis(joystick, 'leftx', rightBeforeDeadzone)
        assert.spy(callbackSpy).was_called(2)
        assert.spy(callbackSpy).was_called_with('right')
      end)

      it('get(), pressed(), down(), and released() should return expected values', function()
        assert.same(0,     controller:get('left'))
        assert.same(false, controller:pressed('left'))
        assert.same(false, controller:down('left'))
        assert.same(false, controller:released('left'))
        assert.same(0,     controller:get('right'))
        assert.same(false, controller:pressed('right'))
        assert.same(false, controller:down('right'))
        assert.same(false, controller:released('right'))
        controller:endFrame()

        _G.love.gamepadaxis(joystick, 'leftx', leftBeforeDeadzone)
        assert.same(0,     controller:get('left'))
        assert.same(false, controller:pressed('left'))
        assert.same(false, controller:down('left'))
        assert.same(false, controller:released('left'))
        assert.same(0,     controller:get('right'))
        assert.same(false, controller:pressed('right'))
        assert.same(false, controller:down('right'))
        assert.same(false, controller:released('right'))
        controller:endFrame()

        _G.love.gamepadaxis(joystick, 'leftx', leftAfterDeadzone)
        assert.same(afterDeadzone, controller:get('left'))
        assert.same(true,          controller:pressed('left'))
        assert.same(true,          controller:down('left'))
        assert.same(false,         controller:released('left'))
        assert.same(0,             controller:get('right'))
        assert.same(false,         controller:pressed('right'))
        assert.same(false,         controller:down('right'))
        assert.same(false,         controller:released('right'))
        controller:endFrame()

        _G.love.gamepadaxis(joystick, 'leftx', leftFullOn)
        assert.same(fullOn, controller:get('left'))
        assert.same(false,  controller:pressed('left'))
        assert.same(true,   controller:down('left'))
        assert.same(false,  controller:released('left'))
        assert.same(0,      controller:get('right'))
        assert.same(false,  controller:pressed('right'))
        assert.same(false,  controller:down('right'))
        assert.same(false,  controller:released('right'))
        controller:endFrame()

        _G.love.gamepadaxis(joystick, 'leftx', leftBeforeDeadzone)
        assert.same(0,     controller:get('left'))
        assert.same(false, controller:pressed('left'))
        assert.same(false, controller:down('left'))
        assert.same(true,  controller:released('left'))
        assert.same(0,     controller:get('right'))
        assert.same(false, controller:pressed('right'))
        assert.same(false, controller:down('right'))
        assert.same(false, controller:released('right'))
        controller:endFrame()

        _G.love.gamepadaxis(joystick, 'leftx', rightBeforeDeadzone)
        assert.same(0,     controller:get('left'))
        assert.same(false, controller:pressed('left'))
        assert.same(false, controller:down('left'))
        assert.same(false, controller:released('left'))
        assert.same(0,     controller:get('right'))
        assert.same(false, controller:pressed('right'))
        assert.same(false, controller:down('right'))
        assert.same(false, controller:released('right'))
        controller:endFrame()

        _G.love.gamepadaxis(joystick, 'leftx', rightFullOn)
        assert.same(0,      controller:get('left'))
        assert.same(false,  controller:pressed('left'))
        assert.same(false,  controller:down('left'))
        assert.same(false,  controller:released('left'))
        assert.same(fullOn, controller:get('right'))
        assert.same(true,   controller:pressed('right'))
        assert.same(true,   controller:down('right'))
        assert.same(false,  controller:released('right'))
        controller:endFrame()

        _G.love.gamepadaxis(joystick, 'leftx', neutral)
        assert.same(0,     controller:get('left'))
        assert.same(false, controller:pressed('left'))
        assert.same(false, controller:down('left'))
        assert.same(false, controller:released('left'))
        assert.same(0,     controller:get('right'))
        assert.same(false, controller:pressed('right'))
        assert.same(false, controller:down('right'))
        assert.same(true,  controller:released('right'))
        controller:endFrame()

        _G.love.gamepadaxis(joystick, 'leftx', leftFullOn)
        _G.love.gamepadaxis(joystick, 'leftx', rightFullOn)
        _G.love.gamepadaxis(joystick, 'leftx', neutral)
        assert.same(0,     controller:get('left'))
        assert.same(true,  controller:pressed('left'))
        assert.same(false, controller:down('left'))
        assert.same(true,  controller:released('left'))
        assert.same(0,     controller:get('right'))
        assert.same(true,  controller:pressed('right'))
        assert.same(false, controller:down('right'))
        assert.same(true,  controller:released('right'))
        controller:endFrame()
      end)

      describe('When controller has no joystick defined', function()
        before_each(function()
          controller:setJoystick(nil)
        end)

        it('Should do nothing when axis is pushed past deadzone on a joystick', function()
          controller:setPressedCallback(callback)
          _G.love.gamepadaxis(joystick, 'leftx', leftAfterDeadzone)
          assert.spy(callbackSpy).was_not_called()
        end)

        it('Should do nothing when axis is released on a joystick', function()
          controller:setReleasedCallback(callback)
          _G.love.gamepadaxis(joystick, 'leftx', leftAfterDeadzone)
          _G.love.gamepadaxis(joystick, 'leftx', neutral)
          assert.spy(callbackSpy).was_not_called()
        end)
      end)

      describe('When controller has a joystick defined', function()
        before_each(function()
          controller:setJoystick(joystick)
        end)

        it('Should do nothing when axis is pushed past deadzone on some other joystick', function()
          controller:setPressedCallback(callback)
          _G.love.gamepadaxis(anotherJoystick, 'leftx', leftAfterDeadzone)
          assert.spy(callbackSpy).was_not_called()
        end)

        it('Should do nothing when axis is released on some other joystick', function()
          controller:setReleasedCallback(callback)
          _G.love.gamepadaxis(anotherJoystick, 'leftx', leftAfterDeadzone)
          _G.love.gamepadaxis(anotherJoystick, 'leftx', neutral)
          assert.spy(callbackSpy).was_not_called()
        end)
      end)

      describe('When controller has joystick set to "all"', function()
        before_each(function()
          controller:setJoystick('all')
        end)

        it('Should call pressed callback when axis is pushed past deadzone on any joystick', function()
          controller:setPressedCallback(callback)
          _G.love.gamepadaxis(joystick, 'leftx', leftAfterDeadzone)
          assert.spy(callbackSpy).was_called(1)
          _G.love.gamepadaxis(joystick, 'leftx', neutral)
          _G.love.gamepadaxis(anotherJoystick, 'leftx', leftAfterDeadzone)
          assert.spy(callbackSpy).was_called(2)
        end)

        it('Should call released callback when axis is released on any joystick', function()
          controller:setReleasedCallback(callback)
          _G.love.gamepadaxis(joystick, 'leftx', leftAfterDeadzone)
          _G.love.gamepadaxis(joystick, 'leftx', neutral)
          assert.spy(callbackSpy).was_called(1)
          _G.love.gamepadaxis(anotherJoystick, 'leftx', leftAfterDeadzone)
          _G.love.gamepadaxis(anotherJoystick, 'leftx', neutral)
          assert.spy(callbackSpy).was_called(2)
        end)
      end)
    end)
  end)
end)
