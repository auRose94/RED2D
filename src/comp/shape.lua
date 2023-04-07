local Component = require "engine.component"
local Shape = inheritsFrom(Component)

function Shape:init(parent)
    Component.init(self, parent)
    self.shape = nil
    self.body = nil
    self.fixture = nil
end

function Shape:destroy()
    assert(self.shape)
    local response = self.shape:release()
    if response == true then
        self.shape = nil
    end
    Component.destroy(self)
end

function Shape:getName()
    return "Shape"
end

function Shape:computeAABB(tx, ty, tr, childIndex)
    assert(self.shape)
    return self.shape:computeAABB(tx, ty, tr, childIndex)
end

function Shape:computeMass(density)
    assert(self.shape)
    return self.shape:computeMass(density)
end

function Shape:getChildCount()
    assert(self.shape)
    return self.shape:getChildCount()
end

function Shape:getRadius()
    assert(self.shape)
    return self.shape:getRadius()
end

function Shape:getType()
    assert(self.shape)
    return self.shape:getType()
end

function Shape:rayCast(x1, y1, x2, y2, maxFraction, tx, ty, tr, childIndex)
    assert(self.shape)
    return self.shape:rayCast(x1, y1, x2, y2, maxFraction, tx, ty, tr, childIndex)
end

function Shape:testPoint(tx, ty, tr, x, y)
    assert(self.shape)
    return self.shape:testPoint(tx, ty, tr, x, y)
end

_G.Shape = Shape

return Shape
