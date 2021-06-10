
local ElementClass = inheritsFrom(nil)

function ElementClass:init(...)
    self.elements = {}
    self.x = 0
    self.y = 0
	self.z = 0
	self.r = 0
	self.sx = 1
	self.sy = 1
	self.ox = 0
	self.oy = 0
	self.kx = 0
	self.ky = 0
    self.width = 0
    self.height = 0
	self.transform = love.math.newTransform()
    for i = 1, select('#', ...) do
        local value = select(i, ...)
        local tValue = type(value)
        if tValue == "table" then
            if isa(value, ElementClass) then
                table.insert(self.elements, value)
                value.parent = self
            else
                self = tableMerge(self, value)
            end
        elseif tValue == "string" then
            self.text = value
        end
    end

end

function ElementClass:getName()
	return "ElementClass"
end


function ElementClass:setPosition(...)
	local x, y = ...
	if type(x) == "table" then
		x, y = unpack(...)
	end
	self.x = x
	self.y = y
end

function ElementClass:getUp()
	local transform = self:getTransform()
	return self:transformNormal(0, 1)
end

function ElementClass:getRight()
	local transform = self:getTransform()
	return self:transformNormal(1, 0)
end

function ElementClass:getWorldPosition()
	local transform = self:getTransform()
	return transform:transformPoint(0, 0)
end

function ElementClass:getWorldPoint(x, y)
	local transform = self:getTransform()
	return transform:transformPoint(x, y)
end

function ElementClass:getPosition()
	return self.x, self.y
end

function ElementClass:setRotation(r)
	self.r = r
end

function ElementClass:getRotation()
	return self.r
end

function ElementClass:setScale(...)
	local x, y = ...
	if type(x) == "table" then
		x, y = unpack(...)
	end
	self.sx = x
	self.sy = y
end

function ElementClass:getScale()
	return self.sx, self.sy
end

function ElementClass:setSkew(...)
	local x, y = ...
	if type(x) == "table" then
		x, y = unpack(...)
	end
	self.kx = x
	self.ky = y
end

function ElementClass:getSkew()
	return self.kx, self.ky
end

function ElementClass:setOrigin(...)
	local x, y = ...
	if type(x) == "table" then
		x, y = unpack(...)
	end
	self.ox = x
	self.oy = y
end

function ElementClass:getOrigin()
	return self.ox, self.oy
end

function ElementClass:getTransform()
	self.transform =
		love.math.newTransform(
			self.x,
			self.y,
			self.r,
			self.sx,
			self.sy,
			self.ox,
			self.oy,
			self.kx,
			self.ky
		)
	if self.parent then
		return self.parent:getTransform() * self.transform
	end
	return self.transform
end

return ElementClass