local Otokonokontroller = require 'otokonokontroller'()
local player

local Player = {}

function Player.new()
  return setmetatable({}, {__index = Player})
    :initialize()
end

function Player:initialize()
  self.x = 400
  self.y = 300
  self.speed = 200

  local joystick = love.joystick.getJoystickCount() >= 1 and love.joystick.getJoysticks()[1] or nil
  self.input = Otokonokontroller:newController({
    walkLeft  = {'key:a', 'key:left',  'pad:dpleft', 'axis:leftx-'},
    walkRight = {'key:d', 'key:right', 'pad:dpright', 'axis:leftx+'},
    climb     = {'key:w', 'key:up',    'pad:dpup'},
    fall      = {'key:s', 'key:down',  'pad:dpdown'},
  })
    -- Totally optional: specify a specific joystick to be used with this controller.
    -- If this is omitted, then _all_ joysticks will be used with this controller.
    :setJoystick(joystick)
    :setPressedCallback(function(control)
      if control == 'climb' then
        self.y = self.y - 32
      end
    end)
    :setReleasedCallback(function(control)
      if control == 'fall' then
        self.y = self.y + 32
      end
    end)

  return self
end

function Player:update(dt)
  local x = self.input:get('walkRight') - self.input:get('walkLeft')
  self.x = self.x + (x * self.speed * dt)
  self.input:endFrame()
end

function Player:draw()
  love.graphics.rectangle('fill', self.x, self.y, 32, 32)
end

function love.load()
  Otokonokontroller:registerCallbacks()

  Otokonokontroller:newController({
    quit = {'key:escape'},
  })
    :setPressedCallback(function(control)
      if control == 'quit' then
        love.event.push('quit')
      end
    end)

  player = Player.new()
end

function love.update(dt)
  player:update(dt)
end

function love.draw()
  player:draw()
end
