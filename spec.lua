require 'busted'

OtokonokontrollerFactory = require 'otokonokontroller'

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
        assert.same('function', type(love.keypressed))
        assert.same('function', type(love.keyreleased))
        assert.same('function', type(love.gamepadpressed))
        assert.same('function', type(love.gamepadreleased))
      end)
    end)

    describe('When existing functions are present', function()
      local originalKeypressedSpy
      local originalKeyreleasedSpy
      local originalGamepadpressedSpy
      local originalGamepadreleasedSpy
      local originalMousepressedSpy
      local originalMousereleasedSpy

      before_each(function()
        originalKeypressedSpy      = spy.new(function() end)
        originalKeyreleasedSpy     = spy.new(function() end)
        originalGamepadpressedSpy  = spy.new(function() end)
        originalGamepadreleasedSpy = spy.new(function() end)
        originalMousepressedSpy    = spy.new(function() end)
        originalMousereleasedSpy   = spy.new(function() end)
        _G.love = {
          keypressed      = originalKeypressedSpy,
          keyreleased     = originalKeyreleasedSpy,
          gamepadpressed  = originalGamepadpressedSpy,
          gamepadreleased = originalGamepadreleasedSpy,
          mousepressed    = originalMousepressedSpy,
          mousereleased   = originalMousereleasedSpy,
        }
        Otokonokontroller:registerCallbacks()
      end)

      it('Should replace and wrap all original functions', function()
        assert.not_same(originalKeypressedSpy, love.keypressed)
        assert.not_same(originalKeyreleasedSpy, love.keyreleased)
        assert.not_same(originalGamepadpressedSpy, love.gamepadpressed)
        assert.not_same(originalGamepadreleasedSpy, love.gamepadreleased)
        assert.not_same(originalMousepressedSpy, love.mousepressed)
        assert.not_same(originalMousereleasedSpy, love.mousereleased)
      end)

      it('Should call original function when calling the wrapped version', function()
        _G.love.keypressed('a')
        assert.spy(originalKeypressedSpy).was_called_with('a')
        _G.love.keyreleased('b')
        assert.spy(originalKeyreleasedSpy).was_called_with('b')
        local joystick = {}
        _G.love.gamepadpressed(joystick, 'dpup')
        assert.spy(originalGamepadpressedSpy).was_called_with(joystick, 'dpup')
        _G.love.gamepadreleased(joystick, 'dpdown')
        assert.spy(originalGamepadreleasedSpy).was_called_with(joystick, 'dpdown')
        _G.love.mousepressed(0, 0, 1, false)
        assert.spy(originalMousepressedSpy).was_called_with(0, 0, 1, false)
        _G.love.mousereleased(0, 0, 1, false)
        assert.spy(originalMousereleasedSpy).was_called_with(0, 0, 1, false)
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
        _G.love.keyreleased('a')
        assert.spy(callbackSpy).was_called_with('one')
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

    describe('When handling gamepad events', function()
      before_each(function()
        controller:setControls({
          one = {'pad:a'},
          two = {'pad:x', 'pad:y'},
        })
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
        _G.love.gamepadreleased(joystick, 'a')
        assert.spy(callbackSpy).was_called_with('one')
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

      describe('When controller has a joystick defined', function()
        before_each(function()
          controller:setJoystick(joystick)
        end)

        it('Should execute pressed callback when button is pressed on that joystick', function()
          controller:setPressedCallback(callback)
          _G.love.gamepadpressed(joystick, 'a')
          assert.spy(callbackSpy).was_called_with('one')
          _G.love.gamepadpressed(joystick, 'y')
          assert.spy(callbackSpy).was_called_with('two')
        end)

        it('Should execute released callback when button is released on that joystick', function()
          controller:setReleasedCallback(callback)
          _G.love.gamepadreleased(joystick, 'a')
          assert.spy(callbackSpy).was_called_with('one')
          _G.love.gamepadreleased(joystick, 'y')
          assert.spy(callbackSpy).was_called_with('two')
        end)

        it('Should execute pressed callback when button is pressed on some other joystick', function()
          controller:setPressedCallback(callback)
          _G.love.gamepadpressed(anotherJoystick, 'a')
          assert.spy(callbackSpy).was_not_called()
          _G.love.gamepadpressed(anotherJoystick, 'y')
          assert.spy(callbackSpy).was_not_called()
        end)

        it('Should execute released callback when button is released on some other joystick', function()
          controller:setReleasedCallback(callback)
          _G.love.gamepadreleased(anotherJoystick, 'a')
          assert.spy(callbackSpy).was_not_called()
          _G.love.gamepadreleased(anotherJoystick, 'y')
          assert.spy(callbackSpy).was_not_called()
        end)
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
        _G.love.mousereleased(0, 0, 1, false)
        assert.spy(callbackSpy).was_called_with('one')
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
  end)
end)
