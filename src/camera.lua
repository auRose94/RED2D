local EntityModel = require ".src.entity"
local CameraClass = inheritsFrom(EntityModel)

_G.cameras = {}

function CameraClass:init(level)
    EntityModel.init(self, level, "Camera")
    self.layers = {}
    local scale = 1.325
    self.sx = scale -- 1.125
    
    self.sy = scale
    self.cameraSpeed = 4
    self.rotSpeed = 4
    table.insert(cameras, self)
end

function CameraClass:getName()
    return "CameraClass"
end

function CameraClass:destroy()
    local found = false
    for index, v in ipairs(cameras) do
        if self == v then
            found = index
            break
        end
    end
    if found then
        table.remove(cameras, found)
    end
end

function CameraClass:set()
    love.graphics.push()
    love.graphics.replaceTransform(self:getTransform())
end

function CameraClass:unset()
    love.graphics.pop()
end

function CameraClass:getOffset(division)
    division = division or 4
    local scale = love.graphics.getDPIScale()
    local w, h = love.graphics.getDimensions()
    w, h = (w / division) * scale, (h / division) * scale
    return w * self.sx, h * self.sy
end

function CameraClass:setTransformOffset(xOrArray, y)
    local transform = love.math.newTransform()
    if not self.followTarget then
        transform:rotate(-self.r)
    else
        transform:rotate(-self.followTarget.r)
    end
    if type(xOrArray) == "number" then
        EntityModel.setPosition(self, xOrArray, y)
    elseif type(xOrArray) == "table" then
        EntityModel.setPosition(self, xOrArray[1], xOrArray[2])
    end
end

function CameraClass:getTransform()
    local w, h = love.graphics.getPixelDimensions()
    local trans = love.math.newTransform()
    trans:translate(w / 2, h / 2)
    trans:scale(self.sx, self.sy)
    trans:rotate(-self.r)
    trans:translate(-self.x, -self.y)
    return trans
end

function CameraClass:getWorldPoint(x, y)
    return self:getTransform():inverseTransformPoint(x, y)
end

function CameraClass:getLocalPoint(x, y)
    return self:getTransform():transformPoint(x, y)
end

function CameraClass:getCenter()
    return self:getWorldPoint(self:getOffset())
end

function CameraClass:mousePosition()
    return self:getWorldPoint(love.mouse.getX(), love.mouse.getY())
end

function CameraClass:newEntityLayer(scale, entities)
    self:newLayer(scale, function()
        table.sort(entities, function(a, b)
            if a.drawOrder < b.drawOrder then
                return true
            end
        end)
        for i = 1, #entities do
            local entity = entities[i]
            if entity then
                self:set()
                entity:draw()
                self:unset()
            end
        end
    end)
end

function CameraClass:newLayer(scale, func)
    table.insert(self.layers, {
        draw = func,
        scale = scale
    })
    table.sort(self.layers, function(a, b)
        return a.scale < b.scale
    end)
end

function CameraClass:dispatch()
    _G.camera = self
    for _, v in ipairs(self.layers) do
        v.draw()
    end
    _G.camera = nil
end

function CameraClass:update(dt)
    EntityModel.update(self, dt)
    if self.followTarget then
        local target = self.followTarget
        local ox, oy = self:getOffset()

        local targetTransform = love.math.newTransform()
        if target.parent then
            targetTransform = target.parent:getTransform()
        end
        targetTransform = targetTransform *
                              love.math.newTransform(target.x, target.y, target.r, target.sx, target.sy, target.ox,
                                  target.oy)

        local tX, tY = targetTransform:transformPoint(0, 0)
        local cx = math.lerp(self.x, tX, self.cameraSpeed * dt)
        local cy = math.lerp(self.y, tY, self.cameraSpeed * dt)
        local cr = math.angleLerp(self.r, target.r, self.rotSpeed * dt)
        self:setPosition(cx, cy)
        self:setRotation(cr)
    end
end

function love.resize(width, height)
    for index, camera in ipairs(cameras) do
        if camera.followTarget then
            local target = camera.followTarget
            camera:setTransformOffset(target:getWorldPosition())
        end
    end
end

return CameraClass
