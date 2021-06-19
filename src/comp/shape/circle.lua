local Shape = require "comp.shape"

local CircleShape = inheritsFrom(Shape)

function CircleShape:init(parent, x, y, radius)
    Shape.init(self, parent)
    self.shape = love.physics.newCircleShape(x, y, radius)
end

function CircleShape:getName()
    return "CircleShape"
end

function CircleShape:getPoint()
    assert(self.shape)
    return self.shape:getPoint()
end

function CircleShape:getRadius()
    assert(self.shape)
    return self.shape:getRadius()
end

function CircleShape:setPoint(x, y)
    assert(self.shape)
    return self.shape:setPoint(x, y)
end

function CircleShape:setRadius(r)
    assert(self.shape)
    return self.shape:setRadius(r)
end

_G.CircleShape = CircleShape

return CircleShape
