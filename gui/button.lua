local GUIElement = require ".gui.element"
local GUIButton = inheritsFrom(GUIElement)

function GUIButton:init(...)
	GUIElement.init(self, ...)
	self.text = self:getArgument("text", "")
	self.hide = self:getArgument("hide", false)
	self.enabled = self:getArgument("enabled", true)
	self.textSize = self:getArgument("textSize", 0.5)
	self.width = self:getArgument("width", 32)
	self.height = self:getArgument("height", 32)
	self.borderSize = self:getArgument("borderSize", 1)

	self.boxHighlightColor = self:getArgument("boxHighlightColor", Colors.pansy)
	self.boxPressColor = self:getArgument("boxPressColor", Colors.brown)
	self.boxColor = self:getArgument("boxColor", Colors.red)
	self.lineColor = self:getArgument("lineColor", Colors.eggplant)
	self.textColor = self:getArgument("textColor", Colors.white)
	self.activeColor = self:getArgument("activeColor", Colors.magenta)
	self.disabledColor = self:getArgument("disabledColor", Colors.brown)

	local onLeftClickFunc = self:getArgument("onLeftClick", nil)
	if onLeftClickFunc then
		self:onLeftClick(onLeftClickFunc)
	end

	local onRightClickFunc = self:getArgument("onRightClick", nil)
	if onRightClickFunc then
		self:onLeftClick(onRightClickFunc)
	end
end

function GUIButton:update(dt)
	GUIElement.update(self, dt)
	if self.enabled or self:isActive() then
		local camera = self.system.parent.level.camera
		local mouseX, mouseY = camera:mousePosition()
		local width = math.max(0, self.width)
		local height = math.max(0, self.height)
		local centerX = self.x + (width/2)
		local centerY = self.y + (height/2)
		local transform = self.parent:getTransform()
		local cx, cy = transform:transformPoint(centerX, centerY)
		local shape = love.physics.newRectangleShape(cx, cy, width, height, camera.r)
		self.hover = shape:testPoint(0, 0, 0, mouseX, mouseY)
		
		if self.hover and self:getGUISelectControl():pressed() then
			if self.onLeftClickFunc then
				self:makeActive()
				self.onLeftClickFunc()
			end
		end
	
		if self.hover and self:getGUISecondaryControl():pressed() then
			if self.onRightClickFunc then
				self:makeActive()
				self.onRightClickFunc()
			end
		end
	end
end

function GUIButton:draw()
	if not self.hide then
		local opacity = self.opacity
		local width = math.max(0, self.width)
		local height = math.max(0, self.height)
		local boxColor = self.boxColor
		if self:isActive() then
			boxColor = self.activeColor
			opacity = math.max(math.sin(love.timer.getTime()*5), 0.75)
		end
		if not self.enabled then
			boxColor = self.disabledColor
		end
		local lineColor = self.lineColor
		local textColor = self.textColor
		local limit = width/self.textSize
		local transform = self:getTransform()
		local camera = self.system.parent.level.camera

		love.graphics.replaceTransform(camera:getTransform() * transform)

		if self.enabled and self.hover and (self.onRightClickFunc or self.onLeftClickFunc) then
			if self:getGUISelectControl():pressed() or self:getGUISecondaryControl():pressed() then
				boxColor = self.boxPressColor
			else
				boxColor = self.boxHighlightColor
			end
		end
		love.graphics.setColor(boxColor[1], boxColor[2], boxColor[3], opacity)
		love.graphics.rectangle('fill', 0, 0, width, height)
		if self.borderSize > 0 then
			love.graphics.setColor(lineColor[1], lineColor[2], lineColor[3], opacity)
			love.graphics.setLineWidth(self.borderSize)
			love.graphics.rectangle('line', 0, 0, width, height)
		end
		if self.text then
			love.graphics.setColor(textColor[1], textColor[2], textColor[3], opacity)
			love.graphics.printf(self.text, 0, -2, limit, "center", 0, self.textSize)
		end
	end

	GUIElement.draw(self)
end

function GUIButton:onRightClick(func)
	if func ~= nil and type(self.onClickFunc) == "function" then
		local old = self.onRightClickFunc
		self.onRightClickFunc = function()
			old(self)
			func(self)
		end
	else
		self.onRightClickFunc = func
	end
end

function GUIButton:onLeftClick(func)
	if func ~= nil and type(self.onClickFunc) == "function" then
		local old = self.onLeftClickFunc
		self.onLeftClickFunc = function()
			old(self)
			func(self)
		end
	else
		self.onLeftClickFunc = func
	end
end

return GUIButton