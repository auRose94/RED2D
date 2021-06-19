-- local imgui = require"imgui"
local Entity = inheritsFrom(nil)

function Entity:init(level, name, x, y, z, r, sx, sy, ox, oy, kx, ky)
    assert(level, "No level given")
    level:addEntity(self)
    self.level = level
    self.x = x
    self.y = y
    self.z = z or 0
    self.r = r or 0
    self.sx = sx or 1
    self.sy = sy or self.sx
    self.ox = ox or 0
    self.oy = oy or 0
    self.kx = kx or 0
    self.ky = ky or 0
    self.drawOrder = 0
    self.touched = false
    self.components = {}
    self.children = {}
    self.transform =
        love.math.newTransform(self.x, self.y, self.r, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
    self.name = name or "New Entity"
end

function Entity:getName()
    return "Entity"
end

function Entity:callComponentMethods(name, ...)
    if name == nil or name == "" then
        return
    end
    for _, c in pairs(self.components) do
        if type(c) == "table" then
            local method = c[name] or nil
            if type(method) == "function" then
                method(c, ...)
            end
        end
    end
end

function Entity:update(dt)
    self:callComponentMethods("update", dt)
end

function Entity:drawEditor()
    local keys = sortedKeys(self)
    for index, name in pairs(keys) do
        local value = self[name]
        local t = type(value)
        if type(name) == "string" then
            if t == "number" then
                self[name] = imgui.DragFloat(name, value)
            elseif t == "string" then
                local changed, newValue = imgui.InputText(name, value, #value + 16)
                if changed then
                    self[name] = changed
                end
            elseif t == "boolean" then
                self[name] = imgui.Checkbox(name, value)
            end
        end
    end
end

function Entity:draw()
    love.graphics.applyTransform(self:getTransform())
    for _, c in pairs(self.components) do
        if type(c) == "table" and c.draw then
            c:draw()
        end
    end
end

function Entity:destroy()
    self:callComponentMethods("destroy")
    for _, c in pairs(self.components) do
        if type(c) == "table" then
            c.parent = nil
        end
    end
    if self.parent then
        self.parent:removeChild(self)
    end
    self.components = {}
    self.transform = nil
    self.level:removeEntity(self)
end

function Entity:setPosition(...)
    local x, y = ...
    if type(x) == "table" then
        x, y = unpack(...)
    end
    self.touched = true
    self.x = x
    self.y = y
end

function Entity:getUp()
    local transform = self:getTransform()
    return self:transformNormal(0, 1)
end

function Entity:getRight()
    local transform = self:getTransform()
    return self:transformNormal(1, 0)
end

function Entity:getWorldPosition()
    local transform = self:getTransform()
    return transform:transformPoint(0, 0)
end

function Entity:getPosition()
    return self.x, self.y
end

function Entity:setRotation(r)
    self.touched = true
    self.r = r
end

function Entity:getRotation()
    return self.r
end

function Entity:setScale(...)
    local x, y = ...
    if type(x) == "table" then
        x, y = unpack(...)
    end
    self.sx = x
    self.sy = y
    self.touched = true
end

function Entity:getScale()
    return self.sx, self.sy
end

function Entity:setSkew(...)
    local x, y = ...
    if type(x) == "table" then
        x, y = unpack(...)
    end
    self.kx = x
    self.ky = y
    self.touched = true
end

function Entity:getSkew()
    return self.kx, self.ky
end

function Entity:setOrigin(...)
    local x, y = ...
    if type(x) == "table" then
        x, y = unpack(...)
    end
    self.ox = x
    self.oy = y
    self.touched = true
end

function Entity:getOrigin()
    return self.ox, self.oy
end

function Entity:getTransform()
    if self.touched or not self.transform then
        self.transform =
            love.math.newTransform(self.x, self.y, self.r, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
        self.touched = false
    end
    if self.parent then
        return self.parent:getTransform() * self.transform
    end
    return self.transform
end

function Entity:getComponent(typeOrObject)
    assert(type(self.components) == "table", "Components is not a table")
    for index, v in pairs(self.components) do
        if typeOrObject == v or v:isa(typeOrObject) then
            return v
        end
    end
    return nil
end

function Entity:getComponents(typeClass)
    assert(type(self.components) == "table", "Components is not a table")
    local comps = {}
    for index, v in pairs(self.components) do
        if v:isa(typeClass) then
            table.insert(comps, v)
        end
    end
    for childIndex, child in pairs(self.children) do
        local childComps = child:getComponents(typeClass)
        for index, v in pairs(childComps) do
            table.insert(comps, v)
        end
    end
    return comps
end

function Entity:getParentComponent(typeClass)
    -- Recursively goes up from the child to the parent to get a component
    if self.parent then
        local component = self.parent:getComponent(typeClass)
        if not component then
            return self.parent:getParentComponent(typeClass)
        end
        return component
    end
    return nil
end

function Entity:addComponent(comp)
    assert(type(self.components) == "table", "Components is not a table")
    table.insert(self.components, comp)
    comp.parent = self
end

function Entity:removeComponent(compOrTypeOrIndex)
    local found = false
    local value = nil
    if type(compOrTypeOrIndex) == "number" then
        value = self.components[compOrTypeOrIndex]
        found = compOrTypeOrIndex
    elseif type(compOrTypeOrIndex) == "table" then
        for index, v in ipairs(self.components) do
            if compOrTypeOrIndex == v or v:isa(compOrTypeOrIndex) then
                value = v
                found = index
                break
            end
        end
    end
    if found and value then
        -- value:destroy()
        value.parent = nil
        table.remove(self.components, found)
        return value
    end
end

function Entity:findChild(name)
    local value = nil
    local found = nil
    for index, child in ipairs(self.children) do
        if child.name == name then
            value = child
            found = index
            break
        end
    end
    return value, found
end

function Entity:removeChild(child)
    local found = false
    local value = nil
    for index, child in ipairs(self.children) do
        if child == child then
            value = child
            found = index
            break
        end
    end
    if found and value then
        -- value:destroy()
        value.parent = nil
        table.remove(self.children, found)
        return value
    end
end

function Entity:setParent(parent)
    if parent then
        self.parent = parent
        table.insert(parent.children, self)
    else
        self.parent:removeChild(self)
        self.parent = nil
    end
end

function Entity:transformPoint(...)
    local x, y = ...
    if type(x) == "table" then
        x, y = unpack(...)
    end
    local transform = self:getTransform()
    return transform:transformPoint(x, y)
end

function Entity:inverseTransformPoint(...)
    local x, y = ...
    if type(x) == "table" then
        x, y = unpack(...)
    end
    local transform = self:getTransform()
    return transform:inverseTransformPoint(x, y)
end

function Entity:transformNormal(...)
    local x, y = ...
    if type(x) == "table" then
        x, y = unpack(...)
    end
    x, y = math.normalize(x, y)
    local transform = self:getTransform()
    local wx, wy = transform:transformPoint(0, 0)
    x, y = transform:transformPoint(x, y)
    return math.normalize(wx - x, wy - y)
end

function Entity:inverseTransformNormal(...)
    local x, y = ...
    if type(x) == "table" then
        x, y = unpack(...)
    end
    x, y = math.normalize(x, y)
    local transform = self:getTransform()
    local wx, wy = transform:inverseTransformPoint(0, 0)
    x, y = transform:inverseTransformPoint(x, y)
    return math.normalize(wx - x, wy - y)
end

_G.Entity = Entity

return Entity
