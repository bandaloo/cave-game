local generator = {}

local DIE = 0
local STAY = 1
local BIRTH = 2

local edgemode

local board1 = {}
local board2 = {}

local boardwidth = 0
local boardheight = 0

local boardtick
local rules = {DIE, DIE, DIE, STAY, STAY, BIRTH, BIRTH, BIRTH, BIRTH}
local dirs = {{1, 0}, {1, 1}, {0, 1}, {-1, 1}, {-1, 0}, {-1, -1}, {0, -1}, {1, -1}}

function makeboard(board)
  for i = 0, boardwidth - 1 do
    board[i] = {}
    for j = 0, boardheight - 1 do
      board[i][j] = 0
    end
  end
end

function checkboard(x, y, board)
  if edgemode == 'wrap' then
    x = x % boardwidth
    y = y % boardheight
  end

  if x < 0 or x > boardwidth - 1 or y < 0 or y > boardheight - 1 then
    if edgemode == 'alive' then
      return 1
    else
      return 0
    end
  end

  return board[x][y]
end

function countneighbors(x, y, board)
  count = 0
  for i = 1, 8 do
    count = count + checkboard(x + dirs[i][1], y + dirs[i][2], board)
  end
  return count
end

function stepboard(oldboard, newboard)
  for i = 0, boardwidth - 1 do
    for j = 0, boardheight - 1 do
      count = countneighbors(i, j, oldboard)
      result = rules[count + 1]
      if result == BIRTH then
        newboard[i][j] = 1
      elseif result == DIE then
        newboard[i][j] = 0
      else
        newboard[i][j] = oldboard[i][j]
      end
    end
  end
end

function randomizeboard(threshhold, board)
  for i = 0, boardwidth - 1 do
    for j = 0, boardheight - 1 do
      roll = love.math.random()
      if roll < threshhold then
        board[i][j] = 1
      end
    end
  end
end

function generator.generate(width, height, threshhold, generations, mode)
  boardtick = true
  boardwidth = width
  boardheight = height
  edgemode = mode
  makeboard(board1)
  makeboard(board2)
  randomizeboard(threshhold, board1)
  for i = 1, generations do
    if boardtick then
      stepboard(board1, board2)
      newboard = board2
    else
      stepboard(board2, board1)
      newboard = board1
    end
    boardtick = not boardtick
  end
  return newboard
end

return generator
