local Component = require "component"
local PhysicsComponent = require "comp.physics"
local LoadedItems = require "defaultItems"
local guiStyle = require "gui-style"
-- local imgui = require"imgui"
local Item = inheritsFrom(Component)

function Item.registerItem(data)
    local key = data.id
    assert(key ~= nil, "Missing id for item instance")
    LoadedItems[key] = data
end

function Item.findItemById(id)
    for vid, v in pairs(LoadedItems) do
        if vid == id then
            return v
        end
    end
    return nil
end

function Item.findItemByName(name)
    for _, v in pairs(LoadedItems) do
        if v.name == name then
            return v
        end
    end
    return nil
end

function Item:getName()
    return "Item"
end

function Item:init(parent, data, ...)
    Component.init(self, parent, ...)
    self.parent.drawOrder = 0
    if type(data) == "string" then
        self.typeName = data
        data = Item.findItemById(data) or Item.findItemByName(data)
    end
    assert(data.name ~= nil)
    assert(data.rect ~= nil)
    assert(data.image ~= nil)
    assert(data.shape ~= nil)

    self.name = data.name or ""
    self.type = data.type or nil
    self.description = data.description or ""
    self.image = data.image or love.graphics.newImage("assets/Items.png")
    self:setRect(data.rect)
    self.color = data.color or {1, 1, 1, 1}
    self.hide = false
    self.weight = data.weight or 0
    self.value = data.weight or 1
    self.count = data.count or 1
    self:setOrigin(data.ox or 0, data.oy or 0)
    self.useFunction = data.useFunction or nil
    self.highlighted = false
    self.timeHighlighted = love.timer.getTime()

    if data.shape then
        self.shapeFunc = data.shape
        self.mass = data.mass or nil
        self.density = data.density or 1
        self.friction = data.friction or 0.1
        self.restitution = data.restitution or 0
        self.category = data.category or {2}
        self.mask = data.mask or {3}
        self:createBody()
    end
end

--[[
function Item:drawStats()
	-- Override with imgui calls
	imgui.Text("Count: ")
	imgui.SameLine()
	imgui.TextColored(255, 0, 255, 255, tostring(self.count))
	imgui.Text("Value: ")
	imgui.SameLine()
	imgui.TextColored(255, 0, 255, 255, tostring(self.value))
	if self.weight > 0 then
		imgui.Text("Weight: ")
		imgui.SameLine()
		imgui.TextColored(255, 0, 255, 255, tostring(self.count * self.weight))
	end
end
]]
function Item:isWeapon()
    return self.type == "weapon"
end

function Item:isArmor()
    return self.type == "armor"
end

function Item:isConsumable()
    return self.type == "armor"
end

function Item:canInteract()
    return self:isConsumable()
end

function Item:canEquip()
    return self:isWeapon() or self:isArmor()
end

function Item:canDrop()
    return true -- Overide if you want to prevent...
end

function Item:setActive(boolean)
    assert(self.physBody, "No physical body")
    self.physBody:setActive(boolean)
    self.hide = boolean == false
end

function Item:destroyBody()
    if self.physBody then
        self.physBody:destroy()
        self.physBody = nil
    end
end

function Item:createBody()
    assert(self.shapeFunc)
    self.shape = self.shapeFunc() or nil
    self.physBody = PhysicsComponent(self.parent, "dynamic")

    self.fixture = self.physBody:newFixture(self.shape, self.density)
    if #self.category > 0 then
        self.fixture:setCategory(unpack(self.category))
    end
    if #self.mask > 0 then
        self.fixture:setMask(unpack(self.mask))
    end
    self.fixture:setFriction(self.friction)
    self.fixture:setRestitution(self.restitution)
    self.physBody:setMass(self.mass)
end

function Item:setHighlight(value)
    if not self.highlighted and value == true then
        self.timeHighlighted = love.timer.getTime()
    end
    self.highlighted = value
end

function Item:setRect(rectOrX, y, w, h)
    local rect = {}
    if type(rectOrX) == "table" and #rectOrX == 4 then
        rect = rectOrX
    elseif type(rectOrX) == "number" then
        rect = {rectOrX, y, w, h}
    end
    assert(#rect == 4, "Missing arguments")
    local change = false
    if type(self.rect) == "table" then
        for i = 1, #rect do
            if rect[i] ~= self.rect[i] then
                change = true
                break
            end
        end
    else
        change = true
    end
    if change or not self.quad then
        self.rect = rect
        self.quad =
            love.graphics.newQuad(rect[1], rect[2], rect[3], rect[4], self.image:getWidth(), self.image:getHeight())
    end
end

function Item:update(dt)
    local curText = {colors.white, "⇩", colors.red, self.name, colors.white, "×", colors.red, self.count}
    if not self.text or unpack(curText) ~= unpack(self.text) then
        self.text = curText
        self.textObj = love.graphics.newText(guiStyle.font, curText)
    end
end

function Item:draw()
    if self.image and self.quad and not self.hide then
        local v = love.timer.getTime() - self.timeHighlighted
        local camera = self.parent.level.camera
        local opacity = math.max(math.cos(v * 5) + 1, 0.5)
        if self.highlighted then
            love.graphics.setColor(1, 1, 1, opacity)
        else
            love.graphics.setColor(self.color)
        end
        love.graphics.draw(self.image, self.quad)
        if self.highlighted and self.textObj then
            love.graphics.setColor(math.cos(v * 5) + 1.5, math.cos(v * 5) + 1.5, math.cos(v * 5) + 1.5)
            love.graphics.push()
            love.graphics.rotate(camera.r)
            love.graphics.translate(0, -48)
            love.graphics.draw(self.textObj, 0, math.cos(v * 5) * 16)
            love.graphics.pop()
        end
    end
end

return Item
