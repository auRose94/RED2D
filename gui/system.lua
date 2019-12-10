local ComponentClass = require "component"
local GUISystem = inheritsFrom(ComponentClass)

local testScaling = false

function GUISystem:init(parent)
	ComponentClass.init(self, parent)
	self.elements = {}
	self.enabled = true
	self.show = true
	local camera = parent.level.camera
	camera:newLayer(3, function ()
		if self and self.drawElements then
			self:drawElements()
		end
	end)
end

function GUISystem:getName()
	return "GUISystem"
end

function GUISystem:update(dt)
	if self.enabled then
		for i = 1, #self.elements do
			local element = self.elements[i]
			if element.update then
				element:update(dt)
			end
		end
	end
end

function GUISystem:getTransform()
	local parent = self.parent
	local camera = self.parent.level.camera
	assert(parent, "No parent")
	if testScaling then
		local height = love.graphics.getPixelHeight()
		local scaleY = height / ((16 / 9) * 600)
		local transform = love.math.newTransform(parent.x, parent.y, camera.r, scaleY)
		return transform
	end
	return love.math.newTransform(parent.x, parent.y, camera.r)
end

function GUISystem:drawElements()
	if self.show and #self.elements > 0 then
		local camera = self.parent.level.camera
		local transform = self:getTransform()
		love.graphics.push()
		love.graphics.replaceTransform(camera:getTransform() * transform)
		for i = 1, #self.elements do
			local element = self.elements[i]
			if element and element.show and element.draw then
				element:draw()
			end
		end
		love.graphics.pop()
	end
end

return GUISystem