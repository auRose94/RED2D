local ComponentClass = require "component"
local InventoryWindow = require "comp-inventory-window"
local InventoryClass = inheritsFrom(ComponentClass)
local ItemClass = require "comp-item"
local WeaponClass = require "comp-weapon"
local renderBoundingBox = false

function InventoryClass:getName()
	return "InventoryClass"
end

function InventoryClass:init(parent, entity)
	ComponentClass.init(self, parent)
	self.items = {}
	self.maxWeight = 100
	self.open = false
	self.moveTarget = nil
	self.tradeTraget = nil
	self.pickUpDistance = 128
	self.window = InventoryWindow(parent, self)
	self.entity = entity
	self.entity = entity or nil
	self.pickup = false
end

function InventoryClass:setTargetInventory(inv)
	self.moveTarget = inv
end

function InventoryClass:setTradeInventory(inv)
	self.tradeTraget = inv
end

function InventoryClass:getWeight()
	local weight = 0
	for id, v in ipairs(self.items) do
		local count, item = unpack(v)
		weight = weight + (item.weight * count)
	end
	return weight
end

function InventoryClass:isOverweight()
	return self.maxWeight >= self:getWeight()
end

function InventoryClass:getBoundingBox()
	local cx, cy = self:getPosition()
	local scale = 600
	local tx, ty = cx-(scale), cy-(scale)
	local bx, by = cx+(scale), cy+(scale)
	return tx, ty, bx, by
end

function InventoryClass:toggleInventory()
	self.window:toggleWindow()
end

function InventoryClass:findIndex(item)
	for index, v in ipairs(self.items) do
		local itemType = v[2]
		if item.name == itemType.name then
			return index
		end
	end
	return false
end

function InventoryClass:subtract(item, number)
	if number == 0 or item == nil then
		return
	end
	local found = self:findIndex(item)
	if found then
		local current = self.items[found][1]
		local count = math.max(current, number)
		current = current - count
		if current <= 0 then
			table.remove(self.item, found)
		else
			self.items[found][1] = current
		end
	end
end

function InventoryClass:drop(item, number)
	if number > 0 then
		local level = self.parent.level
		local found = self:findIndex(item)
		if found then
			local count = math.max(self.items[found][1], number)
			local dx, dy = self.entity:getPosition()
			local dropEntity = EntityClass(level, item.name, dx, dy)
			local dropped = ItemClass(dropEntity, item.typeName)
			dropped.count = number
			self.items[found][1] = self.items[found][1] - count
			if self.items[found][1] <= 0 then
				table.remove(self.item, found)
			end
		end
	end
end

function InventoryClass:pickUp(item)
	if item.hide == false then
		item:destroyBody()
		item.parent:destroy()
		local found = self:findIndex(item)
		if found then
			self.items[found][1] = self.items[found][1] + item.count
		else
			table.insert(self.items, { item.count, item })
		end
	end
end

function InventoryClass:update(dt)
	local camera = self.parent.level.camera
	local world = self.parent.level.world
	local cx, cy = self.parent.transform:transformPoint(0, 3)
	local pickup = self.pickup

	function Q(fixture)
		local cat1, cat2 = fixture:getCategory( )
		if cat1 == 2 or cat2 == 2 then
			local body = fixture:getBody()
			local parent = body:getUserData()
			local ix, iy = parent:getPosition()
			local dist = math.dist(cx, cy, ix, iy)
			local item = parent:getComponent(ItemClass)
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

function InventoryClass:draw()
	if renderBoundingBox then
		local tx, ty, bx, by = self:getBoundingBox()
		love.graphics.setColor(0.76, 0.18, 0.05, 0.5)
		love.graphics.rectangle("fill",
		tx, ty,
		math.abs(tx - bx), math.abs(ty - by) )
	end
end

return InventoryClass