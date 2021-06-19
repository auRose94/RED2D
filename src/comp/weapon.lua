local Item = require "comp.item"
local Entity = require "entity"
local WeaponTypes = require "defaultWeaponTypes"
-- local imgui = require"imgui"
local Weapon = inheritsFrom(Item)

function Weapon:getName()
    return "Weapon"
end

function Weapon:init(parent, data, ...)
    Item.init(self, parent, data, ...)
    if type(data) == "string" then
        data = Item.findItemById(data) or Item.findItemByName(data)
    end
    assert(type(data) == "table")
    self.attackRate = data.attackRate or 1
    self.altAttackRate = data.altAttackRate or nil
    self.frames = data.frames or {}
    self.currentFrame = 1
    self.trigger = data.trigger or {0, 0}
    self.aimPoint = data.aimPoint or {0, 0}
    self.lastAttack = love.timer.getTime()
    self.altLastAttack = love.timer.getTime()
end

--[[
function Weapon:drawStats()
	-- Override with imgui calls
	imgui.Text("Attack Rate: ")
	imgui.SameLine()
	imgui.TextColored(255, 0, 255, 255, tostring(self.attackRate))
	if self.altAttackRate ~= nil then
		imgui.Text("Alt Attack Rate: ")
		imgui.SameLine()
		imgui.TextColored(255, 0, 255, 255, tostring(self.altAttackRate))
	end
	Item.drawStats(self)
end
]]
function Weapon:equip(entity)
    if entity and not self:isEquipped() then
        local hands = entity:getWeaponMounts()
        local hand = entity.parent
        local handIndex = nil
        for hi, ho in pairs(hands) do
            if not ho:getComponent(Weapon) then
                hand = ho
                handIndex = hi
            end
        end
        local level = hand.level or entity.parent.level
        hand:setOrigin(self.trigger)
        local weaponEntity = Entity(level, self.name .. "(Equipped)")
        weaponEntity:setParent(hand)
        weaponEntity:addComponent(self)
        weaponEntity:setOrigin(math.invert(self.trigger))
        entity.weapons[handIndex] = self
        self.handIndex = handIndex
        self.hand = hand
        self.entity = entity
        self.hide = false
        self.highlighted = false
    end
end

function Weapon:unequip()
    local entity = self.entity
    local parent = self.parent
    if entity and self:isEquipped() then
        parent:removeComponent(self)
        parent:destroy()
        entity.weapons[self.handIndex] = nil
        self.handIndex = nil
        self.entity = nil
        self.hide = true
    end
end

function Weapon:isPlayer()
    return self.entity and isa(self.entity, PlayerComponent)
end

function Weapon:isEquipped()
    return self.entity and self.entity.weapons[self.handIndex] == self
end

function Weapon:getTypeName()
    return self.weaponType.name or "Undefined"
end

function Weapon:primary()
    assert(true, "You need to override this method")
end

function Weapon:secondary()
    assert(true, "You need to override this method")
end

function Weapon:update(dt)
    local now = love.timer.getTime()
    if self.attackRate ~= nil and self.firing then
        if now - self.lastAttack >= self.attackRate then
            self.lastAttack = now
            self:primary()
        end
    end

    if self.altAttackRate ~= nil and self.altFiring then
        if now - self.altLastAttack >= self.altAttackRate then
            self.altLastAttack = now
            self:secondary()
        end
    end
end

function Weapon:draw()
    self:setRect(self.frames[self.currentFrame])
    Item.draw(self)
end

return Weapon
