local ShapeComponent = require".src.comp-shape"

local CircleShapeComponent = inheritsFrom(ShapeComponent)

function CircleShapeComponent:init(parent, x, y, radius)
	ShapeComponent.init(self, parent)
	self.shape = love.physics.newCircleShape(x, y, radius)
end

function CircleShapeComponent:getName()
	return "CircleShapeComponent"
end

function CircleShapeComponent:getPoint()
	assert(self.shape)
	return self.shape:getPoint()
end

function CircleShapeComponent:getRadius()
	assert(self.shape)
	return self.shape:getRadius()
end

function CircleShapeComponent:setPoint(x, y)
	assert(self.shape)
	return self.shape:setPoint(x, y)
end

function CircleShapeComponent:setRadius(r)
	assert(self.shape)
	return self.shape:setRadius(r)
end

_G.CircleShapeComponent = CircleShapeComponent

return CircleShapeComponent