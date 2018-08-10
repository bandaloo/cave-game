local w = require "window"
local drawer = {}

-- TODO could reduce repeated code here
function drawer.outlinedPoly(verts, width, color, color2)
  local color2 = color2 or {0, 0, 0}
  scaledVerts = w.scalePolygon(verts)
  love.graphics.setColor(unpack(color))
  love.graphics.polygon('fill', scaledVerts)
  love.graphics.setColor(unpack(color2))
  love.graphics.setLineWidth(width * w.zoomRatio/defaultZoomRatio)
  love.graphics.polygon('line', scaledVerts)
end

function drawer.outlinedCircle(x, y, radius, width, color)
  local color2 = color2 or {0, 0, 0}
  sx, sy, sr = w.scaleCircle(x, y, radius)
  love.graphics.setColor(unpack(color))
  love.graphics.circle('fill', sx, sy, sr)
  love.graphics.setColor(unpack(color2))
  love.graphics.setLineWidth(width * w.zoomRatio/defaultZoomRatio)
  love.graphics.circle('line', sx, sy, sr)
end

function drawer.outlinedLine(x1, y1, x2, y2, width1, width2, color, color2)
  local color2 = color2 or {0, 0, 0}
  scaledEndpoints = w.scalePolygon({x1, y1, x2, y2})
  love.graphics.setColor(unpack(color))
  love.graphics.setLineWidth(width1 * w.zoomRatio/defaultZoomRatio)
  love.graphics.line(scaledEndpoints)
  love.graphics.setColor(unpack(color2))
  love.graphics.setLineWidth(width2 * w.zoomRatio/defaultZoomRatio)
  love.graphics.line(scaledEndpoints)
end




return drawer
