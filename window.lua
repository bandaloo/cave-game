local window = {}

window.lookingAt = {0,0}
window.panSpeed = 2
window.zoomRatio = 0 --how many pixels a grid "Block" should be
defaultZoomRatio = 0
window.maxZoomRatio = 100
window.zoomSpeed = .1
local gridBounds = {0,0}
local cameraMoveSpeed = zoomRatio

function window.moveCamera(left, right, up, down, zoomin, zoomout)
    if window.lookingAt[1] == math.huge then
        window.lookingAt[1] = 0
        window.lookingAt[2] = 0
    end

    oldZoom = window.zoomRatio
    if zoomin then
        window.zoomRatio = window.zoomRatio - window.zoomSpeed
    end
    if zoomout then
        window.zoomRatio = window.zoomRatio + window.zoomSpeed
    end

    --keep zoom in bounds
    if window.zoomRatio <= window.minZoomRatio then
        window.zoomRatio = window.minZoomRatio
    end
    if window.zoomRatio > 40 then
        window.zoomRatio = 40
    end
    if oldZoom ~= window.zoomRatio then
        centerZoom(oldZoom)
    end

    dx = 0
    dy = 0
    if left then
        dx = dx - window.panSpeed
    end
    if right then
        dx = dx + window.panSpeed
    end
    if up then
        dy = dy - window.panSpeed
    end
    if down then
        dy = dy + window.panSpeed
    end

    window.lookingAt[1] = window.lookingAt[1] + dx
    window.lookingAt[2] = window.lookingAt[2] + dy

    window.keepViewInBounds()
end

--[[
This converts the center's "World" coordinates to "Grid" coordinates using
the old zoom Ratio, and then converts it back into "world" coordinates with
the new zoom ratio. The difference is how much we need to move the camera by.
]]
function centerZoom(oldZoom)
    local center = {0,0}
    center[1] = love.graphics.getWidth() / 2
    center[2] = love.graphics.getHeight() / 2

    local oldX, oldY = window.boardToWorldCoordinates(
                (center[1] + window.lookingAt[1]) / oldZoom,
                (center[2] + window.lookingAt[2]) / oldZoom)

    window.lookingAt[1] = window.lookingAt[1] - (center[1] - oldX)
    window.lookingAt[2] = window.lookingAt[2] - (center[2] - oldY)

end

function window.keepViewInBounds()
    --size of the screen
    screenSize = {love.graphics.getWidth(), love.graphics.getHeight()}
    --limit of the grid
    highestX = gridBounds[1] * window.zoomRatio
    highestY = gridBounds[2] * window.zoomRatio
    highestX = math.max(highestX - screenSize[1], 0)
    highestY = math.max(highestY - screenSize[2], 0)

    window.lookingAt[1] = math.min(math.max(window.lookingAt[1], 0), highestX)
    window.lookingAt[2] = math.min(math.max(window.lookingAt[2], 0), highestY)

end

function window.setBounds(gridWidth, gridHeight, gridSize)
    defaultZoomRatio = gridSize
    gridBounds = {gridWidth, gridHeight}
    windowWidth, windowHeight = love.window.getMode()
    window.minZoomRatio = math.min(windowWidth/gridWidth, windowHeight/gridHeight)
end

function window.scaleCircle(x, y, radius)
    local scale = window.zoomRatio/defaultZoomRatio
    return (x * scale) - window.lookingAt[1], (y * scale) - window.lookingAt[2], radius*(scale)
end

function window.scalePolygon(verts)
    scale = window.zoomRatio/defaultZoomRatio
    scaledVerts = {}
    for i,v in ipairs(verts) do
        move = 0
        if i%2 ~= 0 then --Assumes 1 indexing, of course
            move = window.lookingAt[1]
        else
            move = window.lookingAt[2]
        end
        scaledVerts[i] = v * scale - move
    end
    return scaledVerts
end

function window.boardToWorldCoordinates(gridX, gridY)
    return gridX * window.zoomRatio - window.lookingAt[1],
            gridY * window.zoomRatio - window.lookingAt[2]
end

function window.worldToGridCoordinates(worldX, worldY)
    return (gridX + window.lookingAt[1]) / window.zoomRatio,
            (gridY + window.lookingAt[2]) / window.zoomRatio
end

return window
