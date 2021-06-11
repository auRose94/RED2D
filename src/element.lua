local ElementClass = inheritsFrom(nil)

function ElementClass:init(...)
    self.elements = {}
    self.x = 0
    self.y = 0
    self.z = 0
    self.r = 0
    self.sx = 1
    self.sy = 1
    self.ox = 0
    self.oy = 0
    self.kx = 0
    self.ky = 0
    self.width = 0
    self.height = 0
    self.hide = false
    self.transform = love.math.newTransform()
    for i = 1, select('#', ...) do
        local value = select(i, ...)
        local tValue = type(value)
        if tValue == "table" then
            if isa(value, ElementClass) then
                table.insert(self.elements, value)
                value.parent = self
            else
                self = tableMerge(self, value)
            end
        elseif tValue == "string" then
            self.text = value
        end
    end

end

function ElementClass:getName()
    return "ElementClass"
end

function ElementClass:setPosition(...)
    local x, y = ...
    if type(x) == "table" then
        x, y = unpack(...)
    end
    self.x = x
    self.y = y
end

function ElementClass:getUp()
    local transform = self:getTransform()
    return self:transformNormal(0, 1)
end

function ElementClass:getRight()
    local transform = self:getTransform()
    return self:transformNormal(1, 0)
end

function ElementClass:getWorldPosition()
    local transform = self:getTransform()
    return transform:transformPoint(0, 0)
end

function ElementClass:getWorldPoint(x, y)
    local transform = self:getTransform()
    return transform:transformPoint(x, y)
end

function ElementClass:getPosition()
    return self.x, self.y
end

function ElementClass:setRotation(r)
    self.r = r
end

function ElementClass:getRotation()
    return self.r
end

function ElementClass:setScale(...)
    local x, y = ...
    if type(x) == "table" then
        x, y = unpack(...)
    end
    self.sx = x
    self.sy = y
end

function ElementClass:getScale()
    return self.sx, self.sy
end

function ElementClass:setSkew(...)
    local x, y = ...
    if type(x) == "table" then
        x, y = unpack(...)
    end
    self.kx = x
    self.ky = y
end

function ElementClass:getSkew()
    return self.kx, self.ky
end

function ElementClass:setOrigin(...)
    local x, y = ...
    if type(x) == "table" then
        x, y = unpack(...)
    end
    self.ox = x
    self.oy = y
end

function ElementClass:getOrigin()
    return self.ox, self.oy
end

function ElementClass:getTransform()
    self.transform = love.math
                         .newTransform(self.x, self.y, self.r, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
    if self.parent then
        return self.parent:getTransform() * self.transform
    end
    return self.transform
end

function ElementClass:getInnerSize()
    local width, height = 0, 0
    for _, value in pairs(self.elements) do
        if value and not value.hide then
            if value.x + value.width > width then
                width = value.x + value.width
            end

            if value.y + value.height > height then
                height = value.y + value.height
            end
        end
    end
    return width, height
end

function ElementClass:mouseInside()
    local mx, my = love.mouse.getPosition()
    local width, height = self.width, self.height
    if self.textObj then
        local textObj = self.textObj
        local tW, tH = textObj:getDimensions()
        if tW > width then
            width = tW
        end
        if tH > height then
            height = tH
        end
    end
    if self.maxHeight < height then
        height = self.maxHeight
    end
    if self.maxWidth < height then
        height = self.maxWidth
    end

    local v = {}
    v[1] = {love.graphics.transformPoint(self.x, self.y)}
    v[2] = {love.graphics.transformPoint(self.x + width, self.y)}
    v[3] = {love.graphics.transformPoint(self.x + width, self.y + height)}
    v[4] = {love.graphics.transformPoint(self.x, self.y + height)}

    return polyPoint(v, mx, my)
end

function ElementClass:draw()
    if not self.hide then
        for _, value in pairs(self.elements) do
            if value and not value.hide and type(value.draw) == "function" then
                love.graphics.push()
                value:draw()
                love.graphics.pop()
            end
        end
    end
end

return ElementClass
