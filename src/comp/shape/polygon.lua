local Shape = require "comp.shape"

local PolygonShape = inheritsFrom(Shape)

function PolygonShape:init(parent, ...)
    Shape.init(self, parent)
    if select("#", ...) > 0 then
        self.shape = love.physics.newPolygonShape(...)
    end
end

function PolygonShape:getPoints()
    assert(self.shape)
    return self.shape:getPoints()
end

function PolygonShape:validate()
    assert(self.shape)
    return self.shape:validate()
end

function PolygonShape:getName()
    return "PolygonShape"
end

_G.PolygonShape = PolygonShape

return PolygonShape
