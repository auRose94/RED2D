local Component = require "engine.component"
local PhysicsComp = require "comp.physics"
local WeaponComponent = require "comp.weapon"
local Body = inheritsFrom(Component)

function Body:getName()
    return "Body"
end

function Body:init(parent, data, ...)
    Component.init(self, parent, ...)
    self.direction = 1
    self.leftAim = false
    self.rightAim = false
    self.aimX = 0
    self.aimY = 0
    self.dead = false

    self.walkingFrame = 1
    self.lastWalkingFrameUpdate = love.timer.getTime()
    self.walkingFrameSpeed = self.walkingFrameSpeed or 0.015
    self.speed = self.speed or 600
    self.jumpPower = self.jumpPower or 10
    self.jumpCooloff = self.jumpCooloff or 0.1
    self.flySpeed = self.flySpeed or 400
    self.gravity = self.gravity or 980
    self.touchAngle = self.touchAngle or 0.005
    self.knockOutSpeed = self.knockOutSpeed or 1500
    self.topSpeed = self.topSpeed or 600
    self.rotSpeed = self.rotSpeed or 10
    self.speedSkew = self.speedSkew or 0.125
    self.health = self.health or 10
    self.maxHealth = self.maxHealth or 10
    self.lastStanding = love.timer.getTime()
    self.lastJump = love.timer.getTime()
    self.targetAngle = 0
    self.currentAngle = 0
    self.currentNormalX = 0
    self.currentNormalY = -1
    self.baseName = "default"

    self.physComp = parent:getComponent(PhysicsComp) or PhysicsComp(parent, "dynamic")

    self.physComp:setFixedRotation(true)
    -- self.physComp:useCCD(true)

    self.raycastLength = 32

    self.downRaycast = nil
    self.downNormalX = 0
    self.downNormalY = -1
    self.downAngle = 0

    self.legColor = {1, 1, 1, 1}
    self.bodyColor = {1, 1, 1, 1}
    self.armColor = {1, 1, 1, 1}

    local order = 1

    self.leftHand = Entity(parent.level, "left hand")
    self.leftHand.drawOrder = order
    self.leftHand:setScale(0.25, 0.25)
    self.leftHand:setParent(parent)

    self.rightHand = Entity(parent.level, "right hand")
    self.rightHand.drawOrder = order
    self.rightHand:setScale(0.25, 0.25)
    self.rightHand:setParent(parent)

    self.headEntity = Entity(parent.level, "head")
    self.headEntity:setScale(0.9, 0.9)
    self.headEntity:setParent(parent)
    self.headEntity.drawOrder = 2

    self.loadedData = nil
    if data then
        self:loadBodyData(data)
    end

    self.weapons = {}
end

function Body:getWeaponMounts()
    return {self.leftHand, self.rightHand}
end

function IsTexturePair(table)
    if type(table) == "table" and type(table[1]) == "userdata" and type(table[2]) == "userdata" then
        return true
    end
    return false
end

