local controllers = require "controllers"
local window = {}

window.lookingAt = {0,0}
window.panSpeed = 2
window.zoomRatio = 0 --how many pixels a grid "Block" should be
defaultZoomRatio = 0
window.maxZoomRatio = 40
window.zoomSpeed = .1
window.focusedObject = 1
window.freeMode = true
local gridBounds = {0,0}
local cameraMoveSpeed = zoomRatio

function window.updateCamera(objects)
    if controllers.checkControl("prevFocusedObject") then
        if window.freeMode then
            window.zoomRatio = window.maxZoomRatio
        end
        window.freeMode = false
        window.focusedObject = window.focusedObject - 1
        if window.focusedObject <= 0 then
            window.focusedObject = #objects
        end
    elseif controllers.checkControl("nextFocusedObject") then
        if window.freeMode then
            window.zoomRatio = window.maxZoomRatio
        end
        window.freeMode = false
        window.focusedObject = window.focusedObject + 1
        if window.focusedObject > #objects then
            window.focusedObject = 1
        end
    elseif love.keyboard.isDown("\\") then
        window.freeMode = true
    end


    zoomCamera()
    if window.freeMode then
        panCamera()
    else
        trackObject(objects[window.focusedObject])
    end

    window.keepViewInBounds()
end

function trackObject(object)
    local trackX = math.huge
    local trackY = math.huge
    if object.shapeType == "Circle" then
        x = object.body:getX()
        y = object.body:getY()
        trackX = x * (window.zoomRatio/defaultZoomRatio)
        trackY = y * (window.zoomRatio/defaultZoomRatio)
    elseif object.shapeType == "Polygon" then
        x = object.body:getX()
        y = object.body:getY()
        trackX = x * (window.zoomRatio/defaultZoomRatio)
        trackY = y * (window.zoomRatio/defaultZoomRatio)
    else
        window.freeMode = true
    end
    if(trackX ~= math.huge and trackY ~= math.huge) then
        window.lookingAt[1] = trackX - (love.graphics.getWidth() / 2)
        window.lookingAt[2] = trackY - (love.graphics.getHeight() / 2)
    end
end

function zoomCamera()
    oldZoom = window.zoomRatio
    if controllers.checkControl("resetCamera") then
        window.zoomRatio = window.minZoomRatio
    end
    if controllers.checkControl("zoomOut") then
        window.zoomRatio = window.zoomRatio - window.zoomSpeed
    end
    if controllers.checkControl("zoomIn") then
        window.zoomRatio = window.zoomRatio + window.zoomSpeed
    end

    --keep zoom in bounds
    if window.zoomRatio <= window.minZoomRatio then
        window.zoomRatio = window.minZoomRatio
    end
    if window.zoomRatio > window.maxZoomRatio then
        window.zoomRatio = window.maxZoomRatio
    end
    if oldZoom ~= window.zoomRatio and window.freeMode then
        centerZoom(oldZoom)
    end
end

function panCamera()
    dx = 0
    dy = 0
    if controllers.checkControl("panLeft") then
        dx = dx - window.panSpeed
    end
    if controllers.checkControl("panRight") then
        dx = dx + window.panSpeed
    end
    if controllers.checkControl("panUp") then
        dy = dy - window.panSpeed
    end
    if controllers.checkControl("panDown") then
        dy = dy + window.panSpeed
    end

    window.lookingAt[1] = window.lookingAt[1] + dx
    window.lookingAt[2] = window.lookingAt[2] + dy
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
