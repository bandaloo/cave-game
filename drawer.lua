local drawer = {}

function drawer.outlinedPoly(verts, width, color)
  love.graphics.setColor(unpack(color))
  love.graphics.polygon('fill', verts)
  love.graphics.setColor(0, 0, 0)
  love.graphics.setLineWidth(width)
  love.graphics.polygon('line', verts)
end

function drawer.outlinedcircle(x, y, radius, width, color)
  love.graphics.setColor(unpack(color))
  love.graphics.circle('fill', x, y, radius)
  love.graphics.setColor(0, 0, 0)
  love.graphics.setLineWidth(width)
  love.graphics.circle('line', x, y, radius)
end


return drawer
