
local GUISystem = require ".gui.system"
local GUIElement = require ".gui.element"
local GUIWindow = require ".gui.window"
local GUIImage = require ".gui.image"
local GUIText = require ".gui.text"
local GUIButton = require ".gui.button"
local GUIScroll = require ".gui.scroll"
local InventoryClass = require "comp-inventory"
local PlayerComponent = require "comp-player"
local StatusWindow = inheritsFrom(GUISystem)

function StatusWindow:init(parent)
	GUISystem.init(self, parent)
	self.inventory = parent:getComponent(InventoryClass)
	self.player = parent:getComponent(PlayerComponent)
	local window = GUIWindow(self, "Status")

	local statusButton = GUIButton(window, "Status")
	statusButton.width = 100
	statusButton:onLeftClick(function()
		self:changeTo("status", statusButton)
	end)
	local inventoryButton = GUIButton(window, "Inventory")
	inventoryButton.x = 100
	inventoryButton.width = 100
	inventoryButton:onLeftClick(function()
		self:changeTo("inventory", inventoryButton)
	end)
	local questsButton = GUIButton(window, "Quests")
	questsButton.x = 200
	questsButton.width = 100
	questsButton:onLeftClick(function()
		self:changeTo("quests", questsButton)
	end)

	local statusRoot = GUIElement(window)
	statusRoot.y = 32
	statusRoot:onUpdate(function()
		statusRoot.width, statusRoot.height = self:getRootSize()
	end)

	local inventoryRoot = GUIElement(window)
	inventoryRoot.y = 32
	inventoryRoot:onUpdate(function()
		inventoryRoot.width, inventoryRoot.height = self:getRootSize()
	end)
	
	local questsRoot = GUIElement(window)
	questsRoot.y = 32
	questsRoot:onUpdate(function()
		questsRoot.width, questsRoot.height = self:getRootSize()
	end)

	self.window = window
	self.statusButton = statusButton
	self.inventoryButton = inventoryButton
	self.questsButton = questsButton

	self.roots = {}
	self.currentRoot = statusRoot
	self.roots.status = statusRoot
	self.roots.inventory = inventoryRoot
	self.roots.quests = questsRoot
end

function StatusWindow:changeTo(mode, button)
	local last = self.currentRoot
	last.enabled = false
	local lastButton = self.currentButton
	lastButton.enabled = true
	self.currentButton = button
	self.currentButton.enabled = false
	self.currentRoot = self.roots[mode] or last
	self.currentRoot.enabled = true
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