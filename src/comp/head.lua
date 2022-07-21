local Component = require "component"

local HeadComponent = inheritsFrom(Component)

function HeadComponent:getName()
    return "HeadComponent"
end

function HeadComponent:init(parent, data, ...)
    Component.init(self, parent, ...)
    parent.drawOrder = 0.01
    self.direction = 1 -- 0 or more equals right, 0 or less equals left
    self.blinking = true
    self.talking = false
    self.facialState = {}
    self.lookX = 0
    self.lookY = 0

    self.headTopX, self.headTopY = 0, 0 -- Used for mounting equipment
    self.leftEyeX, self.leftEyeY = 0, 0 -- Used to shed tears and throw hearts
    self.rightEyeX, self.rightEyeY = 0, 0 -- Used to look angry and cause fears
    self.leftMouthX, self.leftMouthY = 0, 0 -- A mouth that's too loud
    self.rightMouthX, self.rightMouthY = 0, 0 -- And a mouth that can't stop
    self.headBaseX, self.headBaseY = 0, 0 -- Used to mount to a body, if any at all
    self.eyeColor = {1, 1, 1, 1}
    self.mouthColor = {1, 1, 1, 1}
    self.faceColor = {1, 1, 1, 1}
    self.order = {}

    if data then
        self:loadFaceData(data)
    end
end

function IsTexturePair(table)
    if type(table) == "table" and type(table[1]) == "userdata" and type(table[2]) == "userdata" then
        return true
    end
    return false
end

function IsRotation(table)
    if type(table) == "table" then
        for i, o in pairs(table) do
            if not IsTexturePair(o) then
                return false
            end
        end
    end
    return true
end

