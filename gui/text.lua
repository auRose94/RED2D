local GUIElement = require ".gui.element"
local GUIText = inheritsFrom(GUIElement)

function GUIText:init(parent, text)
	GUIElement.init(self, parent)
	self.text = text
	self.show = true
	self.enabled = true
	self.textSize = 0.5
	self.width = 32
	self.height = 32
	self.align = "left"
	self.opacity = 1

	self.textColor = Colors.white
end

function GUIText:draw()
	if self.show then
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