
local GUISystem = require ".gui.system"
local GUIWindow = require ".gui.window"
local GUIImage = require ".gui.image"
local GUIText = require ".gui.text"
local GUIButton = require ".gui.button"
local GUIScroll = require ".gui.scroll"
local InventoryWindow = inheritsFrom(GUISystem)

function InventoryWindow:init(parent, inventory)
	GUISystem.init(self, parent)
	self.inventory = inventory
	self.window = GUIWindow(self, "Inventory")
	self.scroll = GUIScroll(self.window)
	self.scroll.opacity = 0.75
	self.inventoryElements = {}
end

function InventoryWindow:update()
	local player = self.inventory.player
	local _, _, _, areaH = self.scroll:getInnerArea()
	self.scroll.width = self.window.width
	self.scroll.height = self.window.height
	local weight = self.inventory:getWeight()
	local maxWeight = self.inventory.maxWeight
	self.window.auxTitle = weight.."/"..maxWeight

	local buttonHeight = 42
	local buttonWidth = self.window.width
	if self.window.height < areaH then
		buttonWidth = buttonWidth - 16
	end
	local imageScale = 1.5
	if #self.inventory.items > #self.scroll.elements then
		local newElements = #self.inventory.items - #self.scroll.elements
		for i = 1, newElements, 1 do
			local index = (#self.scroll.elements + i)
			local listing = self.inventory.items[index]
			local count = listing[1]
			local item = listing[2]
			local itemWidth = item.rect[3]
			local itemHeight = item.rect[4]
			local button = GUIButton(self.scroll)
			button.borderSize = 1
			button.width = buttonWidth
			button.height = buttonHeight
			button.y = buttonHeight * (index-1)
			button.opacity = 0.5
			if item:canInteract() then
				button:onLeftClick(function ()
					item:use(player)
				end)
			end
			local text = GUIText(button, item.name.." ×"..count)
			text.y = -2
			text.width = buttonWidth - (itemWidth*2)
			text.height = buttonHeight
			text.textSize = 0.65
			text.align = "center"
			local image = GUIImage(button, item.image)
			image.opacity = 1
			image.sx = imageScale
			image.sy = imageScale
			image.y = ((buttonHeight/2)-((itemHeight*imageScale)/2))
			image.x = buttonWidth - (itemWidth*imageScale)
			image:setRect(item.rect)
		end
	end

	for i=1,#self.scroll.elements,1 do
		local button = self.scroll.elements[i]
		local listing = self.inventory.items[i]
		local count = listing[1]
		local item = listing[2]
		local itemWidth = item.rect[3]
		local itemHeight = item.rect[4]
		local text = button.elements[1]
		local image = button.elements[2]
		button.width = buttonWidth
		text.width = buttonWidth - (itemWidth*imageScale)-13
		text.text = item.name.." ×"..count
		image.y = ((buttonHeight/2)-((itemHeight*imageScale)/2))
		image.x = buttonWidth - (itemWidth*imageScale) - image.y
	end
	GUISystem.update(self)
end

function InventoryWindow:getName()
	return "InventoryWindow"
end

function InventoryWindow:toggleWindow()
	self.window:toggleWindow()
end

return InventoryWindow