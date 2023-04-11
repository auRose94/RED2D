local EntityModel = require "engine.entity"
local Camera = inheritsFrom(EntityModel)

_G.cameras = {}

function Camera:init(level)
    EntityModel.init(self, level, "Camera")
    self.entities = {}
    local scale = 1.325
    self.sx = scale -- 1.125

    self.sy = scale
    self.cameraSpeed = 4
    self.rotSpeed = 4
    self.filter = {"nearest", "nearest", 16}
    self.canvas = love.graphics.newCanvas(width, height)
    self.canvas:setFilter(unpack(self.filter))
    table.insert(cameras, self)
end

function Camera:getName()
    return "Camera"
end

function Camera:destroy()
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

function Camera:getOffset(division)
    division = division or 4
    local scale = love.graphics.getDPIScale()
    local w, h = love.graphics.getDimensions()
    w, h = (w / division) * scale, (h / division) * scale
    return w * self.sx, h * self.sy
end

function Camera:setTransformOffset(xOrArray, y)
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

function Camera:getTransform()
    local w, h = love.graphics.getPixelDimensions()
    local trans = love.math.newTransform()
    trans:translate(w / 2, h / 2)
    trans:scale(self.sx, self.sy)
    trans:rotate(-self.r)
    trans:translate(-self.x, -self.y)
    return trans
end

function Camera:getWorldPoint(x, y)
    return self:getTransform():inverseTransformPoint(x, y)
end

function Camera:getLocalPoint(x, y)
    return self:getTransform():transformPoint(x, y)
end

function Camera:getCenter()
    return self:getWorldPoint(self:getOffset())
end

function Camera:mousePosition()
    return self:getWorldPoint(love.mouse.getPosition())
end

function Camera:layerDraw()
    local items = {}
    for _, e in pairs(self.entities) do
        table.insert(items, e)
        e:dumpAllEntities(
            function(entity)
                table.insert(items, entity)
            end
        )
    end
    love.graphics.push()
    love.graphics.origin()
    love.graphics.applyTransform(self:getTransform())

    local toRender = {}
    local ox, oy = self:getOffset()
    local cX1, cY1 = self:getWorldPoint(ox * 3.14, oy * 3.14)
    local cX2, cY2 = self.x, self.y
    local cSize = math.dist(cX1, cY1, cX2, cY2)
    for _, e in pairs(items) do
        local ex, ey = e:getWorldPosition()
        local eDis = math.dist(cX2, cY2, ex, ey)
        if eDis - e.areaSize < cSize then
            table.insert(toRender, e)
        end
    end
    table.sort(
        toRender,
        function(a, b)
            return a.drawOrder < b.drawOrder
        end
    )
    for _, c in pairs(toRender) do
        love.graphics.push()
        c:draw()
        love.graphics.pop()
    end
    love.graphics.pop()
end

function Camera:newEntityLayer(entities)
    self.entities = entities
end

function Camera:dispatch()
    _G.camera = self
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear(0, 0, 0, 0)
    self.canvas:renderTo(
        function()
            self:layerDraw()
        end
    )
    love.graphics.origin()
    love.graphics.setCanvas()
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.canvas, 0, 0, 0, 1, 1)
    _G.camera = nil
end

function Camera:update(dt)
    EntityModel.update(self, dt)
    if self.followTarget then
        local target = self.followTarget

        local targetTransform = love.math.newTransform()
        if target.parent then
            targetTransform = target.parent:getTransform()
        end
        targetTransform =
            targetTransform *
            love.math.newTransform(target.x, target.y, target.r, target.sx, target.sy, target.ox, target.oy)

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
        camera.canvas = love.graphics.newCanvas(width, height)
        camera.canvas:setFilter(unpack(camera.filter))
    end
end

return Camera
