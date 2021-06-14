local ElementClass = inheritsFrom(nil)

function ElementClass:init(...)
    self.elements = {}
    self.transform = love.math.newTransform()
    for i = 1, select('#', ...) do
        local value = select(i, ...)
        local tValue = type(value)
        if tValue == "table" then
            if isa(value, ElementClass) then
                self:addElement(value)
            else
                for k, v in pairs(value) do
                    self[k] = v
                end
            end
        elseif tValue == "string" then
            self.text = value
        end
    end
    self.x = self.x or 0
    self.y = self.y or 0
    self.z = self.z or 0
    self.r = self.r or 0
    self.sx = self.sx or 1
    self.sy = self.sy or 1
    self.ox = self.ox or 0
    self.oy = self.oy or 0
    self.kx = self.kx or 0
    self.ky = self.ky or 0
    self.width = self.width or 0
    self.height = self.height or 0
    self.hide = self.hide or false
end

function ElementClass:getName()
    return "ElementClass"
end

function ElementClass:addElement(elem)
    assert(type(self.elements) == "table", "Elements is not a table")
    table.insert(self.elements, elem)
    elem.parent = self
end

function ElementClass:removeElement(elemOrTypeOrIndex)
    local found = false
    local value = nil
    if type(elemOrTypeOrIndex) == "number" then
        value = self.elements[elemOrTypeOrIndex]
        found = elemOrTypeOrIndex
    elseif type(elemOrTypeOrIndex) == "table" then
        for index, v in ipairs(self.elements) do
            if elemOrTypeOrIndex == v or v:isa(elemOrTypeOrIndex) then
                value = v
                found = index
                break
            end
        end
    end
    if found then
        value:destroy()
        value.parent = nil
        table.remove(self.elements, found)
        return value
    end
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
    for _, value in ipairs(self.elements) do
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
    if self.maxWidth < width then
        width = self.maxWidth
    end
    if self.maxHeight < height then
        height = self.maxHeight
    end

    return ElementClass:mouseInsideRect(self.x, self.y, width, height)
end

function ElementClass:mouseInsideRect(rX, rY, rW, rH)
    local v = {}
    v[1] = {love.graphics.transformPoint(rX, rY)}
    v[2] = {love.graphics.transformPoint(rX + rW, rY)}
    v[3] = {love.graphics.transformPoint(rX + rW, rY + rH)}
    v[4] = {love.graphics.transformPoint(rX, rY + rH)}

    return polyPoint(v, love.mouse.getPosition())
end

function ElementClass:draw()
    if not self.hide then
        love.graphics.push()
        for _, value in ipairs(self.elements) do
            if value and not value.hide and type(value.draw) == "function" then
                love.graphics.applyTransform(self:getTransform())
                value:draw()
            end
        end
        love.graphics.pop()
    end
end

return ElementClass
