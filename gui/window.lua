local GUIElement = require ".gui.element"
local GUIWindow = inheritsFrom(GUIElement)

function GUIWindow:init(...)
	GUIElement.init(self, ...)
	self.title = self:getArgument("title", "")
	self.auxTitle = self:getArgument("auxTitle", "")
	self.x = self:getArgument("x", 0)
	self.y = self:getArgument("y", 0)
	self.width = self:getArgument("width", 300)
	self.height = self:getArgument("height", 450)
	self.minWidth = self:getArgument("minWidth", 300)
	self.maxWidth = self:getArgument("maxWidth", 1000)
	self.minHeight = self:getArgument("minHeight", 32)
	self.maxHeight = self:getArgument("maxHeight", 1000)
	self.hide = self:getArgument("hide", false)
	self.enabled = self:getArgument("enabled", true)
	self.offX = self:getArgument("offX", -350)
	self.offY = self:getArgument("offY", -250)
	self.buttonSize = self:getArgument("buttonSize", 26)
	self.textSize = self:getArgument("textSize", 32)
	self.mouseOffsetX = nil
	self.mouseOffsetY = nil
	self.resizeOffsetX = nil
	self.resizeOffsetY = nil
end

function GUIWindow:toggleWindow()
	self.mouseOffsetX = nil
	self.mouseOffsetY = nil
	self.hide = not self.hide
end

function GUIWindow:getTransform()
	local transform = GUIElement.getTransform(self)
	transform:translate(self.offX, self.offY)
	return transform
end

function GUIWindow:update(dt)
	GUIElement.update(self, dt)
	if self.enabled and self.system then
		local camera = self.system.parent.level.camera
		local mouseX, mouseY = camera:mousePosition()
		local transform = self.parent:getTransform()
		local rMouseX, rMouseY = transform:inverseTransformPoint(mouseX, mouseY)
		local width = self.width
		local height = self.height
		local x = self.x + self.offX
		local y = self.y + self.offY
		local buttonSize = self.buttonSize
		local resizeSize = 16
		local textOffset = 2
		local textSize = self.textSize
		local topBarHeight = textSize

		-- Close Button
		local closeX = x + (width-buttonSize-3) + (buttonSize/2)
		local closeY = y + 3 - topBarHeight + (buttonSize/2)
		local cx, cy = transform:transformPoint(closeX, closeY)
		local closeShape = love.physics.newRectangleShape(cx, cy, buttonSize, buttonSize, camera.r)
		self.closeHover = closeShape:testPoint(0, 0, 0, mouseX, mouseY)

		-- Select State
		local click = self:getGUISelectControl()

		-- On Button Close
		if self.closeHover and click:pressed() then
			self:toggleWindow()
		end

		-- Move Area
		if not self.closeHover then
			local moveX = x + (width / 2)
			local moveY = y - topBarHeight + (topBarHeight / 2)
			local mx, my = transform:transformPoint(moveX, moveY)
			local moveShape = love.physics.newRectangleShape(mx, my, width, topBarHeight, camera.r)
			self.moveHover = moveShape:testPoint(0, 0, 0, mouseX, mouseY)
		end

		if self.moveHover and click:pressed() then
			self.mouseOffsetX = x - rMouseX
			self.mouseOffsetY = y - rMouseY
		end
		if (self.mouseOffsetX ~= nil or self.mouseOffsetY ~= nil) then
			self.offX = (self.mouseOffsetX + rMouseX)
			self.offY = (self.mouseOffsetY + rMouseY)
		end
		if click:released() and (self.mouseOffsetX ~= nil or self.mouseOffsetY ~= nil) then
			self.mouseOffsetX = nil
			self.mouseOffsetY = nil
		end

		-- Resize button
		local resizeX = x + (width-resizeSize-3) + (resizeSize/2)
		local resizeY = y + (height-resizeSize+19) + (resizeSize/2)
		local rx, ry = transform:transformPoint(resizeX, resizeY)
		local resizeShape = love.physics.newRectangleShape(rx, ry, resizeSize, resizeSize, camera.r)
		self.resizeHover = resizeShape:testPoint(0, 0, 0, mouseX, mouseY)

		if self.resizeHover and click:pressed() then
			self.resizeOffsetX = width - x - rMouseX
			self.resizeOffsetY = height - y - rMouseY
		end
		if self.resizeOffsetX ~= nil or self.resizeOffsetY ~= nil then
			self.width = x + (self.resizeOffsetX + rMouseX)
			self.height = y + (self.resizeOffsetY + rMouseY)
		end
		if click:released() and (self.resizeOffsetX ~= nil or self.resizeOffsetY ~= nil) then
			self.resizeOffsetX = nil
			self.resizeOffsetY = nil
		end

		self.width = math.max(self.minWidth, self.width)
		if self.maxWidth then
			self.width = math.min(self.width, self.maxWidth)
		end
		self.height = math.max(self.minHeight, topBarHeight, self.height)
		if self.maxHeight then
			self.height = math.min(self.height, self.maxHeight)
		end

	end
