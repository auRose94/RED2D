local GUISystem = require ".gui.system"
local input = require "input"
local GUIElement = inheritsFrom(nil)

function GUIElement:init(...)
	local data = nil
	self.elements = {}
	local count = select("#", ...)
	for argI=1, count do
		local argV = select(argI, ...)
		if type(argV) == "table" then
			if type(argV.isa) == "function" then
				if argV:isa(GUISystem) then
					-- GUISystem (as parent)
					argV:addElement(self)
				elseif argV:isa(GUIElement) then
					if argV.system then
						-- GUIElement (as parent)
						argV:append(self)
					else
						-- GUIElement (as element)
						self:append(argV)
					end
				end
			else
				data = argV -- data table
			end
		end
	end
	self.data = data or {}
	self.newData = clone(data)

	self.enabled = self:getArgument("enabled", false)
	self.hide = self:getArgument("hide", true)
	self.x = self:getArgument("x", 0)
	self.y = self:getArgument("y", 0)
	self.r = self:getArgument("r", 0)
	self.width = self:getArgument("width", 0)
	self.height = self:getArgument("height", 0)
	self.opacity = self:getArgument("opacity", 0.7)

	local onUpdateFunc = self:getArgument("onUpdateFunc", nil)
	if onUpdateFunc then
		self:onUpdate(onUpdateFunc)
	end
end

function GUIElement:append(...)
	for i = 1, select("#", ...) do
		local element = select(i, ...)
		if type(element) == "table" and
			type(element.isa) == "function" and
			element:isa(GUIElement) then
			element.parent = self
			element.system = self.system
			table.insert(self.elements, element)
		end
	end
	return ...
end

function GUIElement:getArgument(name, default)
	local value = self.data[name]
	if value ~= nil then
		self.newData[name] = nil
		return value
	end
	if default ~= nil then
		return default
	end
	return nil
end

function GUIElement:removeFromState(...)
	local returns = {}
	local count = select("#", ...)
	for i=1, count do
		local name = select(i, ...)
		returns[i] = self.data[name]
		self.newData[name] = nil
	end
	return unpack(returns)
end

function GUIElement:assignData(data)
	-- Much like a state machine, each element has a state
	for name, value in pairs(data) do
		self.newData[name] = value
	end
end

function GUIElement:isActive()
	return GUIElement.currentlyActive == self
end

function GUIElement:makeActive()
	GUIElement.currentlyActive = self
end

function GUIElement:getTransform()
	-- This applies to the root element... children use separate one.
	local transform = self.parent:getTransform()
	transform:rotate(self.r)
	transform:translate(self.x, self.y)
	return transform
end

function GUIElement:getChildTransform()
	-- Other classes get to overide me.
	return self:getTransform()
end

function GUIElement:update(dt)
	self.data = self.newData
	self.newData = clone(self.data)
	
	if self and self.enabled and self.system then
		if self.onUpdate then
			self:onUpdate(dt)
		end
		for i = 1, #self.elements do
			local element = self.elements[i]
			if element.system ~= self.system then
				element.system = self.system
			end
			if (element.enabled or element:isActive()) and element.update then
				element:update(dt)
			end
		end
	end
end

function GUIElement:getClipping(ox, oy, sx, sy)
	ox = ox or 0
	oy = oy or 0
	sx = sx or 0
	sy = sy or 0
	local x = self.x or 0
	local y = self.y or 0
	local width = self.width or 0
	local height = self.height or 0
	local transform = self:getChildTransform()
	local camera = self.system.parent.level.camera
	local cameraTransform = camera:getTransform()
	local lct = cameraTransform * transform
	local lx, ly = lct:transformPoint(x+ox, y+oy)
	local bx, by = lct:transformPoint(x+width+sx, y+height+sy)
	return lx, ly, bx - lx, by - ly
end

function GUIElement:getGUISelectControl()
	local system = self.system
	if system.guiPrimary then
		return system.guiPrimary
	end
	PlayerComponent = PlayerComponent or require "comp-player"
	local player = system.player or system:getComponent(PlayerComponent)
	system.guiPrimary = player.guiPrimary or
		input.getInput(player.playerIndex, "GUI Left Click")
	return system.guiPrimary
end

function GUIElement:getGUISecondaryControl()
	local system = self.system
	if system.guiSecondary then
		return system.guiSecondary
	end
	PlayerComponent = PlayerComponent or require "comp-player"
	local player = system.player or system:getComponent(PlayerComponent)
	system.guiSecondary = player.guiSecondary or
		input.getInput(player.playerIndex, "GUI Right Click")
	return system.guiSecondary
end

function GUIElement:getInnerArea()
	local cl, ct, cr, cb = 0, 0, 0, 0
	if #self.elements > 0 then
		for i = 1, #self.elements do
			local element = self.elements[i]
			if element and element.enabled and not element.hide and element.draw then
				local el, et, er, eb = element:getInnerArea()
				cl = math.min(cl, el, element.x)
				ct = math.min(ct, et, element.y)
				cr = math.max(cr, el + er, element.x + element.width)
				cb = math.max(cb, et + eb, element.y + element.height)
			end
		end
	end
	return cl, ct, cr - cl, cb - ct
end

function GUIElement:draw()
	if self and not self.hide then
		local transform = self:getChildTransform()
		local camera = self.system.parent.level.camera
		local lx, ly, bx, by = self:getClipping()
		local lcx, lcy, lcw, lch = love.graphics.getScissor()
		if #self.elements > 0 then
			
			love.graphics.push()
			for _, element in ipairs(self.elements) do
				if element and not element.hide and element.draw then
					if not lcx and not lcy and not lcw and not lch then
						love.graphics.setScissor(lx, ly, bx, by)
					else
						love.graphics.intersectScissor(lcx, lcy, lcw, lch)
					end
					love.graphics.replaceTransform(camera:getTransform()*transform)
					element:draw()
				end
			end
			love.graphics.pop()
			love.graphics.setScissor(lcx, lcy, lcw, lch)
		end
	end
end

function GUIElement:onUpdate(func)
	if self.onUpdateFunc and func then
		local last = self.onUpdateFunc
		self.onUpdateFunc = function (element, dt)
			last(element, dt)
			func(element, dt)
		end
	else
		self.onUpdateFunc = func
	end
end

_G.GUIElement = GUIElement

return GUIElement