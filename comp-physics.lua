local ComponentClass = require"component"
local FixtureComponent = require"comp-fixture"
local PhysicsComponent = inheritsFrom(ComponentClass)

function PhysicsComponent:getName()
	return "PhysicsComponent"
end

function PhysicsComponent:init(parent, type)
	ComponentClass.init(self, parent)
	type = type or "dynamic"
	local ex, ey = ComponentClass.getPosition(self)
	local er = ComponentClass.getRotation(self)
	self.body = love.physics.newBody(parent.level.world, ex, ey, type)
	assert(self.body ~= nil, "Body is null")
	self.body:setAngle(er)
	self.body:setUserData(parent)
	self.lastX = ex
	self.lastY = ey
	self.lastR = er
	self.x = ex
	self.y = ey
	self.r = er
end

function PhysicsComponent:setFixedRotation(v)
	assert(self.body ~= nil, "Body is null")
	return self.body:setFixedRotation(v)
end

function PhysicsComponent:setActive(v)
	assert(self.body ~= nil, "Body is null")
	return self.body:setActive(v)
end

function PhysicsComponent:setMass(v)
	assert(self.body ~= nil, "Body is null")
	self.mass = v or 0
	self.body:setMass(v or 0)
end

function PhysicsComponent:useCCD(v)
	assert(self.body ~= nil, "Body is null")
	return self.body:setBullet(v)
end

function PhysicsComponent:getLinearVelocity()
	assert(self.body ~= nil, "Body is null")
	return self.body:getLinearVelocity()
end

function PhysicsComponent:getLocalVector(worldX, worldY)
	assert(self.body ~= nil, "Body is null")
	return self.body:getLocalVector(worldX, worldY)
end

function PhysicsComponent:getLocalPoint(worldX, worldY)
	assert(self.body ~= nil, "Body is null")
	return self.body:getLocalPoint(worldX, worldY)
end

function PhysicsComponent:getWorldPoint(localX, localY)
	assert(self.body ~= nil, "Body is null")
	return self.body:getWorldPoint(localX, localY)
end

function PhysicsComponent:getWorldVector(localX, localY)
	assert(self.body ~= nil, "Body is null")
	return self.body:getWorldVector(localX, localY)
end

function PhysicsComponent:getContacts()
	assert(self.body ~= nil, "Body is null")
	return self.body:getContacts()
end

function PhysicsComponent:setPosition(x, y, z)
	assert(self.body ~= nil, "Body is null")
	ComponentClass.setPosition(self, x, y, z)
	self.body:setPosition(x, y)
end

function PhysicsComponent:getPosition()
	assert(self.body ~= nil, "Body is null")
	local x, y = self.body:getPosition()
	self.x = x
	self.y = y
	ComponentClass.setPosition(self, x, y)
	return self.x, self.y
end

function PhysicsComponent:setRotation(r)
	assert(self.body ~= nil, "Body is null")
	ComponentClass.setRotation(self, r)
	self.body:setAngle(r)
end

function PhysicsComponent:getRotation()
	assert(self.body ~= nil, "Body is null")
	self.r = self.body:getRotation()
	ComponentClass.setRotation(self, self.r)
	return self.r
end

function PhysicsComponent:setAngularVelocity(v)
	assert(self.body ~= nil, "Body is null")
	self.body:setAngularVelocity(v)
end

function PhysicsComponent:applyLinearImpulse(vx, vy)
	assert(self.body ~= nil, "Body is null")
	self.body:applyLinearImpulse(vx, vy)
end

function PhysicsComponent:newFixture(shape, density)
	if shape.isa and shape:isa(ShapeComponent) then
		return FixtureComponent(self.parent, shape, density)
	end
	return love.physics.newFixture(self.body, shape, density)
end

function PhysicsComponent:update(dt)
	assert(self.body ~= nil, "Body is null")
	self.lastX = self.x
	self.lastY = self.y
	self.lastR = self.r
	self.x = self.body:getX()
	self.y = self.body:getY()
	self.r = self.body:getAngle()
	self:setPosition(self.x, self.y, 0)
	self:setRotation(self.r)
end

function PhysicsComponent:draw()
	local camera = self.parent.level.camera
	assert(self.body ~= nil, "Body is null")
	if _G.debugDrawPhysics then
		love.graphics.push()
		love.graphics.replaceTransform(camera:getTransform())
		love.graphics.setColor(0.76, 0.18, 0.05, 0.5)
		local fixtureList = self.body:getFixtures()
		for fi = 1, #fixtureList do
			local fixture = fixtureList[fi]
			local shape = fixture:getShape()
			local shapeType = shape:getType()
			if shapeType == "polygon" then
				love.graphics.polygon(
					"fill",
					self.body:getWorldPoints(shape:getPoints())
				)
			elseif shapeType == "circle" then
				local cx, cy = self.body:getWorldPoint(shape:getPoint())
				love.graphics.circle("fill", cx, cy, shape:getRadius())
			end
		end

		local contacts = self.body:getContacts()
		for ci = 1, #contacts do
			local contact = contacts[ci]
			local fixtureA, fixtureB = contact:getFixtures()
			love.graphics.setColor(0, 1, 0, 0.5)
			love.graphics.setPointSize(3)
			love.graphics.points(contact:getPositions())
		end
		love.graphics.pop()
	end
end

function PhysicsComponent:destroy()
	if self.body then
		self.body:release()
		self.body = nil
	end
end

_G.PhysicsComponent = PhysicsComponent

return PhysicsComponent