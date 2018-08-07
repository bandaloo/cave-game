local g = require "generator"



SQUARESIZE = 32
local boardwidth = 40
local boardheight = 22

function love.load(arg)
  love.graphics.setBackgroundColor(0, 0, 0)
  cornerx = (love.graphics.getWidth() - boardwidth * SQUARESIZE) / 2
  cornery = (love.graphics.getHeight() - boardheight * SQUARESIZE) / 2
  board = g.generate(boardwidth, boardheight, 0.35, 100, 'alive')
end

function love.update(dt)
end

function love.draw(dt)
  drawboard(board)
end

function drawboard(board)
  for i = 0, boardwidth - 1 do
    for j = 0, boardheight - 1 do
      if board[i][j] == 1 then
        love.graphics.setColor(255, 255, 255)
        love.graphics.rectangle('fill', i * SQUARESIZE + cornerx, j * SQUARESIZE + cornery, SQUARESIZE, SQUARESIZE)
      end
    end
  end
end
