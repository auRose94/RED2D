local ComponentClass = require "component"
local ShapeComponent = inheritsFrom(ComponentClass)

function ShapeComponent:init(parent)
    ComponentClass.init(self, parent)
    self.shape = nil
    self.body = nil
    self.fixture = nil
end

function ShapeComponent:destroy()
    assert(self.shape)
    local response = self.shape:release()
    if response == true then
        self.shape = nil
    end
end

function ShapeComponent:getName()
    return "ShapeComponent"
end

function ShapeComponent:computeAABB(tx, ty, tr, childIndex)
    assert(self.shape)
    return self.shape:computeAABB(tx, ty, tr, childIndex)
end

function ShapeComponent:computeMass(density)
    assert(self.shape)
    return self.shape:computeMass(density)
end

function ShapeComponent:getChildCount()
    assert(self.shape)
    return self.shape:getChildCount()
end

function ShapeComponent:getRadius()
    assert(self.shape)
    return self.shape:getRadius()
end

function ShapeComponent:getType()
    assert(self.shape)
    return self.shape:getType()
end

function ShapeComponent:rayCast(x1, y1, x2, y2, maxFraction, tx, ty, tr, childIndex)
    assert(self.shape)
    return self.shape:rayCast(x1, y1, x2, y2, maxFraction, tx, ty, tr, childIndex)
end

function ShapeComponent:testPoint(tx, ty, tr, x, y)
    assert(self.shape)
    return self.shape:testPoint(tx, ty, tr, x, y)
end

_G.ShapeComponent = ShapeComponent

return ShapeComponent
