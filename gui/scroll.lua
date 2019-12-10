local GUIElement = require ".gui.element"
local GUIScroll = inheritsFrom(GUIElement)

local areaOffset = 8

function GUIScroll:init(parent, x, y, width, height)
	GUIElement.init(self, parent)
	self.x = x or 0
	self.y = y or 0
	self.width = width or 300
	self.height = height or 450
	self.show = true
	self.enabled = true
	self.offset = 0
	self.buttonOffset = nil
end

function GUIScroll:getScrollWidthAndOffset()
	local areaX, areaY, areaW = self:getInnerArea()
	local width = self.width
	local ratio = width * (width/areaW)
	local clamp = math.min(width, (math.max(ratio, 0)))
	local endPoint = width-clamp
	local scrollButtonXOffset = math.min(math.max(self.offset * areaW, 0), endPoint)
	if scrollButtonXOffset ~= 0 then
		local percentage = (scrollButtonXOffset / endPoint)
		return clamp, scrollButtonXOffset, percentage
	end
	return clamp, scrollButtonXOffset, 0
end

function GUIScroll:getScrollHeightAndOffset()
	local areaX, areaY, areaW, areaH = self:getInnerArea()
	local height = self.height
	local ratio = height * (height/areaH)
	local clamp = math.min(height, (math.max(ratio, 0)))
	local endPoint = height-clamp
	local scrollButtonYOffset = math.min(math.max(self.offset * areaH, 0), endPoint)
	if scrollButtonYOffset ~= 0 then
		local percentage = (scrollButtonYOffset / endPoint)
		return clamp, scrollButtonYOffset, percentage
	end
	return clamp, scrollButtonYOffset, 0
end

function GUIScroll:getTransform()
	local transform = GUIElement.getTransform(self)
	local areaX, areaY, areaW, areaH = self:getInnerArea()
	local height = self.height
	local _h, _y, percentage = self:getScrollHeightAndOffset()
	local ratio = areaH * (areaH/height)
	local clamp = math.min(height, (math.max(ratio, 0)))
	local areaPoint = (areaH-clamp)
	local offset = math.lerp(0,areaPoint,percentage)
	transform:translate(0, (-offset))
	return transform
end

function GUIScroll:getGUISelectControl()
	local state = 
		love.mouse.isDown(1) or
		love.keyboard.isDown("kpenter") or
		love.keyboard.isDown("return")
	return state
end

function GUIScroll:update(dt)
	GUIElement.update(self, dt)
	if self.enabled then
		local _, _, areaW, areaH = self:getInnerArea()
		local camera = self.system.parent.level.camera
		local mouseX, mouseY = camera:mousePosition()
		local transform = self.parent:getTransform()
		local rmouseX, rmouseY = transform:inverseTransformPoint(mouseX, mouseY)
		local width = self.width
		local height = self.height
		local buttonSize = 16
		local transform = self.parent:getTransform()

		--Horizontal button hit check
		local scrollButtonWidth, scrollButtonXOffset = self:getScrollWidthAndOffset()
		local topLeftX = scrollButtonXOffset
		local topLeftY = height - buttonSize
		local centerX = topLeftX + (scrollButtonWidth/2)
		local centerY = topLeftY + (buttonSize/2)
		local cx, cy = transform:transformPoint(centerX, centerY)
		local shape = love.physics.newRectangleShape(cx, cy, scrollButtonWidth, buttonSize, camera.r)
		self.horizontalScrollHover = shape:testPoint(0, 0, 0, mouseX, mouseY)

		--Verticle button hit check
		local scrollButtonHeight, scrollButtonYOffset = self:getScrollHeightAndOffset()
		local topLeftX = width - buttonSize
		local topLeftY = scrollButtonYOffset
		local centerX = topLeftX + (buttonSize/2)
		local centerY = topLeftY + (scrollButtonHeight/2)
		local cx, cy = transform:transformPoint(centerX, centerY)
		local shape = love.physics.newRectangleShape(cx, cy, buttonSize, scrollButtonHeight, camera.r)
		self.verticleScrollHover = shape:testPoint(0, 0, 0, mouseX, mouseY)
	
		local lastSelect = self.lastSelect
		self.lastSelect = self:getGUISelectControl()
		
		if self.verticleScrollHover and not lastSelect and self.lastSelect then
			self.buttonOffset = topLeftY - rmouseY
		elseif lastSelect and not self.lastSelect then
			self.buttonOffset = nil
		end
		if self.buttonOffset ~= nil then
			self.offset = math.min(math.max(0, self.buttonOffset + rmouseY),areaH-scrollButtonHeight)/areaH
		end
	end
