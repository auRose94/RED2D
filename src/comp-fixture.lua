local ComponentClass = require ".src.component"
local FixtureComponent = inheritsFrom(ComponentClass)

function FixtureComponent:init(parent, shapeComp, density)
    ComponentClass.init(self, parent)
    local bodyComp = self:getComponent(require ".src.comp-physics")
    self.fixture = love.physics.newFixture(bodyComp.body, shapeComp.shape, density)
    shapeComp.fixture = self.fixture
    shapeComp.body = bodyComp
end

function FixtureComponent:destroy()
    assert(self.fixture)
    local response = self.fixture:release()
    if response == true then
        self.fixture = nil
    end
end

function FixtureComponent:getName()
    return "FixtureComponent"
end

function FixtureComponent:getBody()
    assert(self.fixture)
    return self.fixture:getBody()
end

function FixtureComponent:getBoundingBox()
    assert(self.fixture)
    return self.fixture:getBoundingBox()
end

function FixtureComponent:getCategory()
    assert(self.fixture)
    return self.fixture:getCategory()
end

function FixtureComponent:getDensity()
    assert(self.fixture)
    return self.fixture:getDensity()
end

function FixtureComponent:getFilterData()
    assert(self.fixture)
    return self.fixture:getFilterData()
end

function FixtureComponent:getFriction()
    assert(self.fixture)
    return self.fixture:getFriction()
end

function FixtureComponent:getGroupIndex()
    assert(self.fixture)
    return self.fixture:getGroupIndex()
end

function FixtureComponent:getMask()
    assert(self.fixture)
    return self.fixture:getMask()
end

function FixtureComponent:getMassData()
    assert(self.fixture)
    return self.fixture:getMassData()
end

function FixtureComponent:getRestitution()
    assert(self.fixture)
    return self.fixture:getRestitution()
end

function FixtureComponent:getShape()
    assert(self.fixture)
    return self.fixture:getShape()
end

function FixtureComponent:getUserData()
    assert(self.fixture)
    return self.fixture:getUserData()
end

function FixtureComponent:isDestroyed()
    assert(self.fixture)
    return self.fixture:isDestroyed()
end

function FixtureComponent:isSensor()
    assert(self.fixture)
    return self.fixture:isSensor()
end

function FixtureComponent:rayCast(x1, y1, x2, y2, maxFraction, childIndex)
    assert(self.fixture)
    return self.fixture:rayCast(x1, y1, x2, y2, maxFraction, childIndex)
end

function FixtureComponent:setCategory(c1, ...)
    assert(self.fixture)
    assert(type(c1) == "number")
    return self.fixture:setCategory(c1, ...)
end

function FixtureComponent:setDensity(density)
    assert(self.fixture)
    return self.fixture:setDensity(density)
end

function FixtureComponent:setFilterData(categories, mask, group)
    assert(self.fixture)
    return self.fixture:setFilterData(categories, mask, group)
end

function FixtureComponent:setFriction(friction)
    assert(self.fixture)
    return self.fixture:setFriction(friction)
end

function FixtureComponent:setGroupIndex(group)
    assert(self.fixture)
    assert(type(group) == "number")
    return self.fixture:setGroupIndex(group)
end

function FixtureComponent:setMask(m1, ...)
    assert(self.fixture)
    assert(type(m1) == "number")
    return self.fixture:setMask(m1, ...)
end

function FixtureComponent:setRestitution(restitution)
    assert(self.fixture)
    return self.fixture:setRestitution(restitution)
end

function FixtureComponent:setSensor(sensor)
    assert(self.fixture)
    return self.fixture:setSensor(sensor)
end

function FixtureComponent:setUserData(value)
    assert(self.fixture)
    return self.fixture:setUserData(value)
end

function FixtureComponent:testPoint(x, y)
    assert(self.fixture)
    return self.fixture:testPoint(x, y)
end

_G.FixtureComponent = FixtureComponent

return FixtureComponent
