local g = require "generator"
local c = require "constructors"
local controllers = require "controllers"
local w = require "window"

SQUARESIZE = 12.8
MINDT = 0.001
TIMESTEP = 1 / 120
local boardWidth = 100
local boardHeight = 56

local edt = 0 -- extra delta time, for preventing very small timestep
local rdt = 0 -- remainder delta time, for keeping a constant time step

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

function love.load(arg)
  love.graphics.setBackgroundColor(255, 255, 255)
  board = g.generate(boardWidth, boardHeight, 0.35, 100, 'alive')
  fillWorld(board)
  w.setBounds(boardWidth, boardHeight, SQUARESIZE)
  controllers.setupControls()
end

function love.update(dt)
    controllers.updateControls(dt)
	local total = dt
    updatesPerFrame = 0
    local tdt
    local completedStep -- this is true when a full step has been completed
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
      if object.behaviors ~= nil then
        for i, func in ipairs(object.behaviors) do
          func(object)
        end
      end
    end
    world:update(tdt)
    updatesPerFrame = updatesPerFrame + 1
	end
    w.updateCamera(objects)
    if controllers.checkControl("resetGame") then --Regenerate the grid
        resetGame()
    end

    if controllers.checkControl("removeWallCollision") then
        for k,v in pairs(blocks) do
            v.body:destroy()
        end
    end
  edt = total
  rdt = TIMESTEP - tdt
end

function deleteWalls()
    for i,v in ipairs(blocks) do

    end
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
end

function drawBoard(board)
  love.graphics.setColor(0.1, 0.1, 0.1)
  for i = 0, boardWidth - 1 do
    for j = 0, boardHeight - 1 do
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
  for i = 0, boardWidth - 1 do
    for j = 0, boardHeight - 1 do
      if board[i][j] == 1 then
        if g.countNeighbors(i,j,board, {{1, 0},{0, 1},{-1, 0},{0, -1}}) < 4 then
            local block = {}
            block.body = love.physics.newBody(world, i * SQUARESIZE + SQUARESIZE / 2, j * SQUARESIZE + SQUARESIZE / 2)
            block.shape = love.physics.newRectangleShape(0, 0, SQUARESIZE, SQUARESIZE)
            block.fixture = love.physics.newFixture(block.body, block.shape);
            blocks[i .. "," .. j] = block
        end
      end
    end
  end
end
