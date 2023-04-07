local Component = require "engine.component"
local PhysicsComp = require "comp.physics"

-- local imgui = require"imgui"
local Bullet = inheritsFrom(Component)

function Bullet:init(parent, ...)
    Component.init(self, parent, ...)
    self.dirX = self.dirX or 0
    self.dirY = self.dirY or 0
    self.force = self.force or 25
    self.radius = self.radius or 3.0
    self.density = self.density or 0.4
    self.ricochet = self.ricochet or 4
    self.friction = self.friction or 0.4
    self.category = self.category or {4}
    self.mask = self.mask or {3}
    self.restitution = self.restitution or 1
    self.mass = self.mass or 0.0125
    self.physBody = PhysicsComp(parent, "dynamic")
    self.physBody:useCCD(true)
    self.shape = love.physics.newCircleShape(self.radius)

    self.fixture = self.physBody:newFixture(self.shape, self.density)

    self.fixture:setFriction(self.friction)
    self.fixture:setRestitution(self.restitution)
    self.fixture:setCategory(self.category)
    self.fixture:setMask(self.mask)
    self.fixture:setUserData(self)
    self.physBody:setMass(self.mass)
    local vx, vy = self.dirX * self.force, self.dirY * self.force
    self.physBody:applyLinearImpulse(vx, vy)
end

function Bullet:destroy()
    Component.destroy(self)
    if not self.hide then
        self.hide = true
        self.shape:release()
        self.fixture:destroy()
        self.physBody:destroy()
        self.physBody = nil
        self.fixture = nil
    end
end

function Bullet:update(dt)
    local physBody = self.physBody
    if physBody then
        local contacts = physBody:getContacts()
        for ci, contact in ipairs(contacts) do
            if contact and contact:isEnabled() and contact:isTouching() then
                self.ricochet = self.ricochet - 1
                if self.ricochet <= 0 then
                    return self:destroy()
                end
            end
        end
    end
end

function Bullet:draw()
    -- self.image and self.quad and
    if not self.hide then
        love.graphics.setColor(colors.red)
        love.graphics.circle("fill", 0, 0, self.radius)
    end
end

return Bullet
