local Component = require "component"
local Fixture = inheritsFrom(Component)

function Fixture:init(parent, shapeComp, density, ...)
    Component.init(self, parent, ...)
    local bodyComp = self:getComponent(require "comp.physics")
    self.fixture = love.physics.newFixture(bodyComp.body, shapeComp.shape, density)
    shapeComp.fixture = self.fixture
    shapeComp.body = bodyComp
end

function Fixture:destroy()
    assert(self.fixture)
    local response = self.fixture:release()
    if response == true then
        self.fixture = nil
    end
    Component.destroy(self)
end

function Fixture:getName()
    return "Fixture"
end

function Fixture:getBody()
    assert(self.fixture)
    return self.fixture:getBody()
end

function Fixture:getBoundingBox()
    assert(self.fixture)
    return self.fixture:getBoundingBox()
end

function Fixture:getCategory()
    assert(self.fixture)
    return self.fixture:getCategory()
end

function Fixture:getDensity()
    assert(self.fixture)
    return self.fixture:getDensity()
end

function Fixture:getFilterData()
    assert(self.fixture)
    return self.fixture:getFilterData()
end

function Fixture:getFriction()
    assert(self.fixture)
    return self.fixture:getFriction()
end

function Fixture:getGroupIndex()
    assert(self.fixture)
    return self.fixture:getGroupIndex()
end

function Fixture:getMask()
    assert(self.fixture)
    return self.fixture:getMask()
end

function Fixture:getMassData()
    assert(self.fixture)
    return self.fixture:getMassData()
end

function Fixture:getRestitution()
    assert(self.fixture)
    return self.fixture:getRestitution()
end

function Fixture:getShape()
    assert(self.fixture)
    return self.fixture:getShape()
end

function Fixture:getUserData()
    assert(self.fixture)
    return self.fixture:getUserData()
end

function Fixture:isDestroyed()
    assert(self.fixture)
    return self.fixture:isDestroyed()
end

function Fixture:isSensor()
    assert(self.fixture)
    return self.fixture:isSensor()
end

function Fixture:rayCast(x1, y1, x2, y2, maxFraction, childIndex)
    assert(self.fixture)
    return self.fixture:rayCast(x1, y1, x2, y2, maxFraction, childIndex)
end

function Fixture:setCategory(c1, ...)
    assert(self.fixture)
    assert(type(c1) == "number")
    return self.fixture:setCategory(c1, ...)
end

function Fixture:setDensity(density)
    assert(self.fixture)
    return self.fixture:setDensity(density)
end

function Fixture:setFilterData(categories, mask, group)
    assert(self.fixture)
    return self.fixture:setFilterData(categories, mask, group)
end

function Fixture:setFriction(friction)
    assert(self.fixture)
    return self.fixture:setFriction(friction)
end

function Fixture:setGroupIndex(group)
    assert(self.fixture)
    assert(type(group) == "number")
    return self.fixture:setGroupIndex(group)
end

function Fixture:setMask(m1, ...)
    assert(self.fixture)
    assert(type(m1) == "number")
    return self.fixture:setMask(m1, ...)
end

function Fixture:setRestitution(restitution)
    assert(self.fixture)
    return self.fixture:setRestitution(restitution)
end

function Fixture:setSensor(sensor)
    assert(self.fixture)
    return self.fixture:setSensor(sensor)
end

function Fixture:setUserData(value)
    assert(self.fixture)
    return self.fixture:setUserData(value)
end

function Fixture:testPoint(x, y)
    assert(self.fixture)
    return self.fixture:testPoint(x, y)
end

_G.Fixture = Fixture

return Fixture
