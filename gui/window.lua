local GUIElement = require ".gui.element"
local GUIWindow = inheritsFrom(GUIElement)

function GUIWindow:init(parent, title, x, y, width, height)
	GUIElement.init(self, parent)
	assert(title)
	self.title = title
	self.auxTitle = ""
	self.x = x or 0
	self.y = y or 0
	self.width = width or 300
	self.height = height or 450
	self.minWidth = 300
	self.maxWidth = 1000
	self.minHeight = 32
	self.maxHeight = 1000
	self.show = true
	self.enabled = true
	self.offX = -350
	self.offY = -250
	self.buttonSize = 26
	self.textSize = 32
	self.lastSelect = false
	self.mouseOffsetX = nil
	self.mouseOffsetY = nil
	self.resizeOffsetX = nil
	self.resizeOffsetY = nil
end

function GUIWindow:toggleWindow()
	self.mouseOffsetX = nil
	self.mouseOffsetY = nil
	self.show = not self.show
end

function GUIWindow:getTransform()
	local transform = GUIElement.getTransform(self)
	transform:translate(self.offX, self.offY)
	return transform
end

function GUIWindow:update(dt)
	GUIElement.update(self, dt)
	if self.enabled then
		local camera = self.system.parent.level.camera
		local mouseX, mouseY = camera:mousePosition()
		local transform = self.parent:getTransform()
		local rmouseX, rmouseY = transform:inverseTransformPoint(mouseX, mouseY)
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
		local lastSelect = self.lastSelect
		self.lastSelect = self:getGUISelectControl()

		-- On Button Close
		if self.closeHover and not lastSelect and self.lastSelect then
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

		if self.moveHover and not lastSelect and self.lastSelect then
			self.mouseOffsetX = x - rmouseX
			self.mouseOffsetY = y - rmouseY
		end
		if (self.mouseOffsetX ~= nil or self.mouseOffsetY ~= nil) then
			self.offX = (self.mouseOffsetX + rmouseX)
			self.offY = (self.mouseOffsetY + rmouseY)
		end
		if lastSelect and not self.lastSelect and (self.mouseOffsetX ~= nil or self.mouseOffsetY ~= nil) then
			self.mouseOffsetX = nil
			self.mouseOffsetY = nil
		end

		-- Resize button
		local resizeX = x + (width-resizeSize-3) + (resizeSize/2)
		local resizeY = y + (height-resizeSize+19) + (resizeSize/2)
		local rx, ry = transform:transformPoint(resizeX, resizeY)
		local resizeShape = love.physics.newRectangleShape(rx, ry, resizeSize, resizeSize, camera.r)
		self.resizeHover = resizeShape:testPoint(0, 0, 0, mouseX, mouseY)

		if self.resizeHover and not lastSelect and self.lastSelect then
			self.resizeOffsetX = width - x - rmouseX
			self.resizeOffsetY = height - y - rmouseY
		end
		if (self.resizeOffsetX ~= nil or self.resizeOffsetY ~= nil) then
			self.width = x + (self.resizeOffsetX + rmouseX)
			self.height = y + (self.resizeOffsetY + rmouseY)
		end
		if lastSelect and not self.lastSelect and (self.resizeOffsetX ~= nil or self.resizeOffsetY ~= nil) then
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
	if self.show then
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