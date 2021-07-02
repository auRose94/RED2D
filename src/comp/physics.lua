local Component = require "component"
local Fixture = require "comp.fixture"
local PhysicsComp = inheritsFrom(Component)

function PhysicsComp:getName()
    return "PhysicsComp"
end

function PhysicsComp:init(parent, type, ...)
    Component.init(self, parent, ...)
    type = type or "dynamic"
    local ex, ey = Component.getPosition(self)
    local er = Component.getRotation(self)
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

function PhysicsComp:setFixedRotation(v)
    assert(self.body ~= nil, "Body is null")
    return self.body:setFixedRotation(v)
end

function PhysicsComp:setActive(v)
    assert(self.body ~= nil, "Body is null")
    return self.body:setActive(v)
end

function PhysicsComp:setMass(v)
    assert(self.body ~= nil, "Body is null")
    self.mass = v or 0
    self.body:setMass(v or 0)
end

function PhysicsComp:useCCD(v)
    assert(self.body ~= nil, "Body is null")
    return self.body:setBullet(v)
end

function PhysicsComp:getLinearVelocity()
    assert(self.body ~= nil, "Body is null")
    return self.body:getLinearVelocity()
end

function PhysicsComp:getLocalVector(worldX, worldY)
    assert(self.body ~= nil, "Body is null")
    return self.body:getLocalVector(worldX, worldY)
end

function PhysicsComp:getLocalPoint(worldX, worldY)
    assert(self.body ~= nil, "Body is null")
    return self.body:getLocalPoint(worldX, worldY)
end

function PhysicsComp:getWorldPoint(localX, localY)
    assert(self.body ~= nil, "Body is null")
    return self.body:getWorldPoint(localX, localY)
end

function PhysicsComp:getWorldVector(localX, localY)
    assert(self.body ~= nil, "Body is null")
    return self.body:getWorldVector(localX, localY)
end

function PhysicsComp:getContacts()
    assert(self.body ~= nil, "Body is null")
    return self.body:getContacts()
end

function PhysicsComp:setPosition(x, y, z)
    assert(self.body ~= nil, "Body is null")
    Component.setPosition(self, x, y, z)
    self.body:setPosition(x, y)
end

function PhysicsComp:getPosition()
    assert(self.body ~= nil, "Body is null")
    local x, y = self.body:getPosition()
    self.x = x
    self.y = y
    Component.setPosition(self, x, y)
    return self.x, self.y
end

function PhysicsComp:setRotation(r)
    assert(self.body ~= nil, "Body is null")
    Component.setRotation(self, r)
    self.body:setAngle(r)
end

function PhysicsComp:getRotation()
    assert(self.body ~= nil, "Body is null")
    self.r = self.body:getRotation()
    Component.setRotation(self, self.r)
    return self.r
end

function PhysicsComp:setAngularVelocity(v)
    assert(self.body ~= nil, "Body is null")
    self.body:setAngularVelocity(v)
end

function PhysicsComp:applyLinearImpulse(vx, vy)
    assert(self.body ~= nil, "Body is null")
    self.body:applyLinearImpulse(vx, vy)
end

function PhysicsComp:newFixture(shape, density)
    if shape.isa and shape:isa(Shape) then
        return Fixture(self.parent, shape, density)
    end
    return love.physics.newFixture(self.body, shape, density)
end

function PhysicsComp:update(dt)
    --assert(self.body ~= nil, "Body is null")
    if self.body then
        self.lastX = self.x
        self.lastY = self.y
        self.lastR = self.r
        self.x = self.body:getX()
        self.y = self.body:getY()
        self.r = self.body:getAngle()
        self:setPosition(self.x, self.y, 0)
        self:setRotation(self.r)
    end
end

function PhysicsComp:draw()
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
                love.graphics.polygon("fill", self.body:getWorldPoints(shape:getPoints()))
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

function PhysicsComp:destroy()
    if self.body then
        self.body:release()
        self.body = nil
    end
    Component.destroy(self)
end

_G.PhysicsComp = PhysicsComp

return PhysicsComp