function IsPointTable(table)
    if type(table) == "table" then
        for i, o in pairs(table) do
            if not (type(o) == "table" and #o == 2 and type(o[1]) == "number" and type(o[2]) == "number") then
                return false
            end
        end
    end
    return true
end

function IsRotationTable(table)
    if type(table) == "table" then
        for i, o in pairs(table) do
            if not IsTexturePair(o) then
                return false
            end
        end
    end
    return true
end

function Body:loadBodyData(data)
    self.loadedData = data
    local left = data.left or nil
    local right = data.right or nil
    assert(type(left) == type(right) and type(left) == "table", "No left and right face tables")
    assert(#left == #right, "Both tables need to be the same size")

    -- Left and right tables
    self.left = left
    self.right = right

    assert(type(left.base) == "table", "No base for left")
    assert(type(left.center) == "table", "No center for left")
    assert(type(left.base.default) == "table", "No default base for left")
    --assert(type(left.arms) == "table", "No arms for left")
    assert(type(left.legs) == "table", "No legs for left")

    --assert(IsRotationTable(left.arms.left.rotations), "No left arm rotations for left")
    --assert(IsPointTable(left.arms.left.points), "No left arm points for left")
    --assert(type(left.arms.left.base) == "table", "No base for left arm for left")

    --assert(IsRotationTable(left.arms.right.rotations), "No right arm rotations for left")
    --assert(IsPointTable(left.arms.right.points), "No right arm points for left")
    --assert(type(left.arms.right.base) == "table", "No base for right arm for left")

    assert(type(right.base) == "table", "No base for right")
    assert(type(right.center) == "table", "No center for right")
    assert(type(right.base.default) == "table", "No default base for right")
    --assert(type(right.arms) == "table", "No arms for right")
    assert(type(right.legs) == "table", "No legs for right")

    --assert(IsRotationTable(right.arms.left.rotations), "No left arm rotations for right")
    --assert(IsPointTable(right.arms.left.points), "No left arm points for right")
    --assert(type(right.arms.left.base) == "table", "No base for left arm for right")

    --assert(IsRotationTable(right.arms.right.rotations), "No right arm rotations for right")
    --assert(IsPointTable(right.arms.right.points), "No right arm points for right")
    --assert(type(right.arms.right.base) == "table", "No base for right arm for right")

    -- Properties for body
    self.robot = data.robot or false
    self.walkingFrameSpeed = data.walkingFrameSpeed or self.walkingFrameSpeed
    self.speed = data.speed or self.speed
    self.jumpPower = data.jumpPower or self.jumpPower
    self.jumpCooloff = data.jumpCooloff or self.jumpCooloff
    self.flySpeed = data.flySpeed or self.flySpeed
    self.gravity = data.gravity or self.gravity
    self.touchAngle = data.touchAngle or self.touchAngle
    self.knockOutSpeed = data.knockOutSpeed or self.knockOutSpeed
    self.topSpeed = data.topSpeed or self.topSpeed
    self.rotSpeed = data.rotSpeed or self.rotSpeed

    -- Mount points
    self:setHeadMount(data.headMount or {0, 0})

    self:setOrigin(data.offsetX, data.offsetY)

    data.createPhysics(self)
end

function Body:onDownHit(fixture, x, y, xn, yn, fraction)
    if fixture == self.bottomFixture or fixture == self.bodyFixture then
        return -1
    end
    self.downRaycast = {fixture, x, y, xn, yn, fraction}
    local angle = math.angle3(0, -1, xn, yn)
    if angle < self.touchAngle or angle > -self.touchAngle then
        self.downNormalX = xn
        self.downNormalY = yn
        self.downAngle = angle
    end

    return 0
end

function Body:heal(amount)
    self.health = self.health + amount
    if self.health > self.maxHealth then
        self.health = self.maxHealth
    end
end

function Body:hurt(damage)
    self.health = self.health - damage
    if self.health < 0 then
        self.health = 0
    end
end

function Body:setHeadMount(x, y)
    if type(x) == "table" then
        self.headMountX, self.headMountY = unpack(x)
    else
        self.headMountX, self.headMountY = x, y
    end
    self.headEntity:setPosition(self.headMountX, self.headMountY)
end

function Body:getAim(invertY)
    local ax, ay = self.aimX, self.aimY
    if self.getAimNormal then
        ax, ay = self:getAimNormal(invertY)
    end
    local angle = math.angle2(1, 0, ax, ay)
    if angle == math.pi then
        return -angle
    end
    return angle
end

function Body:getLeftWeapon()
    if self.leftHand then
        local weapons = self.leftHand:getComponents(WeaponComponent)
        if #weapons > 0 then
            return weapons[1]
        end
    end
    return nil
end

function Body:getRightWeapon()
    if self.rightHand then
        local weapons = self.rightHand:getComponents(WeaponComponent)
        if #weapons > 0 then
            return weapons[1]
        end
    end
    return nil
end

function Body:update(dt)
    local world = self.parent.level.world
    local physComp = self.physComp

    local vx, vy = physComp:getLinearVelocity()
    local lvx, lvy = physComp:getLocalVector(vx, vy)
    local speed = math.dist(0, 0, vx, vy)
    local now = love.timer.getTime()

    local maxSpeed = self.topSpeed
    local skewXMultiplier = maxSpeed / (maxSpeed - math.abs(lvx))
    local skewYMultiplier = maxSpeed / (maxSpeed - math.abs(lvy))
    local xSkew = (skewXMultiplier - 1) * self.direction
    local ySkew = (skewYMultiplier - 1)
    if math.abs(xSkew) > self.speedSkew then
        xSkew = math.min(math.abs(xSkew), self.speedSkew) * self.direction
    end
    if math.abs(ySkew) > self.speedSkew then
        ySkew = math.min(math.abs(ySkew), self.speedSkew) * (math.sign(lvy) * self.direction)
    else
        ySkew = 0
    end
    self:setSkew(xSkew, ySkew)

    local standing = false
    local knockedOut = false

    if speed >= self.knockOutSpeed or self.health <= 0 then
        knockedOut = true
    end

    local contacts = physComp:getContacts()
    if #contacts > 0 then
        for ci = 1, #contacts do
            local contact = contacts[ci]
            if contact ~= nil then
                local x1, y1 = contact:getPositions()
                if x1 and y1 then
                    local fixtureA, fixtureB = contact:getFixtures()
                    if fixtureA == self.bottomFixture.fixture or fixtureB == self.bottomFixture.fixture then
                        local cx, cy = contact:getNormal()
                        local angle = math.angle3(0, -1, cx, cy)
                        if angle < self.touchAngle or angle > -self.touchAngle and contact:isTouching() then
                            self.lastStanding = now
                            self.targetAngle = angle
                            self.currentNormalX = cx
                            self.currentNormalY = cy
                        end
                    end
                end
            end
        end
    end

    function OnDownHitCallback(fixture, x, y, xn, yn, fraction)
        return self:onDownHit(fixture, x, y, xn, yn, fraction)
    end

    local downRayX, downRayY = physComp:getWorldPoint(0, self.raycastLength)
    self.downRaycast = nil
    local wx, wy = physComp:getPosition()
    world:rayCast(wx, wy, downRayX, downRayY, OnDownHitCallback)

    if self.lastStanding > now - 0.005 then
        standing = true
    end

    -- earth gravity: 9.81*64

    if knockedOut == false then
        self.physComp:setFixedRotation(true)
        local angle = math.angle(0, 0, self.currentNormalX, self.currentNormalY) + math.rad(90)
        local downDirX, downDirY = physComp:getWorldVector(0, -1)
        local r = math.angleLerp(self:getRotation(), angle, self.rotSpeed * dt)
        if not self.moveDown then
            physComp:setRotation(r)
            physComp:setAngularVelocity(0)
        end
        physComp:applyLinearImpulse(downDirX * -self.gravity * dt, downDirY * -self.gravity * dt)
    else
        self.physComp:setFixedRotation(false)
    end

    local walkingDirX = 0
    local jumpingDir = 0
    if self.moveRight then
        if standing == false then
            walkingDirX = self.flySpeed * dt
        else
            walkingDirX = self.speed * dt
        end
    elseif self.moveLeft then
        if standing == false then
            walkingDirX = -self.flySpeed * dt
        else
            walkingDirX = -self.speed * dt
        end
    end

    local recentlyJumped = self.lastJump < now - self.jumpCooloff
    if recentlyJumped and standing and self.moveUp then
        jumpingDir = -self.jumpPower
        self.lastJump = now
    end

    if speed < self.topSpeed and walkingDirX ~= 0 or jumpingDir ~= 0 then
        physComp:applyLinearImpulse(physComp:getWorldVector(walkingDirX, jumpingDir))
    end

    -- Animations
    local faceTable = self.right
    if lvx > 0.5 and self.direction == -1 then
        self.direction = 1
    elseif lvx < -0.5 and self.direction == 1 then
        self.direction = -1
    end

    if self.direction > 0 then
        faceTable = self.right
    elseif self.direction < 0 then
        faceTable = self.left
    end

    local leftArmRect = nil
    local rightArmRect = nil
    local baseRect = faceTable.base[self.baseName or "default"]
    local legsRect = faceTable.legs.standing
    if faceTable.arms ~= nil then
        local rotations = #faceTable.arms.left.rotations

        local aimAngle = math.pi / 2
        if self.aimX ~= 0 and self.aimY ~= 0 then
            aimAngle = self:getAim()
        end
        local rotIndex = math.abs(math.floor(math.deg(aimAngle + math.pi) / (360 / rotations))) + 1
        local defaultIndex = math.abs(math.floor(math.deg((math.pi / 2) + math.pi) / (360 / rotations))) + 1
        local leftPoint = faceTable.arms.left.points[defaultIndex]
        local rightPoint = faceTable.arms.right.points[defaultIndex]
        leftArmRect = faceTable.arms.left.rotations[rotIndex]
        rightArmRect = faceTable.arms.right.rotations[rotIndex]
        local leftAim = aimAngle
        local rightAim = aimAngle

        if self.leftAim or self.rightAim then
            aimAngle = self:getAim(false, unpack(faceTable.center))
            local partSize = 360 / rotations
            rotIndex = math.abs(math.floor(math.deg(aimAngle + math.pi) / partSize)) + 1
            if (self.leftAim and self:getLeftWeapon()) and (self.rightAim and self:getRightWeapon()) then
                leftPoint = faceTable.arms.left.points[rotIndex]
                rightPoint = faceTable.arms.right.points[rotIndex]
            elseif (self.leftAim and self:getLeftWeapon()) then
                leftPoint = faceTable.arms.left.points[rotIndex]
            elseif (self.rightAim and self:getRightWeapon()) then
                rightPoint = faceTable.arms.right.points[rotIndex]
            end
            if leftPoint then
                leftAim = self:getAim(false, unpack(leftPoint))
            end
            if rightPoint then
                rightAim = self:getAim(false, unpack(rightPoint))
            end
            if self:getLeftWeapon() then
                leftArmRect = faceTable.arms.left.rotations[rotIndex]
            end
            if self:getRightWeapon() then
                rightArmRect = faceTable.arms.right.rotations[rotIndex]
            end
        end

        local rightHandScaleX, rightHandScaleY = self.rightHand:getScale()
        local leftHandScaleX, leftHandScaleY = self.leftHand:getScale()
        if self.direction > 0 then
            self.leftHand:setScale(leftHandScaleX, math.abs(leftHandScaleY))
            self.rightHand:setScale(rightHandScaleX, math.abs(rightHandScaleY))
        elseif self.direction < 0 then
            self.leftHand:setScale(leftHandScaleX, -math.abs(leftHandScaleY))
            self.rightHand:setScale(rightHandScaleX, -math.abs(rightHandScaleY))
        end

        self.leftHand:setRotation(leftAim)
        self.leftHand:setPosition(leftPoint)

        self.rightHand:setRotation(rightAim)
        self.rightHand:setPosition(rightPoint)
    end

    local fromTop = self.topSpeed - speed
    local speedMultiplier = ((fromTop / self.topSpeed) / self.walkingFrameSpeed)
    local walkingFrameStep = now - speedMultiplier
    local legsAnimation = faceTable.legs.animation
    if standing and math.abs(lvx) > 1 and math.abs(lvy) < 10 then
        -- Walking
        if self.lastWalkingFrameUpdate <= walkingFrameStep then
            self.lastWalkingFrameUpdate = now
            self.walkingFrame = self.walkingFrame + 1
            if self.walkingFrame > #legsAnimation then
                self.walkingFrame = 1
            end
        end
        legsRect = legsAnimation[self.walkingFrame]
    elseif standing == false and lvy < 0 then
        -- Jump pending
        legsRect = legsAnimation[5]
    elseif standing == false and lvy > 0 then
        -- Jumping
        legsRect = legsAnimation[3]
    elseif standing then
        legsRect = faceTable.legs.standing
    end

    local order = {}
    if leftArmRect then
        table.insert(order, {leftArmRect[3], leftArmRect, self.armColor})
    end
    if rightArmRect then
        table.insert(order, {rightArmRect[3], rightArmRect, self.armColor})
    end
    if baseRect then
        table.insert(order, {baseRect[3], baseRect, self.bodyColor})
    end
    if legsRect then
        table.insert(order, {legsRect[3], legsRect, self.legColor})
    end
    self.order = order

    table.sort(
        self.order,
        function(a, b)
            return a[1] < b[1]
        end
    )
end

function Body:draw()
    if self.order then
        for _, o in pairs(self.order) do
            local _, pair, color = unpack(o)
            local img, rect = unpack(pair)
            love.graphics.setColor(color)
            love.graphics.draw(img, rect)
        end
    end
    if _G.debugDrawPhysics then
        if self.downRaycast ~= nil then
            local _, x, y, _, _, _ = unpack(self.downRaycast)
            love.graphics.setColor(0, 1, 0, 0.5)
            love.graphics.setLineWidth(3)
            local lx, ly = self.physComp:getPosition()
            love.graphics.line(lx, ly, x, y)
        end
    end
end

return Body
