local EntityClass = inheritsFrom(nil)

function EntityClass:init(level, name, x, y, z, r, sx, sy, ox, oy, kx, ky)
	assert(level, "No level given")
	level:addEntity(self)
	self.x = x
	self.y = y
	self.r = r or 0
	self.sx = sx or 1
	self.sy = sy or self.sx
	self.ox = ox or 0
	self.oy = oy or 0
	self.kx = kx or 0
	self.ky = ky or 0
	self.touched = false
	self.components = {}
	self.children = {}
	self.transform = love.math.newTransform()
	self.name = name or "New Entity"
end

function EntityClass:getName()
	return "EntityClass"
end

function EntityClass:callComponentMethods(name, ...)
	if name == nil or name == "" then
		return
	end
	for _, c in pairs(self.components) do
		if type(c) == "table" then
			local method = c[name] or nil
			if type(method) == "function" then
				method(c, ...)
			end
		end
	end
end

function EntityClass:update(dt)
	self:callComponentMethods("update", dt)
end

function EntityClass:draw()
	love.graphics.applyTransform(self:getTransform())
	for _, c in pairs(self.components) do
		if type(c) == "table" and c.draw then
			love.graphics.push()
			c:draw()
			love.graphics.pop()
		end
	end
end

function EntityClass:destroy()
	self:callComponentMethods("destroy")
	for _, c in pairs(self.components) do
		if type(c) == "table" then
			c.parent = nil
		end
	end
	self.components = {}
	self.transform = nil
	local level = self.level
	if level then
		level:removeEntity(self)
	end
end

function EntityClass:setPosition(...)
	local x, y = ...
	if type(x) == "table" then
		x, y = unpack(...)
	end
	self.touched = true
	self.x = x
	self.y = y
end

function EntityClass:getUp()
	local transform = self:getTransform()
	return self:transformNormal(0, 1)
end

function EntityClass:getRight()
	local transform = self:getTransform()
	return self:transformNormal(1, 0)
end

function EntityClass:getWorldPosition()
	local transform = self:getTransform()
	return transform:transformPoint(0, 0)
end

function EntityClass:getPosition()
	return self.x, self.y
end

function EntityClass:setRotation(r)
	self.touched = true
	self.r = r
end

function EntityClass:getRotation()
	return self.r
end

function EntityClass:setScale(...)
	local x, y = ...
	if type(x) == "table" then
		x, y = unpack(...)
	end
	self.sx = x
	self.sy = y
	self.touched = true
end

function EntityClass:getScale()
	return self.sx, self.sy
end

function EntityClass:setSkew(...)
	local x, y = ...
	if type(x) == "table" then
		x, y = unpack(...)
	end
	self.kx = x
	self.ky = y
	self.touched = true
end

function EntityClass:getScew()
	return self.kx, self.ky
end

function EntityClass:setOrigin(...)
	local x, y = ...
	if type(x) == "table" then
		x, y = unpack(...)
	end
	self.ox = x
	self.oy = y
	self.touched = true
end

function EntityClass:getOrigin()
	return self.ox, self.oy
end

function EntityClass:getTransform()
	if self.touched or not self.transform then
		self.transform = love.math.newTransform(self.x, self.y, self.r, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
		self.touched = false
	end
	if self.parent then
		return self.parent:getTransform() * self.transform
	end
	return self.transform
end

function EntityClass:getComponent(typeOrObject)
	assert(type(self.components) == "table", "Components is not a table")
	for index, v in pairs(self.components) do
		if typeOrObject == v or v:isa(typeOrObject) then
			return v
		end
	end
	return nil
end

function EntityClass:getComponents(typeClass)
	assert(type(self.components) == "table", "Components is not a table")
	local comps = {}
	for index, v in pairs(self.components) do
		if v:isa(typeClass) then
			table.insert(comps, v)
		end
	end
	for childIndex, child in pairs(self.children) do
		local childComps = child:getComponents(typeClass)
		for index, v in pairs(childComps) do
			table.insert(comps, v)
		end
	end
	return comps
end

function EntityClass:addComponent(comp)
	assert(type(self.components) == "table", "Components is not a table")
	table.insert(self.components, comp)
	comp.parent = self
end

function EntityClass:removeComponent(compOrTypeOrIndex)
	local found = false
	local value = nil
	if type(compOrTypeOrIndex) == "number" then
		value = self.components[compOrTypeOrIndex]
		found = compOrTypeOrIndex
	elseif type(compOrTypeOrIndex) == "table" then
		for index, v in ipairs(self.components) do
			if compOrTypeOrIndex == v or v:isa(compOrTypeOrIndex) then
				value = v
				found = index
				break
			end
		end
	end
	if found then
		value:destroy()
		value.parent = nil
		table.remove(self.components, found)
		return value
	end
end

function EntityClass:findChild(name)
	local value = nil
	local found = nil
	for index, child in ipairs(self.children) do
		if child.name == name then
			value = child
			found = index
			break
		end
	end
	return value, found
end

function EntityClass:removeChild(child)
	local found = false
	local value = nil
	for index, child in ipairs(self.children) do
		if child == child then
			value = child
			found = index
			break
		end
	end
	if found then
		value:destroy()
		value.parent = nil
		table.remove(self.children, found)
		return value
	end
end

function EntityClass:setParent(parent)
	if parent then
		self.parent = parent
		table.insert(parent.children, self)
	else
		self.parent:removeChild(self)
		self.parent = nil
	end
end

function EntityClass:transformPoint(...)
	local x, y = ...
	if type(x) == "table" then
		x, y = unpack(...)
	end
	local transform = self:getTransform()
	return transform:transformPoint(x, y)
end

function EntityClass:inverseTransformPoint(...)
	local x, y = ...
	if type(x) == "table" then
		x, y = unpack(...)
	end
	local transform = self:getTransform()
	return transform:inverseTransformPoint(x, y)
end

function EntityClass:transformNormal(...)
	local x, y = ...
	if type(x) == "table" then
		x, y = unpack(...)
	end
	x, y = math.normalize(x, y)
	local transform = self:getTransform()
	local wx, wy = transform:transformPoint(0, 0)
	x, y = transform:transformPoint(x, y)
	return math.normalize(wx - x, wy - y)
end

function EntityClass:inverseTransformNormal(...)
	local x, y = ...
	if type(x) == "table" then
		x, y = unpack(...)
	end
	x, y = math.normalize(x, y)
	local transform = self:getTransform()
	local wx, wy = transform:inverseTransformPoint(0, 0)
	x, y = transform:inverseTransformPoint(x, y)
	return math.normalize(wx - x, wy - y)
end

_G.EntityClass = EntityClass

return EntityClass