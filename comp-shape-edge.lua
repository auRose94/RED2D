

local ShapeComponent = require "comp-shape"

local EdgeShapeComponent = inheritsFrom(ShapeComponent)

function EdgeShapeComponent:init(parent, x1, y1, x2, y2)
	ShapeComponent.init(self, parent)
	self.shape = love.physics.newEdgeShape(x1, y1, x2, y2)
end

function EdgeShapeComponent:getName()
	return "EdgeShapeComponent"
end

function EdgeShapeComponent:getNextVertex()
	assert(self.shape)
	return self.shape:getNextVertex()
end

function EdgeShapeComponent:getPoints()
	assert(self.shape)
	return self.shape:getPoints()
end

function EdgeShapeComponent:getPreviousVertex()
	assert(self.shape)
	return self.shape:getPreviousVertex()
end

function EdgeShapeComponent:setNextVertex(x, y)
	assert(self.shape)
	return self.shape:setNextVertex()
end

function EdgeShapeComponent:setPreviousVertex(x, y)
	assert(self.shape)
	return self.shape:setPreviousVertex(x, y)
end

_G.EdgeShapeComponent = EdgeShapeComponent

return EdgeShapeComponent