end

function GUIWindow:getClipping()
	local lx, ly, bx, by = GUIElement.getClipping(self, 0, 0, 1, 1)
	return lx, ly, bx, by
end

function GUIWindow:draw()
	if not self.hide and self.system then
		local camera = self.system.parent.level.camera
		local transform = self:getTransform()
		local width = self.width
		local height = self.height
		local titleArea = width - 64
		local textOffset = 2
		local textSize = self.textSize
		local topBarHeight = textSize
		local buttonSize = self.buttonSize
		local resizeSize = 16
		local windowAreaHeight = self.height + resizeSize + 6
		local opacity = self.opacity

		love.graphics.replaceTransform(camera:getTransform() * transform)

		--Top bar
		local moveColor = Colors.red
		if self.moveHover and not self.closeHover then
			moveColor = Colors.pansy
		end
		love.graphics.setColor(moveColor[1], moveColor[2], moveColor[3], opacity)
		love.graphics.rectangle('fill', 0, -topBarHeight, width, topBarHeight)
		
		--Window area
		love.graphics.setColor(Colors.brown[1], Colors.brown[2], Colors.brown[3], opacity)
		love.graphics.rectangle('fill', 0, 0, width, windowAreaHeight)

		--Title
		love.graphics.setColor(Colors.white[1], Colors.white[2], Colors.white[3], opacity)
		love.graphics.printf(self.title, 0, -topBarHeight-4, titleArea, "left", 0)

		--Close
		local closeColor = Colors.brown
		if self.closeHover then
			closeColor = Colors.red
		end
		love.graphics.setColor(closeColor[1], closeColor[2], closeColor[3], opacity)
		love.graphics.rectangle('fill', (width-buttonSize-3), 3-topBarHeight, buttonSize, buttonSize)
		love.graphics.setColor(Colors.white[1], Colors.white[2], Colors.white[3], opacity)
		love.graphics.printf("❌", (width-buttonSize-1), 5-topBarHeight, titleArea, "left", 0, 0.75)

		GUIElement.draw(self)

		-- Auxillary title
		if self.auxTitle then
			local auxTitleArea = width - (resizeSize-1)
			love.graphics.setColor(Colors.white[1], Colors.white[2], Colors.white[3], opacity)
			love.graphics.printf(self.auxTitle, 1, height, auxTitleArea, "left", 0, 0.5)
		end

		--Resize
		local resizeColor = Colors.brown
		if self.resizeHover then
			resizeColor = Colors.red
		end
		love.graphics.setColor(resizeColor[1], resizeColor[2], resizeColor[3], opacity)
		love.graphics.rectangle('fill', (width-resizeSize-3), (height-resizeSize+19), resizeSize, resizeSize)
		love.graphics.setColor(Colors.white[1], Colors.white[2], Colors.white[3], opacity)
		love.graphics.printf("◿", (width-resizeSize-1), (height-resizeSize+9), titleArea, "left", 0, 0.75)

	end
end


return GUIWindow