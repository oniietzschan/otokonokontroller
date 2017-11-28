require 'busted'

describe('Otokonokontroller:', function()
  local Otokonokontroller

  before_each(function()
    Otokonokontroller = require 'otokonokontroller'
  end)

  describe('When creating a new controller', function()
    local controller

    before_each(function ()
    end)

    it('Should initialize successfully', function ()
      controller = Otokonokontroller.newController()
    end)
  end)
end)
