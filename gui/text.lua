local GUIElement = require ".gui.element"
local GUIText = inheritsFrom(GUIElement)

function GUIText:init(...)
	GUIElement.init(self, ...)
	self.text = self:getArgument("text", "")
	self.textSize = self:getArgument("textSize", 0.5)
	self.width = self:getArgument("width", 32)
	self.height = self:getArgument("height", 32)
	self.align = self:getArgument("align", "left")
	self.opacity = self:getArgument("opacity", 1)

	self.textColor = self:getArgument("textColor", Colors.white)
end

function GUIText:draw()
	if not self.hide then
		local opacity = self.opacity
		local camera = self.system.parent.level.camera
		local width = math.max(0, self.width)
		local textColor = self.textColor
		local limit = width / self.textSize
		local transform = self:getTransform()
		love.graphics.replaceTransform(camera:getTransform() * transform)

		love.graphics.setColor(textColor[1], textColor[2], textColor[3], opacity)
		love.graphics.printf(self.text, 0, 0, limit, self.align, 0, self.textSize)

		GUIElement.draw(self)
	end
end

return GUIText