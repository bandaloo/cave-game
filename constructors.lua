local d = require "drawer"
local b = require "behaviors"
local h = require "helpers"
local w = require "window"
local controls = require "controllers"

local constructors = {}

b.link(constructors)

function constructors.newEnemyBasic(x, y)
  local enemy = {}
  enemy.entityType = 'enemy'
  enemy.health = 5
  enemy.awareness = 200
  enemy.color = {0, 1, 0}
  enemy.body = love.physics.newBody(world, x, y, 'dynamic')
  enemy.shape = love.physics.newRectangleShape(0, 0, 20, 20)
  enemy.fixture = love.physics.newFixture(enemy.body, enemy.shape, 2)
  enemy.shapeType = "Polygon"
  enemy.fixture:setRestitution(0.1)
  enemy.body:setLinearDamping(0.4)
  enemy.body:setLinearVelocity(0, 0)
  enemy.body:setMass(0.1)
  enemy.behaviors = {b.chase}
  enemy.draw = function(self)
    d.outlinedPoly({self.body:getWorldPoints(self.shape:getPoints())}, 4, self.color)
  end
  enemy.destroy = b.enemyDestroy
  enemy.collisions = {} -- maybe there could be enemy traps you could place down
  enemy.fixture:setUserData(enemy)
  return enemy
end

function constructors.newPlayer(x, y)
  local player = {}
  player.entityType = 'player'
  player.health = 5
  player.shotTick = 0
  player.shotRate = 50
  player.color = {1, 0, 0}
  player.body = love.physics.newBody(world, x, y, 'dynamic')
  player.shape = love.physics.newCircleShape(15)
  player.shapeType = "Circle"
  player.fixture = love.physics.newFixture(player.body, player.shape, 2.5)
  player.fixture:setRestitution(0.1)
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
    end,
    function(self)
      local mouseX, mouseY = w.screenToWorldCoordinates(love.mouse.getPosition())
      local playerX, playerY = self.body:getPosition()
      local shotX, shotY = h.normalToPoint(playerX, playerY, mouseX, mouseY)
      local bulletX, bulletY = h.scaledNormalToPointPos(playerX, playerY, mouseX, mouseY, 30)
      if completedStep then
        self.shotTick = (self.shotTick + 1) % self.shotRate
      end

      if self.shotTick == 0 then
        local bullet = constructors.newBullet(bulletX, bulletY)
        bullet.body:setLinearVelocity(shotX * 400, shotY * 400)
        bullet.fixture:setSensor(true)
        table.insert(objects, bullet)
        -- in order to spawn an object that disappears if there is no room, set
        -- pending to false and make it a sensor
      end
    end
  }
  player.draw = function(self)
    d.outlinedCircle(self.body:getX(), self.body:getY(), self.shape:getRadius(), 4, player.color)
  end
  player.destroy = b.playerDestroy
  player.collisions = {enemy = {function(self) testText = 'collided' end}}
  player.fixture:setUserData(player)
  return player
end

function constructors.newBullet(x, y)
  local bullet = {}
  bullet.kind = 'bullet'
  bullet.color = {1, 1, 1}
  bullet.health = 1
  bullet.lifetime = 10
  bullet.body = love.physics.newBody(world, x, y, 'dynamic')
  bullet.shape = love.physics.newCircleShape(8)
  bullet.fixture = love.physics.newFixture(bullet.body, bullet.shape, 1)
  bullet.fixture:setRestitution(0.1)
  bullet.body:setLinearDamping(0.4)
  bullet.body:setMass(0.1)
  bullet.fixture:setCategory(2)
  bullet.fixture:setMask(2)
  bullet.draw = function(self)
    d.outlinedCircle(self.body:getX(), self.body:getY(), self.shape:getRadius(), 2, bullet.color)
  end
  bullet.destroy = b.bulletDestroy
  bullet.collisions = {enemy = {}}
  bullet.fixture:setUserData(bullet)
  bullet.pending = false -- name of pending should probably be changed
  return bullet
end

return constructors
