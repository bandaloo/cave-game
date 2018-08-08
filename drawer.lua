local w = require "window"
local drawer = {}

function drawer.outlinedPoly(verts, width, color)
  scaledVerts = w.scalePolygon(verts)
  love.graphics.setColor(unpack(color))
  love.graphics.polygon('fill', scaledVerts)
  love.graphics.setColor(0, 0, 0)
  love.graphics.setLineWidth(width * w.zoomRatio/defaultZoomRatio)
  love.graphics.polygon('line', scaledVerts)
end

function drawer.outlinedcircle(x, y, radius, width, color)
  sx, sy, sr = w.scaleCircle(x, y, radius)
  love.graphics.setColor(unpack(color))
  love.graphics.circle('fill', sx, sy, sr)
  love.graphics.setColor(0, 0, 0)
  love.graphics.setLineWidth(width * w.zoomRatio/defaultZoomRatio)
  love.graphics.circle('line', sx, sy, sr)
end


return drawer
