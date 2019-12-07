
local PolygonShapeComponent = require "comp-shape-polygon"

local RectangleShapeComponent = inheritsFrom(PolygonShapeComponent)

function RectangleShapeComponent:init(parent, x, y, width, height, angle)
	PolygonShapeComponent.init(self, parent)
	self.shape = love.physics.newRectangleShape(x, y, width, height, angle)
end

function RectangleShapeComponent:getName()
	return "RectangleShapeComponent"
end

_G.RectangleShapeComponent = RectangleShapeComponent

return RectangleShapeComponent