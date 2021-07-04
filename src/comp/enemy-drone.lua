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
end

function EnemyDrone:headPoint()
    return self:transformPoint(8, -3)
end

function EnemyDrone:scan(angle)
    local world = self.parent.level.world
    local sx, sy = self:headPoint()
    local ext = 400
    local px, py = self:transformPoint(math.cos(angle) * ext, math.sin(angle) * ext)
    --echo(sx, sy, px, py)

    local hitList = {}
    function callback(fixture, x, y, xn, yn, fraction)
        local hit = {
            fixture = fixture,
            x = x,
            y = y,
            xn = xn,
            yn = yn,
            fraction = fraction,
            distance = math.dist(x, y, sx, sy)
        }
        table.insert(hitList, #hitList, hit)
        return 1
    end
    world:rayCast(sx, sy, px, py, callback)
    table.sort(
        hitList,
        function(left, right)
            return left.fraction < right.fraction
        end
    )
    return hitList
end

function EnemyDrone:update(dt)
    local inventory = self.inventory
    local world = self.parent.level.world

    local playerFound = nil
    self.hitLists = {}
    for i = -180, 180, 2 do
        local hitList = self:scan(math.rad(i))
        for hi, hit in ipairs(hitList) do
            local entity = hit.fixture:getUserData()
            if entity:getName() == "Player" and hi == 1 then
                playerFound = entity
                table.insert(self.hitLists, hitList)
            end
        end
    end

    --echo(playerFound ~= nil)
    --self.headComp.direction = self.direction

    Body.update(self, dt)
end

function EnemyDrone:draw()
    if _G.debugDrawNPCView then
        local camera = self.parent.level.camera
        local x, y = self:headPoint()
        love.graphics.push()
        love.graphics.origin()
        love.graphics.applyTransform(camera:getTransform())
        if self.hitLists then
            for hi, hits in ipairs(self.hitLists) do
                for i, hit in ipairs(hits) do
                    love.graphics.setColor(0, 0, 255, 255)
                    love.graphics.line(x, y, hit.x, hit.y)
                    love.graphics.setColor(255, 0, 0, 255)
                    love.graphics.print(i, hit.x, hit.y) -- Prints the hit order besides the point.
                    love.graphics.circle("line", hit.x, hit.y, 1)
                    love.graphics.setColor(0, 255, 0, 255)
                    love.graphics.line(hit.x, hit.y, hit.x + hit.xn * 25, hit.y + hit.yn * 25)
                end
            end
        end
        love.graphics.pop()
    end

    Body.draw(self)
end

_G.EnemyDrone = EnemyDrone

return EnemyDrone
