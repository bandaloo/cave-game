local h = require "helpers"
local c

local behaviors = {}

function behaviors.link(module)
  c = module
end

function behaviors.chase(self)
  if nearestPlayer ~= nil then
    if h.distance(self.body:getX(), self.body:getY(), nearestPlayer.body:getX(), nearestPlayer.body:getY()) < self.awareness then
      local x, y = h.normalToObject(self, nearestPlayer)
      self.body:applyForce(x * 30, y * 30)
    end
  end
end

return behaviors
