local g = require "generator"
local c = require "constructors"


SQUARESIZE = 32
MINDT = 0.001
TIMESTEP = 1 / 120
local boardWidth = 40
local boardHeight = 22

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

table.insert(objects, enemy)
table.insert(objects, player)

function love.load(arg)
  love.graphics.setBackgroundColor(255, 255, 255)
  cornerX = (love.graphics.getWidth() - boardWidth * SQUARESIZE) / 2
  cornerY = (love.graphics.getHeight() - boardHeight * SQUARESIZE) / 2
  board = g.generate(boardWidth, boardHeight, 0.35, 100, 'alive')
  fillWorld(board)
end

function love.update(dt)
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
  edt = total
  rdt = TIMESTEP - tdt
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
        love.graphics.rectangle('fill', i * SQUARESIZE + cornerX - 4, j * SQUARESIZE + cornerY - 4, SQUARESIZE + 8, SQUARESIZE + 8)
      end
    end
  end
  love.graphics.setColor(0, 0.4, 0.1)
  for i = 0, boardWidth - 1 do
    for j = 0, boardHeight - 1 do
      if board[i][j] == 1 then
        love.graphics.rectangle('fill', i * SQUARESIZE + cornerX, j * SQUARESIZE + cornerY, SQUARESIZE, SQUARESIZE)
      end
    end
  end
end

function fillWorld(board)
  for i = 0, boardWidth - 1 do
    for j = 0, boardHeight - 1 do
      if board[i][j] == 1 then
        local block = {}
        block.body = love.physics.newBody(world, i * SQUARESIZE + cornerX + SQUARESIZE / 2, j * SQUARESIZE + cornerY + SQUARESIZE / 2)
        block.shape = love.physics.newRectangleShape(0, 0, SQUARESIZE, SQUARESIZE)
        block.fixture = love.physics.newFixture(block.body, block.shape);
      end
    end
  end
end