end

function GUIScroll:getClipping()
	local scrollButtonHeight, scrollButtonYOffset = self:getScrollHeightAndOffset()
	local lx, ly, bx, by = GUIElement.getClipping(self, 0, -scrollButtonYOffset, 0, scrollButtonYOffset)
	return lx, ly, bx, by
end

function GUIScroll:draw()
	if self.show then
		local camera = self.system.parent.level.camera
		local transform = GUIElement.getTransform(self)
		local width = math.max(0, self.width)
		local height = math.max(0, self.height)
		local opacity = self.opacity
		local areaX, areaY, areaW, areaH = self:getInnerArea()

		love.graphics.replaceTransform(camera:getTransform() * transform)

		local buttonSize = 16
		local scrollButtonHeight, scrollButtonYOffset = self:getScrollHeightAndOffset()
		local scrollButtonWidth, scrollButtonXOffset = 
		self:getScrollWidthAndOffset()
		local verticleButtonColor = Colors.orange
		local horizontalButtonColor = Colors.orange
		local barColor = Colors.white

		if self.verticleScrollHover and areaH > height then
			if self.lastSelect then
				verticleButtonColor = Colors.pansy
			else
				verticleButtonColor = Colors.red
			end
		else
			verticleButtonColor = Colors.pansy
		end

		if self.horizontalScrollHover and areaW > width then
			if self.lastSelect then
				horizontalButtonColor = Colors.pansy
			else
				horizontalButtonColor = Colors.red
			end
		else
			horizontalButtonColor = Colors.pansy
		end

		local backgroundWidth = width
		local backgroundHeight = height
		if height < areaH then
			backgroundWidth = width-buttonSize
		end
		if width < areaW then
			backgroundHeight = height-buttonSize
		end

		--background
		love.graphics.setColor(Colors.brown[1], Colors.brown[2], Colors.brown[3], opacity)
		love.graphics.rectangle('fill', 0, 0, backgroundWidth, backgroundHeight)

		if width < areaW then
			-- Horizontal White bar
			love.graphics.setColor(barColor[1], barColor[2], barColor[3], opacity)
			love.graphics.rectangle("fill", 
				0, height-buttonSize, 
				scrollButtonXOffset, buttonSize)
			love.graphics.rectangle("fill", 
				scrollButtonXOffset+scrollButtonWidth, height-buttonSize, 
				width-scrollButtonWidth-scrollButtonXOffset, buttonSize)

			-- Horizontal Bar
			love.graphics.setColor(horizontalButtonColor[1], horizontalButtonColor[2], horizontalButtonColor[3], opacity)
			love.graphics.rectangle("fill", scrollButtonXOffset, height-buttonSize, scrollButtonWidth, buttonSize)
		end

		if height < areaH then
			-- Verticle White bar
			love.graphics.setColor(barColor[1], barColor[2], barColor[3], opacity)
			love.graphics.rectangle("fill", width - buttonSize, 0, buttonSize, scrollButtonYOffset)
			love.graphics.rectangle("fill", width - buttonSize, scrollButtonYOffset+scrollButtonHeight, buttonSize, height - scrollButtonHeight-scrollButtonYOffset)

			-- Verticle Bar
			love.graphics.setColor(verticleButtonColor[1], verticleButtonColor[2], verticleButtonColor[3], opacity)
			love.graphics.rectangle("fill", width - buttonSize, scrollButtonYOffset, buttonSize, scrollButtonHeight)
		end

		GUIElement.draw(self)

	end
end


return GUIScroll