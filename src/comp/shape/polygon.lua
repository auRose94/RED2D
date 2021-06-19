local ShapeComponent = require "comp.shape"

local PolygonShapeComponent = inheritsFrom(ShapeComponent)

function PolygonShapeComponent:init(parent, ...)
    ShapeComponent.init(self, parent)
    if select("#", ...) > 0 then
        self.shape = love.physics.newPolygonShape(...)
    end
end

function PolygonShapeComponent:getPoints()
    assert(self.shape)
    return self.shape:getPoints()
end

function PolygonShapeComponent:validate()
    assert(self.shape)
    return self.shape:validate()
end

function PolygonShapeComponent:getName()
    return "PolygonShapeComponent"
end

_G.PolygonShapeComponent = PolygonShapeComponent

return PolygonShapeComponent
