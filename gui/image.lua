local GUIElement = require ".gui.element"
local GUIImage = inheritsFrom(GUIElement)

function GUIImage:init(...)
	GUIElement.init(self, ...)
	local flags = self:getArgument("flags", "")
	local path = self:getArgument("path", "")
	self.hide = self:getArgument("show", false)
	self.enabled = self:getArgument("enabled", true)
	if type(path) == "string" then
		self.path = path
		self.srcTexture = love.graphics.newImage(path, flags or {
			["linear"] = true,
			["mipmaps"] = true
		})
		self.srcTexture:setFilter("linear", "nearest", 0)
	elseif type(path) == "userdata" then
		self.srcTexture = path
	end
	assert(self.srcTexture, "No texture passed")

	self.srcWidth = self.srcTexture:getWidth()
	self.srcHeight = self.srcTexture:getHeight()
	self.srcX = 0
	self.srcY = 0

	self.srcRect = { self.srcX, self.srcY, self.srcWidth, self.srcHeight }
	self.srcQuad = love.graphics.newQuad(self.srcX, self.srcY, self.srcWidth, self.srcHeight, self.srcTexture:getWidth(), self.srcTexture:getHeight())

	self.r = self:getArgument("r", 0)

	self.imageHighlightColor = self:getArgument("imageHighlightColor", Colors.lightBlue)
	self.imagePressColor = self:getArgument("imagePressColor", Colors.black)
	self.imageColor = self:getArgument("imageColor", Colors.white)

	self.backgroundHighlightColor = self:getArgument("backgroundHighlightColor", Colors.gray)
	self.backgroundPressColor = self:getArgument("backgroundPressColor", Colors.white)
	self.backgroundColor = self:getArgument("backgroundColor", Colors.white)
	self.background = self:getArgument("background", 0)
end

function GUIImage:setRect(rectOrX, y, w, h)
	assert(self.srcTexture)
	if type(rectOrX) == "userdata" then
		self.srcRect = nil
		self.srcQuad = rectOrX
	else
		if type(rectOrX) == "number" then
			self.srcX = rectOrX
			self.srcY = y
			self.srcWidth = w
			self.srcHeight = h
		elseif type(rectOrX) == "table" and #type(rectOrX) >= 4 then
			self.srcX = rectOrX[1]
			self.srcY = rectOrX[2]
			self.srcWidth = rectOrX[3]
			self.srcHeight = rectOrX[4]
		end
		self.srcRect = { self.srcX, self.srcY, self.srcWidth, self.srcHeight }
		self.srcQuad = love.graphics.newQuad(self.srcX, self.srcY, self.srcWidth, self.srcHeight, self.srcTexture:getWidth(), self.srcTexture:getHeight())
	end
end

function GUIImage:getGUISelectControl()
	local state =
		love.mouse.isDown(1) or
		love.keyboard.isDown("kpenter") or
		love.keyboard.isDown("return")
	return state
end

function GUIImage:getQuad()
	if	(type(self.srcRect) == "table" and
			self.srcTexture ~= nil) and
			(self.srcRect[1] ~= self.srcX or
			self.srcRect[2] ~= self.srcY or
			self.srcRect[3] ~= self.srcWidth or
			self.srcRect[4] ~= self.srcHeight) then
		self.srcRect = { self.srcX, self.srcY, self.srcWidth, self.srcHeight }
		self.srcQuad = love.graphics.newQuad(self.srcX, self.srcY, self.srcWidth, self.srcHeight, self.srcTexture:getWidth(), self.srcTexture:getHeight())
	end
	return self.srcQuad
end

function GUIImage:update(dt)
	GUIElement.update(self, dt)
	if self.onClickFunc and self.enabled then
		local camera = self.system.parent.level.camera
		local mouseX, mouseY = camera:mousePosition()
		local width = math.max(0, self.sx * self.width)
		local height = math.max(0, self.sy * self.height)
		local centerX = self.x + ((width)/2)
		local centerY = self.y + ((height)/2)
		local transform = self.parent:getTransform()
		local cx, cy = transform:transformPoint(centerX, centerY)
		local shape = love.physics.newRectangleShape(cx, cy, width, height, camera.r)
		self.hover = shape:testPoint(0, 0, 0, mouseX, mouseY)

		local click = self:getGUISelectControl()
		
		if self.hover and click:pressed() then
			self.onClickFunc()
		end
	end
end

function GUIImage:draw()
	if not self.hide then
		local opacity = self.opacity
		local imageColor = self.imageColor
		local backgroundColor = self.backgroundColor
		local rot = self.r
		local transform = self:getTransform()
		local camera = self.system.parent.level.camera
		local click = self:getGUISelectControl()
	
		love.graphics.replaceTransform(camera:getTransform() * transform)
		
		if self.hover then
			if click:pressed() then
				imageColor = self.imagePressColor
				backgroundColor = self.imagePressColor
			else
				imageColor = self.imageHighlightColor
				backgroundColor = self.backgroundHighlightColor
			end
		end
		love.graphics.setColor(imageColor[1], imageColor[2], imageColor[3], opacity)
		love.graphics.draw(
			self.srcTexture,
			self:getQuad(),
			0, 0,
			rot,
			self.sx,
			self.sy)
	
	end
	GUIElement.draw(self)
end

function GUIImage:onClick(func)
	if func ~= nil and type(self.onClickFunc) == "function" then
		local old = self.onClickFunc
		self.onClickFunc = function()
			old()
			func()
		end
	else
		self.onClickFunc = func
	end
end

return GUIImage