local Component = require "component"
local PhysicsComp = require "comp.physics"
local PolyShape = require "comp.shape.polygon"
local Inventory = require "comp.inventory"
local StatusWindow = require "comp.status-window"
local HeadComponent = require "comp.head"
local Body = require "comp.body"
local HeadDroneData = require "head.red"
local BodyDroneData = require "body.drone"
local input = require "input"

local EnemyDrone = inheritsFrom(Body)

function EnemyDrone:getName()
    return "EnemyDrone"
end

function EnemyDrone:init(parent, playerIndex, joystickIndex, ...)
    Body.init(self, parent, BodyDroneData, ...)
    self.parent.drawOrder = 1

    self:setScale(2, 2)

    self.inventory = Inventory(parent, self, true)

    -- self.headEntity:setPosition(8, 8)
    local headParent = self:findChild("head")
    assert(headParent, "No head point found")
    --local headComp = HeadComponent(headParent, HeadDroneData)
    --self.headComp = headComp

    local width = 1000
    local ext = 500
    local leftVerts = {0.0, 0.0, width, ext, width, -ext}
    self.viewLeftShape = love.physics.newPolygonShape(leftVerts)
    self.viewLeftFixture = love.physics.newFixture(self.physComp.body, self.viewLeftShape, 0)
    self.viewLeftFixture:setSensor(true)
    self.viewLeftFixture:setUserData(self)

    local rightVerts = {0.0, 0.0, -width, ext, -width, -ext}
    self.viewRightShape = love.physics.newPolygonShape(rightVerts)
    self.viewRightFixture = love.physics.newFixture(self.physComp.body, self.viewRightShape, 0)
    self.viewRightFixture:setSensor(true)
    self.viewRightFixture:setUserData(self)
end

function EnemyDrone:update(dt)
    local inventory = self.inventory
    local world = self.parent.level.world

    local playerFound = nil
    local contacts = self.physComp.body:getContacts()
    for i, contact in ipairs(contacts) do
        local fixtureA, fixtureB = contact:getFixtures()
        function onContact(fixture, otherFixture)
            local entity = otherFixture:getUserData()
            if entity and contact:isTouching() then
                local className = entity:getName()
                if className == "PlayerComponent" then
                    playerFound = entity
                end
            end
        end
        if fixtureA == self.viewLeftFixture then
            onContact(fixtureA, fixtureB)
        end
        if fixtureA == self.viewRightFixture then
            onContact(fixtureA, fixtureB)
        end
        if fixtureB == self.viewLeftFixture then
            onContact(fixtureB, fixtureA)
        end
        if fixtureB == self.viewRightFixture then
            onContact(fixtureB, fixtureA)
        end
    end
    self.hitList = {}
    if playerFound then
        local sx, sy = self:getPosition()
        local px, py = playerFound:getPosition()
        if sx ~= px and sy ~= py then
            function callback(fixture, x, y, xn, yn, fraction)
                local hit = {}
                hit.fixture = fixture
                hit.x, hit.y = x, y
                hit.xn, hit.yn = xn, yn
                hit.fraction = fraction

                table.insert(self.hitList, hit)
                return 1
            end
            world:rayCast(sx, sy, px, py, callback)
        end
    end
    if #self.hitList >= 1 then
        local last = self.hitList[#self.hitList]
        if last.fixture:getUserData() ~= playerFound then
            self.hitList = {}
        end
    end
    --self.headComp.direction = self.direction

    Body.update(self, dt)
end

function EnemyDrone:draw()
    love.graphics.push()
    love.graphics.origin()
    echo(self.hitList)
    for i, hit in ipairs(self.hitList) do
        love.graphics.setColor(255, 0, 0)
        love.graphics.print(i, hit.x, hit.y) -- Prints the hit order besides the point.
        love.graphics.circle("line", hit.x, hit.y, 3)
        love.graphics.setColor(0, 255, 0)
        love.graphics.line(hit.x, hit.y, hit.x + hit.xn * 25, hit.y + hit.yn * 25)
    end
    love.graphics.pop()

    Body.draw(self)
end

_G.EnemyDrone = EnemyDrone

return EnemyDrone
