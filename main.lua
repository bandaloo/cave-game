local g = require "generator"
local c = require "constructors"
local controllers = require "controllers"
local w = require "window"
local h = require "helpers"
local d = require "drawer"

SQUARESIZE = 12.8
MINDT = 0.001
TIMESTEP = 1 / 120
local boardWidth = 100
local boardHeight = 56

local edt = 0 -- extra delta time, for preventing very small timestep
local rdt = 0 -- remainder delta time, for keeping a constant time step
testText = "test"
-- temporary seed for testing
love.math.setRandomSeed(0)

gameMeter = 64
love.physics.setMeter(gameMeter)
world = love.physics.newWorld(0, 0, false)
objects = {}
player = c.newPlayer(100, 100)
nearestPlayer = player
enemy = c.newEnemyBasic(200, 200)
blocks = {}

table.insert(objects, enemy)
table.insert(objects, player)

-- TODO come back to this
-- spawnSensor = {}
-- spawnSensor.body = love.physics.newBody(world, x, y, 'dynamic')
-- spawnSensor.shape = love.physics.newCircleShape(15)
-- spawnSensor.fixture = love.physics.newFixture(spawnSensor.body, spawnSensor.shape, 2.5)


function love.load(arg)
  love.graphics.setBackgroundColor(255, 255, 255)
  board = g.generate(boardWidth, boardHeight, 0.35, 100, 'alive')
  fillWorld(board)
  w.setBounds(boardWidth, boardHeight, SQUARESIZE)
  controllers.setupControls()
  world:setCallbacks(beginContact)
end

function love.update(dt)
  controllers.updateControls(dt)
	local total = dt
  updatesPerFrame = 0
  local tdt
    --completedStep -- this is true when a full step has been completed
	while total > MINDT do
    completedStep = false
    if rdt ~= 0 then
      tdt = rdt
      rdt = 0
      completedStep = true
    else
      tdt = math.min(TIMESTEP, total) + edt
      edt = 0
      if tdt == TIMESTEP then
        completedStep = true
      end
    end
		total = total - tdt
    for key, object in pairs(objects) do
      if not object.pending then
        object.pending = true
      else
        object.fixture:setSensor(false) -- might move this up
      end
      if object.behaviors ~= nil then
        for i, func in ipairs(object.behaviors) do
          func(object)
        end
      end
      if object.health <= 0 or (object.lifetime ~= nil and object.lifetime < 0) then
        object.destroy(object)
        object.body:destroy()
        objects[key] = nil
      end
      if object.lifetime ~= nil then
        object.lifetime = object.lifetime - dt
      end
    end
    world:update(tdt)
    updatesPerFrame = updatesPerFrame + 1
	end
  w.updateCamera(objects)
  if controllers.checkControl("resetGame") then --Regenerate the grid
    resetGame()
  end

  pos = controllers.checkControl("click")
  if pos then
      local gridX, gridY = w.worldToGridCoordinates(pos[1], pos[2])
      board[gridX][gridY] = 0
      for k,v in pairs(blocks) do
          v.body:destroy()
      end
      fillWorld(board)

      -- if blocks[gridX .. "," .. gridY] ~= nil then
      --     blocks[gridX .. "," .. gridY].body:destroy()
      --     blocks[gridX .. "," .. gridY] = nil
      --     fillWorld(board)
      -- end

  end

  if controllers.checkControl("removeWallCollision") then
      for k,v in pairs(blocks) do
          v.body:destroy()
      end
  end
  edt = total
  rdt = TIMESTEP - tdt
end

function resetGame()
  world = love.physics.newWorld(0, 0, false)
  objects = {}
  player = c.newPlayer(100, 100)
  nearestPlayer = player
  enemy = c.newEnemyBasic(200, 200)
  blocks = {}

  table.insert(objects, enemy)
  table.insert(objects, player)

  board = g.generate(boardWidth, boardHeight, 0.35, 100, 'alive')
  fillWorld(board)
end

function love.draw(dt)
  drawBoard(board)
  for key, object in pairs(objects) do
    object:draw()
  end
  love.graphics.printf(updatesPerFrame, 0, 0, 200, 'left')
  love.graphics.printf(testText, 0, 0, 200, 'left')
end

function drawBoard(board)
  love.graphics.setColor(0.1, 0.1, 0.1)
  for i = 0, boardWidth - 1 do
    for j = 0, boardHeight - 1 do
        if i == 7 and j == 1 then
        end
      if board[i][j] == 1 then
        drawX, drawY = w.boardToWorldCoordinates(i, j)
        love.graphics.rectangle('fill', drawX - 4 * w.zoomRatio/defaultZoomRatio,
                                drawY - 4 * w.zoomRatio/defaultZoomRatio,
                                w.zoomRatio + 8 * w.zoomRatio/defaultZoomRatio,
                                w.zoomRatio + 8 * w.zoomRatio/defaultZoomRatio)
      end
    end
  end
  love.graphics.setColor(0, 0.4, 0.1)
  for i = 0, boardWidth - 1 do
    for j = 0, boardHeight - 1 do
      if board[i][j] == 1 then
        drawX, drawY = w.boardToWorldCoordinates(i, j)
        love.graphics.rectangle('fill', drawX, drawY,
                                w.zoomRatio, w.zoomRatio)
      end
    end
  end
end

function fillWorld(board)
  blocks = {}
  for i = 0, boardWidth - 1 do
    for j = 0, boardHeight - 1 do
      if board[i][j] == 1 then
        if g.countNeighbors(i,j,board, {{1, 0},{0, 1},{-1, 0},{0, -1}}) < 4 then
          local block = {}
          block.body = love.physics.newBody(world, i * SQUARESIZE + SQUARESIZE / 2, j * SQUARESIZE + SQUARESIZE / 2)
          block.shape = love.physics.newRectangleShape(0, 0, SQUARESIZE, SQUARESIZE)
          block.fixture = love.physics.newFixture(block.body, block.shape);
          blocks[i .. "," .. j] = block
        else
          if blocks[i .. "," .. j] then
            blocks[i .. "," .. j].body:destroy()
          end
        end
      end
    end
  end
end

function beginContact(fixture1, fixture2, coll)
  -- this is repetitive so figure out a better way to do this
  local object1 = fixture1:getUserData() -- make this compatible with sensors
  local object2 = fixture2:getUserData()
  sensorCheck(object1)
  sensorCheck(object2)
  if object1 ~= nil and object2 ~= nil then
    collide(object1, object2)
    collide(object2, object1)
  end
end

function collide(object1, object2)
  if object1.collisions[object2.entityType] ~= nil then
    for i, func in ipairs(object1.collisions[object2.entityType]) do
      -- currentKey = i
      func(object1, object2)
    end
  end
end

function sensorCheck(object)
  if object ~= nil then
    if object.fixture:isSensor() then
      testText = "sensor collided"
      object.health = -1
      return
    end
  end
end
