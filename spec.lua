require 'busted'

OtokonokontrollerFactory = require 'otokonokontroller'

describe('Otokonokontroller:', function()
  local Otokonokontroller

  before_each(function()
    Otokonokontroller = OtokonokontrollerFactory()
    _G.love = {}
  end)

  describe('When creating a new controller', function()
    local controller

    before_each(function()
    end)

    it('Should initialize successfully', function()
      controller = Otokonokontroller:newController()
    end)
  end)

  describe('When calling Otokonokontroller:registerForLoveCallbacks()', function()
    describe('When no functions exist yet', function()
      it('Should define new functions', function()
        Otokonokontroller:registerForLoveCallbacks()
        assert.same('function', type(love.keypressed))
        assert.same('function', type(love.keyreleased))
      end)
    end)

    describe('When existing functions are present', function()
      local originalKeypressedSpy
      local originalKeyreleasedSpy

      before_each(function()
        originalKeypressedSpy  = spy.new(function() end)
        originalKeyreleasedSpy = spy.new(function() end)
        _G.love = {
          keypressed = originalKeypressedSpy,
          keyreleased = originalKeyreleasedSpy,
        }
        Otokonokontroller:registerForLoveCallbacks()
      end)

      it('Should replace and wrap all original functions', function()
        assert.not_same(originalKeypressedSpy, love.keypressed)
        assert.not_same(originalKeyreleasedSpy, love.keyreleased)
      end)

      it('Should call original function when calling the wrapped version', function()
        _G.love.keypressed('a')
        assert.spy(originalKeypressedSpy).was_called_with('a')
        _G.love.keyreleased('b')
        assert.spy(originalKeyreleasedSpy).was_called_with('b')
      end)
    end)
  end)

  describe('When triggering input callbacks', function()
    local controller
    local callbackSpy
    local callback

    before_each(function()
      Otokonokontroller:registerForLoveCallbacks()
      controller = Otokonokontroller:newController({
        one = {'key:a'},
        two = {'key:b', 'key:c'},
      })
      callbackSpy = spy.new(function() end)
      callback = function(...) callbackSpy(...) end
    end)

    it('Should execute pressed callback when keyboard key is pressed', function()
      controller:setPressedCallback(callback)
      _G.love.keypressed('a')
      assert.spy(callbackSpy).was_called_with('one')
      _G.love.keypressed('c')
      assert.spy(callbackSpy).was_called_with('two')
    end)

    it('Should execute released callback when keyboard key is released', function()
      controller:setReleasedCallback(callback)
      _G.love.keyreleased('a')
      assert.spy(callbackSpy).was_called_with('one')
      _G.love.keyreleased('c')
      assert.spy(callbackSpy).was_called_with('two')
    end)
  end)
end)
