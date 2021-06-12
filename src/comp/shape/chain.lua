local ShapeComponent = require ".src.comp.shape"

local ChainShapeComponent = inheritsFrom(ShapeComponent)

function ChainShapeComponent:init(parent, loop, ...)
    ShapeComponent.init(self, parent)
    self.shape = love.physics.newChainShape(loop, ...)
end

function ChainShapeComponent:getName()
    return "ChainShapeComponent"
end

function ChainShapeComponent:getChildEdge(index)
    assert(self.shape)
    return self.shape:getChildEdge(index)
end

function ChainShapeComponent:getNextVertex()
    assert(self.shape)
    return self.shape:getNextVertex()
end

function ChainShapeComponent:getPoint()
    assert(self.shape)
    return self.shape:getPoint()
end

function ChainShapeComponent:getPoints()
    assert(self.shape)
    return self.shape:getPoints()
end

function ChainShapeComponent:getPreviousVertex()
    assert(self.shape)
    return self.shape:getPreviousVertex()
end

function ChainShapeComponent:getVertexCount()
    assert(self.shape)
    return self.shape:getVertexCount()
end

function ChainShapeComponent:setNextVertex(x, y)
    assert(self.shape)
    return self.shape:setNextVertex(x, y)
end

function ChainShapeComponent:setPreviousVertex(x, y)
    assert(self.shape)
    return self.shape:setPreviousVertex(x, y)
end

_G.ChainShapeComponent = ChainShapeComponent

return ChainShapeComponent
