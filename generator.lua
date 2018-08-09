local generator = {}

local DIE = 0
local STAY = 1
local BIRTH = 2

local edgeMode

local board1 = {}
local board2 = {}

local boardWidth = 0
local boardHeight = 0

local boardtick
local rules = {DIE, DIE, DIE, STAY, STAY, BIRTH, BIRTH, BIRTH, BIRTH}
local dirs = {{1, 0}, {1, 1}, {0, 1}, {-1, 1}, {-1, 0}, {-1, -1}, {0, -1}, {1, -1}}

function makeBoard(board)
  for i = 0, boardWidth - 1 do
    board[i] = {}
    for j = 0, boardHeight - 1 do
      board[i][j] = 0
    end
  end
end

function checkBoard(x, y, board)
  if edgeMode == 'wrap' then
    x = x % boardWidth
    y = y % boardHeight
  end

  if x < 0 or x > boardWidth - 1 or y < 0 or y > boardHeight - 1 then
    if edgeMode == 'alive' then
      return 1
    else
      return 0
    end
  end

  return board[x][y]
end

function generator.countNeighbors(x, y, board, directions)
  if directions == nil then
      directions = dirs
  end
  count = 0
  for i = 1, #directions do
    count = count + checkBoard(x + directions[i][1], y + directions[i][2], board)
  end
  return count
end

function stepBoard(oldBoard, newBoard)
  for i = 0, boardWidth - 1 do
    for j = 0, boardHeight - 1 do
      count = generator.countNeighbors(i, j, oldBoard)
      result = rules[count + 1]
      if result == BIRTH then
        newBoard[i][j] = 1
      elseif result == DIE then
        newBoard[i][j] = 0
      else
        newBoard[i][j] = oldBoard[i][j]
      end
    end
  end
end

function randomizeBoard(threshhold, board)
  for i = 0, boardWidth - 1 do
    for j = 0, boardHeight - 1 do
      roll = love.math.random()
      if roll < threshhold then
        board[i][j] = 1
      end
    end
  end
end

function generator.generate(width, height, threshhold, generations, mode)
  boardtick = true
  boardWidth = width
  boardHeight = height
  edgeMode = mode
  makeBoard(board1)
  makeBoard(board2)
  randomizeBoard(threshhold, board1)
  for i = 1, generations do
    if boardtick then
      stepBoard(board1, board2)
      newBoard = board2
    else
      stepBoard(board2, board1)
      newBoard = board1
    end
    boardtick = not boardtick
  end
  return newBoard
end

return generator
