local Component = require "engine.component"
local Inventory = inheritsFrom(Component)
local Item = require "comp.item"
local Weapon = require "comp.weapon"
local renderBoundingBox = false

function Inventory:getName()
    return "Inventory"
end

function Inventory:init(parent, ...)
    Component.init(self, parent, ...)
    self.items = {}
    self.maxWeight = self.maxWeight or 100
    self.open = false
    self.moveTarget = nil
    self.tradeTarget = nil
    self.pickUpDistance = 128
    self.entity = self.entity or nil
    self.pickup = false
end

function Inventory:setTargetInventory(inv)
    self.moveTarget = inv
end

function Inventory:setTradeInventory(inv)
    self.tradeTarget = inv
end

function Inventory:getWeight()
    local weight = 0
    for id, v in ipairs(self.items) do
        local count, item = unpack(v)
        weight = weight + (item.weight * count)
    end
    return weight
end

function Inventory:isOverweight()
    return self.maxWeight >= self:getWeight()
end

function Inventory:getBoundingBox()
    local cx, cy = self:getPosition()
    local scale = 600
    local tx, ty = cx - scale, cy - scale
    local bx, by = cx + scale, cy + scale
    return tx, ty, bx, by
end

function Inventory:findIndex(item)
    if type(item) == "string" then
        item = Item.findItemById(item)
    end
    for index, v in ipairs(self.items) do
        local itemType = v[2]
        if item.name == itemType.name then
            return index
        end
    end
    return false
end

function Inventory:hasItem(item)
    local found = self:findIndex(item)
    return found ~= nil
end

function Inventory:subtract(item, number)
    local found = self:findIndex(item)
    if found then
        local current = self.items[found][1]
        local count = math.min(current, number)
        current = current - count
        if current <= 0 then
            table.remove(self.items, found)
        else
            self.items[found][1] = current
        end
        self.parent:callComponentMethods("onSubtract", item)
    end
end

function Inventory:drop(item, number)
    number = number or 1
    local level = self.parent.level
    local found = self:findIndex(item)
    if found then
        local count = math.max(1, math.min(self.items[found][1], number))
        local dx, dy = self:getPosition()
        local dropEntity = Entity(level, item.name, dx, dy)
        dropEntity.drawOrder = 0.01
        local dropped = item:class()(dropEntity, item.typeName)
        dropped.count = number
        local newCount = self.items[found][1] - count
        self.items[found][1] = newCount
        if newCount == 0 and item:canEquip() and item:isEquipped() then
            item:unequip()
        end
        if newCount <= 0 then
            table.remove(self.items, found)
        end
    end
end

function Inventory:pickUp(item)
    local added = false
    if item.hide == false then
        item:destroyBody()
        item.parent:destroy()
        local found = self:findIndex(item)
        if found then
            self.items[found][1] = self.items[found][1] + item.count
            added = true
        else
            table.insert(self.items, {item.count, item})
            added = true
        end
    end
    if added then
        self.parent:callComponentMethods("onPickUp", item)
    end
end

function Inventory:update(dt)
    local camera = self.parent.level.camera
    local world = self.parent.level.world
    local cx, cy = self.parent.transform:transformPoint(0, 3)
    local pickup = self.pickup

    function Q(fixture)
        local cat1, cat2 = fixture:getCategory()
        if cat1 == 2 or cat2 == 2 then
            local body = fixture:getBody()
            local parent = body:getUserData()
            local ix, iy = parent:getPosition()
            local dist = math.dist(cx, cy, ix, iy)
            local item = parent:getComponent(Item)
            if item then
                if dist <= self.pickUpDistance then
                    function R(rayFixture, x, y, xn, yn, fraction)
                        if fixture:getCategory() ~= 2 then
                            return 0
                        end
                        if rayFixture == fixture then
                            item:setHighlight(true)
                            if pickup then
                                self:pickUp(item)
                                pickup = false
                            end
                            return 0
                        end
                        return 1
                    end
                    world:rayCast(cx, cy, ix, iy, R)
                else
                    item:setHighlight(false)
                end
            end
        end
        return true
    end
    local tx, ty, bx, by = self:getBoundingBox()
    world:queryBoundingBox(tx, ty, bx, by, Q)
end

function Inventory:draw()
    if renderBoundingBox then
        local tx, ty, bx, by = self:getBoundingBox()
        love.graphics.setColor(0.76, 0.18, 0.05, 0.5)
        love.graphics.rectangle("fill", tx, ty, math.abs(tx - bx), math.abs(ty - by))
    end
end

return Inventory
