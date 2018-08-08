local g = require "generator"
local c = require "constructors"


SQUARESIZE = 32
local boardWidth = 40
local boardHeight = 22

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
  for key, object in pairs(objects) do
    currentKey = key -- check if i actually need this
    if object.behaviors ~= nil then
      for i, func in ipairs(object.behaviors) do
        func(object)
      end
    end
  end
  world:update(dt)
end

function love.draw(dt)
  drawBoard(board)
  for key, object in pairs(objects) do
    object:draw()
  end
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