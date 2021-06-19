local Shape = require "comp.shape"

local ChainShape = inheritsFrom(Shape)

function ChainShape:init(parent, loop, ...)
    Shape.init(self, parent)
    self.shape = love.physics.newChainShape(loop, ...)
end

function ChainShape:getName()
    return "ChainShape"
end

function ChainShape:getChildEdge(index)
    assert(self.shape)
    return self.shape:getChildEdge(index)
end

function ChainShape:getNextVertex()
    assert(self.shape)
    return self.shape:getNextVertex()
end

function ChainShape:getPoint()
    assert(self.shape)
    return self.shape:getPoint()
end

function ChainShape:getPoints()
    assert(self.shape)
    return self.shape:getPoints()
end

function ChainShape:getPreviousVertex()
    assert(self.shape)
    return self.shape:getPreviousVertex()
end

function ChainShape:getVertexCount()
    assert(self.shape)
    return self.shape:getVertexCount()
end

function ChainShape:setNextVertex(x, y)
    assert(self.shape)
    return self.shape:setNextVertex(x, y)
end

function ChainShape:setPreviousVertex(x, y)
    assert(self.shape)
    return self.shape:setPreviousVertex(x, y)
end

_G.ChainShape = ChainShape

return ChainShape
