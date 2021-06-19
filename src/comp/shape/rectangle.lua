local PolygonShape = require "comp.shape.polygon"

local RectangleShape = inheritsFrom(PolygonShape)

function RectangleShape:init(parent, x, y, width, height, angle)
    PolygonShape.init(self, parent)
    self.shape = love.physics.newRectangleShape(x, y, width, height, angle)
end

function RectangleShape:getName()
    return "RectangleShape"
end

_G.RectangleShape = RectangleShape

return RectangleShape
