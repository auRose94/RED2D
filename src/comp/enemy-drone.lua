local Component = require "component"
local PhysicsComponent = require "comp.physics"
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

function EnemyDrone:update(dt)
    local inventory = self.inventory

    --self.headComp.direction = self.direction

    Body.update(self, dt)
end

_G.EnemyDrone = EnemyDrone

return EnemyDrone
