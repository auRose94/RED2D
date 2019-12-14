
local GUISystem = require ".gui.system"
local GUIElement = require ".gui.element"
local GUIWindow = require ".gui.window"
local GUIImage = require ".gui.image"
local GUIText = require ".gui.text"
local GUIButton = require ".gui.button"
local GUIScroll = require ".gui.scroll"
local GUIDropdown = require ".gui.dropdown"
local InventoryClass = require "comp-inventory"
local StatusWindow = inheritsFrom(GUISystem)

function StatusWindow:init(parent)
	GUISystem.init(self, parent)
	self.inventory = parent:getComponent(InventoryClass)
	self.player = parent:getComponent(PlayerComponent or require "comp-player")
	local window = GUIWindow(self, {
		title = "Status",
		maxWidth = 600,
		maxHeight = nil
	})

	local statusButton = GUIButton(window, {
		text = "Status",
		width = 100,
		onLeftClick = function(button)
			self:changeTo("status")
		end
	})
	local inventoryButton = GUIButton(window, {
		text = "Inventory",
		x = 100,
		width = 100,
		onLeftClick = function(button)
			self:changeTo("inventory")
		end
	})
	local questsButton = GUIButton(window, {
		text = "Quests",
		x = 200,
		width = 100,
		onLeftClick = function(button)
			self:changeTo("quests")
		end
	})

	local rootUpdate = function(element)
		element.width, element.height = self:getRootSize()
	end
	local statusRoot = GUIElement(window, {
		y = 32,
		onUpdate = rootUpdate
	})
	local inventoryRoot = GUIElement(window, {
		y = 32,
		onUpdate = rootUpdate
	})
	local questsRoot = GUIElement(window, {
		y = 32,
		onUpdate = rootUpdate
	})

	local categoryDropdown = GUIDropdown(inventoryRoot, {
		text = "Category",
		width = 100
	})
	local categoryMenu = categoryDropdown:newMenu({
		width = 100,
		height = 32*5
	},
		GUIButton({ text = "Weapon" }),
		GUIButton({ text = "Accessory", y = 32 }),
		GUIButton({ text = "Assistive", y = 32*2 }),
		GUIButton({ text = "Quest", y = 32*3 }),
		GUIButton({ text = "Miscellaneous", y = 32*4 })
	)

	self.window = window
	self.buttons = {}
	self.currentButton = statusButton
	self.buttons.status = statusButton
	self.buttons.inventory = inventoryButton
	self.buttons.quests = questsButton

	self.inventory = {}
	self.inventory.categoryMenu = categoryMenu

	self.roots = {}
	self.currentRoot = statusRoot
	self.roots.status = statusRoot
	self.roots.inventory = inventoryRoot
	self.roots.quests = questsRoot
	self:changeTo("status")
end

function StatusWindow:changeTo(mode)
	local last = self.currentRoot
	last.enabled = false
	last.hide = true
	local lastButton = self.currentButton or self.statusButton
	lastButton.enabled = true
	self.currentButton = self.buttons[mode] or self.currentButton
	self.currentButton:makeActive()
	self.currentButton.enabled = false
	self.currentRoot = self.roots[mode] or last
	self.currentRoot.enabled = true
	self.currentRoot.hide = false
end

function StatusWindow:getRootSize()
	return self.window.width, self.window.height-32
end

function StatusWindow:getName()
	return "StatusWindow"
end

function StatusWindow:toggleWindow()
	self.window:toggleWindow()
end

return StatusWindow