function HeadComponent:loadFaceData(data)
    local left = data.left or nil
    local right = data.right or nil
    assert(type(left) == type(right) and type(left) == "table", "Missing left and right face tables")
    assert(#left == #right, "Both tables need to be the same size")

    -- Left and right tables
    self.left = left
    self.right = right

    -- Properties for face
    self.robot = data.robot or false
    self.talkSpeed = data.talkSpeed or 100

    -- Mount points
    self.headBaseX, self.headBaseY = unpack(data.headBase or {0, 0})
    self.headTopX, self.headTopY = unpack(data.headTop or {0, 0})
    self.rightEyeX, self.rightEyeY = unpack(data.rightEye or {0, 0})
    self.rightMouthX, self.rightMouthY = unpack(data.rightMouth or {0, 0})
    self.leftEyeX, self.leftEyeY = unpack(data.leftEye or {0, 0})
    self.leftMouthX, self.leftMouthY = unpack(data.leftMouth or {0, 0})

    -- Offset applied to parent
    self:setOrigin(self.headBaseX, self.headBaseY)

    -- Left Eyes
    assert(type(left.eyes) == "table", "Missing eyes for left")
    assert(IsRotation(left.eyes.rotations), "Left eye rotations needs to be a table of rect")
    assert(IsTexturePair(left.eyes.dead), "Left eye dead needs to be a rect")
    assert(IsTexturePair(left.eyes.happy), "Left eye happy needs to be a rect")
    assert(IsTexturePair(left.eyes.heart), "Left eye heart needs to be a rect")
    assert(IsTexturePair(left.eyes.hurt), "Left eye hurt needs to be a rect")
    assert(IsTexturePair(left.eyes.center), "Left eye center needs to be a rect")
    assert(IsTexturePair(left.eyes.blink), "Left eye blink needs to be a rect")
    assert(IsTexturePair(left.eyes.mad), "Left eye mad needs to be a rect")

    -- Left Mouth
    assert(type(left.mouth) == "table", "Missing mouth for left")
    assert(IsTexturePair(left.mouth.frown), "Left mouth frown needs to be a rect")
    assert(IsTexturePair(left.mouth.smile), "Left mouth smile needs to be a rect")
    assert(IsTexturePair(left.mouth.open), "Left mouth open needs to be a rect")
    assert(IsTexturePair(left.mouth.close), "Left mouth close needs to be a rect")
    assert(IsTexturePair(left.mouth.grit), "Left mouth grit needs to be a rect")

    -- Left Face
    assert(IsTexturePair(left.face), "Left face needs to be a rect")
    assert(IsTexturePair(left.faceblushing), "Left faceBlushing needs to be a rect")
    assert(IsTexturePair(left.facebroken), "Left faceBroken needs to be a rect")

    -- Right Eyes
    assert(type(right.eyes) == "table", "Missing eyes for right")
    assert(IsRotation(right.eyes.rotations), "Right eye rotations needs to be a table of rect")
    assert(IsTexturePair(right.eyes.dead), "Right eye dead needs to be a rect")
    assert(IsTexturePair(right.eyes.happy), "Right eye happy needs to be a rect")
    assert(IsTexturePair(right.eyes.heart), "Right eye heart needs to be a rect")
    assert(IsTexturePair(right.eyes.hurt), "Right eye hurt needs to be a rect")
    assert(IsTexturePair(right.eyes.center), "Right eye center needs to be a rect")
    assert(IsTexturePair(right.eyes.blink), "Right eye blink needs to be a rect")
    assert(IsTexturePair(right.eyes.mad), "Right eye mad needs to be a rect")

    -- Right Mouth
    assert(type(right.mouth) == "table", "Missing mouth for right")
    assert(IsTexturePair(right.mouth.frown), "Right mouth frown needs to be a rect")
    assert(IsTexturePair(right.mouth.smile), "Right mouth smile needs to be a rect")
    assert(IsTexturePair(right.mouth.open), "Right mouth open needs to be a rect")
    assert(IsTexturePair(right.mouth.close), "Right mouth close needs to be a rect")
    assert(IsTexturePair(right.mouth.grit), "Right mouth grit needs to be a rect")

    -- Right Face
    assert(IsTexturePair(right.face), "Right face needs to be a rect")
    assert(IsTexturePair(right.faceblushing), "Right faceBlushing needs to be a rect")
    assert(IsTexturePair(right.facebroken), "Right faceBroken needs to be a rect")

    local faceTable = self.right
    if self.direction < 0 then
        faceTable = self.left
    end
end

function HeadComponent:lookAt(...)
    local x, y = ...
    if type(x) == "table" then
        x, y = unpack(...)
    end
    self.lookX, self.lookY = math.normalize(x, y)
end

function HeadComponent:getAim(invertY)
    local rDirX, rDirY = self.lookX, self.lookY
    local dirMag = 300
    rDirX, rDirY = rDirX * dirMag, rDirY * dirMag
    if invertY then
        rDirY = -rDirY
    end
    return math.angle(0, 0, rDirX, -rDirY)
end

function HeadComponent:update(dt)
    local now = love.timer.getTime()
    local talkSpeed = self.talkSpeed

    local blinkChange = false
    local mouthChange = false
    local emotion = #self.facialState > 0
    local looking = not emotion and (self.lookX ~= self.lookY and self.lookX ~= 0)

    if self.talking then
        mouthChange = math.floor(math.cos(now * talkSpeed)) == 0
    end

    self.currentBlinkWait = self.currentBlinkWait or 1
    self.currentBlink = self.currentBlink or now
    if self.blinking then
        if now - self.currentBlink >= self.currentBlinkWait then
            self.currentBlink = now
            self.currentBlinkWait = (math.random(0, 1000) * 3) / 1000
            blinkChange = true
        end
    end

    local faceTable = self.right
    if self.direction < 0 then
        faceTable = self.left
    end

    local eyes = faceTable.eyes.center
    local mouth = faceTable.mouth.close
    local face = faceTable.face

    -- Base
    if CheckValue(self.facialState, "dead") then
        face = faceTable.facebroken
    elseif faceTable.faceBlushing and CheckValue(self.facialState, "happy", "like") then
        face = faceTable.faceBlushing
    end

    if not CheckValue(self.facialState, "dead") then
        -- Eyes
        if not blinkChange or now - self.currentBlink > self.currentBlinkWait then
            if looking then
                local aimAngle = math.abs(self:getAim() - math.pi)
                local aimIndex = math.abs(math.floor(math.deg(aimAngle) / (360 / (#faceTable.eyes.rotations - 1)))) + 1
                eyes = faceTable.eyes.rotations[aimIndex]
            elseif emotion then
                if CheckValue(self.facialState, "like") then
                    eyes = faceTable.eyes.happy
                elseif CheckValue(self.facialState, "heart") then
                    eyes = faceTable.eyes.heart
                elseif CheckValue(self.facialState, "sad") then
                    eyes = faceTable.eyes.center
                elseif CheckValue(self.facialState, "hurt") then
                    eyes = faceTable.eyes.hurt
                elseif CheckValue(self.facialState, "mad") then
                    eyes = faceTable.eyes.mad
                end
            else
                eyes = faceTable.eyes.center
            end
        else
            eyes = faceTable.eyes.close
        end

        -- Mouth
        if self.talking then
            local change = math.floor(math.cos(now * 10)) ~= 0
            if change then
                if mouth == faceTable.mouth.close then
                    mouth = faceTable.mouth.open
                elseif mouth == faceTable.mouth.open then
                    mouth = faceTable.mouth.close
                end
            end
        else
            if CheckValue(self.facialState, "like", "heart") then
                mouth = faceTable.mouth.smile
            elseif CheckValue(self.facialState, "sad") then
                mouth = faceTable.mouth.grit
            elseif CheckValue(self.facialState, "hurt") then
                mouth = faceTable.mouth.open
            elseif CheckValue(self.facialState, "mad") then
                mouth = faceTable.mouth.frown
            else
                mouth = faceTable.mouth.close
            end
        end
    end
    self.order = {}
    if face then
        table.insert(self.order, {face[3], face, self.faceColor})
    end
    if mouth then
        table.insert(self.order, {mouth[3], mouth, self.mouthColor})
    end
    if eyes then
        table.insert(self.order, {eyes[3], eyes, self.eyeColor})
    end
    table.sort(
        self.order,
        function(a, b)
            return a[1] < b[1]
        end
    )
end

function HeadComponent:draw()
    for i, o in pairs(self.order) do
        local orderIndex, pair, color = unpack(o)
        local img, rect = unpack(pair)
        love.graphics.setColor(color)
        love.graphics.draw(img, rect)
    end
end

return HeadComponent
