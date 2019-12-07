local GUIElement = require ".gui.element"
local GUIButton = inheritsFrom(GUIElement)

function GUIButton:init(parent, text)
	GUIElement.init(self, parent)
	self.text = text
	self.show = true
	self.enabled = true
	self.textSize = 0.5
	self.width = 32
	self.height = 32
	self.borderSize = 2

	self.boxHighlightColor = Colors.pansy
	self.boxPressColor = Colors.brown  
	self.boxColor = Colors.red
	self.lineColor = Colors.eggplant
	self.textColor = Colors.white
end

function GUIButton:update(dt)
	GUIElement.update(self, dt)
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

	local lastLeftSelect = self.lastLeftSelect
	local lastRightSelect = self.lastRightSelect
	self.lastLeftSelect = self:getGUISelectControl()
	self.lastRightSelect = self:getGUISecondaryControl()
	
	if self.hover and lastLeftSelect and not self.lastLeftSelect then
		if self.onLeftClickFunc then
			self.onLeftClickFunc()
		end
	end

	if self.hover and lastRightSelect and not self.lastRightSelect then
		if self.onRightClickFunc then
			self.onRightClickFunc()
		end
	end
end

function GUIButton:draw()
	local opacity = self.opacity
	local width = math.max(0, self.width)
	local height = math.max(0, self.height)
	local boxColor = self.boxColor
	local lineColor = self.lineColor
	local textColor = self.textColor
	local limit = width/self.textSize
	local transform = self:getTransform()
	local camera = self.system.parent.level.camera

	love.graphics.replaceTransform(camera:getTransform() * transform)
	
	if self.hover and (self.onRightClickFunc or self.onLeftClickFunc) then
		if self.lastSelect then
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

	GUIElement.draw(self)
end

function GUIButton:onRightClick(func)
	if func ~= nil and type(self.onClickFunc) == "function" then
		local old = self.onRightClickFunc
		self.onRightClickFunc = function() 
			old()
			func()
		end
	else
		self.onRightClickFunc = func
	end
end

function GUIButton:onLeftClick(func)
	if func ~= nil and type(self.onClickFunc) == "function" then
		local old = self.onLeftClickFunc
		self.onLeftClickFunc = function() 
			old()
			func()
		end
	else
		self.onLeftClickFunc = func
	end
end

return GUIButton