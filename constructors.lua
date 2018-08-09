local d = require "drawer"
local b = require "behaviors"
local h = require "helpers"
local controls = require "controllers"

local constructors = {}

b.link(constructors)

function constructors.newEnemyBasic(x, y)
  local enemy = {}
  enemy.awareness = 200
  enemy.color = {0, 1, 0}
  enemy.body = love.physics.newBody(world, x, y, 'dynamic')
  enemy.shape = love.physics.newRectangleShape(0, 0, 20, 20)
  enemy.fixture = love.physics.newFixture(enemy.body, enemy.shape, 2)
  enemy.shapeType = "Polygon"
  enemy.fixture:setRestitution(0.1)
  enemy.fixture:setUserData(enemy)
  enemy.body:setLinearDamping(0.4)
  enemy.body:setLinearVelocity(0, 0)
  enemy.body:setMass(0.1)
  enemy.behaviors = {b.chase}
  enemy.draw = function(self) d.outlinedPoly({self.body:getWorldPoints(self.shape:getPoints())}, 4, self.color) end
  return enemy
end

function constructors.newPlayer(x, y)
  local player = {}
  player.color = {1, 0, 0}
  player.body = love.physics.newBody(world, x, y, 'dynamic')
  player.shape = love.physics.newCircleShape(15)
  player.shapeType = "Circle"
  player.fixture = love.physics.newFixture(player.body, player.shape, 2.5)
  player.fixture:setRestitution(0.1)
  player.fixture:setUserData(player)
  player.body:setLinearDamping(10)
  player.behaviors = {
    function(self)
      local moveVecX = 0
      local moveVecY = 0
      if controls.checkControl("playerRight") then
        moveVecX = 1
      elseif controls.checkControl("playerLeft") then
        moveVecX = -1
      end
      if controls.checkControl("playerUp") then
        moveVecY = -1
      elseif controls.checkControl("playerDown") then
        moveVecY = 1
      end
      moveVecX, moveVecY = h.normalizeThenScale(moveVecX, moveVecY, 1500)
      self.body:applyForce(moveVecX, moveVecY)
    end
  }
  player.draw = function(self) d.outlinedcircle(self.body:getX(), self.body:getY(), self.shape:getRadius(), 4, player.color) end
  return player
end

return constructors
