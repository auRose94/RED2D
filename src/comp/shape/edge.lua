local Shape = require "comp.shape"

local EdgeShape = inheritsFrom(Shape)

function EdgeShape:init(parent, x1, y1, x2, y2)
    Shape.init(self, parent)
    self.shape = love.physics.newEdgeShape(x1, y1, x2, y2)
end

function EdgeShape:getName()
    return "EdgeShape"
end

function EdgeShape:getNextVertex()
    assert(self.shape)
    return self.shape:getNextVertex()
end

function EdgeShape:getPoints()
    assert(self.shape)
    return self.shape:getPoints()
end

function EdgeShape:getPreviousVertex()
    assert(self.shape)
    return self.shape:getPreviousVertex()
end

function EdgeShape:setNextVertex(x, y)
    assert(self.shape)
    return self.shape:setNextVertex()
end

function EdgeShape:setPreviousVertex(x, y)
    assert(self.shape)
    return self.shape:setPreviousVertex(x, y)
end

_G.EdgeShape = EdgeShape

return EdgeShape
