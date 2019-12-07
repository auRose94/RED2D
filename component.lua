local EntityClass = require "entity"

local ComponentClass = inheritsFrom(nil)

function ComponentClass:setPosition(...)
	assert(self.parent, "No parent")
	self.parent:setPosition(...)
end

function ComponentClass:getPosition()
	assert(self.parent, "No parent")
	return self.parent:getPosition()
end

function ComponentClass:setRotation(r)
	assert(self.parent, "No parent")
	self.parent:setRotation(r)
end

function ComponentClass:getRotation()
	assert(self.parent, "No parent")
	return self.parent:getRotation()
end

function ComponentClass:setScale(...)
	assert(self.parent, "No parent")
	self.parent:setScale(...)
end

function ComponentClass:getScale()
	assert(self.parent, "No parent")
	return self.parent:getScale()
end

function ComponentClass:setSkew(...)
	assert(self.parent, "No parent")
	self.parent:setSkew(...)
end

function ComponentClass:getScew()
	assert(self.parent, "No parent")
	return self.parent:getScew()
end

function ComponentClass:setOrigin(...)
	assert(self.parent, "No parent")
	self.parent:setOrigin(...)
end

function ComponentClass:getOrigin()
	assert(self.parent, "No parent")
	return self.parent:getOrigin()
end

function ComponentClass:getTransform()
	assert(self.parent, "No parent")
	return self.parent:getTransform()
end

function ComponentClass:findChild(name)
	assert(self.parent, "No parent")
	return self.parent:findChild(name)
end

function ComponentClass:getComponent(name)
	assert(self.parent, "No parent")
	return self.parent:getComponent(name)
end

function ComponentClass:addComponent(comp)
	assert(self.parent, "No parent")
	self.parent:addComponent(comp)
end

function ComponentClass:removeComponent(comp)
	assert(self.parent, "No parent")
	self.parent:removeComponent(comp)
end

function ComponentClass:transformPoint(...)
	assert(self.parent, "No parent")
	return self.parent:transformPoint(...)
end

function ComponentClass:inverseTransformPoint(...)
	assert(self.parent, "No parent")
	return self.parent:inverseTransformPoint(...)
end

function ComponentClass:transformNormal(...)
	assert(self.parent, "No parent")
	return self.parent:transformNormal(...)
end

function ComponentClass:inverseTransformNormal(...)
	assert(self.parent, "No parent")
	return self.parent:inverseTransformNormal(...)
end

function ComponentClass:getName()
	return "ComponentClass"
end

function ComponentClass:init(parent)
	assert(self ~= nil)
	assert(parent ~= nil, "No parent")
	assert(EntityClass, "EntityClass is not a global")
	assert(isa(parent, EntityClass), "parent is not an EntityClass")
	self.parent = parent
	local name = self:getName()
	parent:addComponent(self)
end

return ComponentClass