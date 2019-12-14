local GUIButton = require ".gui.button"
local GUIElement = require ".gui.element"
local GUIDropdown = inheritsFrom(GUIButton)

function GUIDropdown:init(...)
	GUIButton.init(self, ...)
	self.enabled = self:getArgument("enabled", true)
	self.hide = self:getArgument("hide", false)
end

function GUIDropdown:newMenu(...)
	local menu = self:append(GUIElement(...))
	menu.hide = true
	menu.enabled = false
	self.menu = menu
	return menu
end

function GUIDropdown:getChildTransform()
	local transform = GUIElement.getTransform(self)
	transform:translate(0, -self.height)
	return transform
end

function GUIDropdown:getClipping()
	local areaX, areaY, areaW, areaH = self:getInnerArea()
	local lx, ly, bx, by = GUIElement.getClipping(self, 0, 0, areaW, areaH)
	return lx, ly, bx, by
end

return GUIDropdown