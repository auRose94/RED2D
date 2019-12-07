local GUISystem = require ".gui.system"
local GUIElement = inheritsFrom(nil)

function GUIElement:init(parent)
	assert(parent)
	table.insert(parent.elements, self)
	
	if parent:isa(GUIElement) then
		self.parent = parent
		self.system = parent.system
	elseif parent:isa(GUISystem) then
		self.parent = parent
		self.system = parent
	end
	assert(self.system)
	assert(self.parent)
	
	self.elements = {}
	self.enabled = false
	self.show = false
	self.x = 0
	self.y = 0
	self.r = 0
	self.width = 0
	self.height = 0
	self.opacity = 0.7
end

function GUIElement:getTransform()
	local transform = self.parent:getTransform()
	transform:rotate(self.r)
	transform:translate(self.x, self.y)
	return transform
end

function GUIElement:update(dt)
	if self and self.enabled then
		if self.onUpdate then
			self:onUpdate(dt)
		end
		for i = 1, #self.elements do
			local element = self.elements[i]
			if element.enabled and element.update then
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
	local x = self.x
	local y = self.y
	local width = self.width
	local height = self.height
	local transform = self:getTransform()
	local camera = self.system.parent.level.camera
	local cameraTransform = camera:getTransform()
	local lct = cameraTransform * transform
	local lx, ly = lct:transformPoint(x+ox, y+oy)
	local bx, by = lct:transformPoint(x+width+sx, y+height+sy)
	return lx, ly, bx - lx, by - ly
end

function GUIElement:getGUISelectControl()
	local state = 
		love.mouse.isDown(1)
	return state
end

function GUIElement:getGUISecondaryControl()
	local state = 
		love.mouse.isDown(2)
	return state
end

function GUIElement:getInnerArea()
	local cl, ct, cr, cb = 0, 0, 0, 0
	if #self.elements > 0 then
		for i = 1, #self.elements do
			local element = self.elements[i]
			if element and element.enabled and element.show and element.draw then
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
	if self and self.enabled and self.show then
		local transform = self:getTransform()
		local camera = self.system.parent.level.camera
		local lx, ly, bx, by = self:getClipping()
		local lcx, lcy, lcw, lch = love.graphics.getScissor()
		if #self.elements > 0 then
			
			love.graphics.push()
			for i = 1, #self.elements do
				local element = self.elements[i]
				if element and element.enabled and element.show and element.draw then
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

return GUIElement