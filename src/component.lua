local Entity = require "entity"
-- local imgui = require"imgui"

local Component = inheritsFrom(nil)

function Component:setPosition(...)
    assert(self.parent, "No parent")
    self.parent:setPosition(...)
end

function Component:getPosition()
    assert(self.parent, "No parent")
    return self.parent:getPosition()
end

function Component:setRotation(r)
    assert(self.parent, "No parent")
    self.parent:setRotation(r)
end

function Component:getRotation()
    assert(self.parent, "No parent")
    return self.parent:getRotation()
end

function Component:setScale(...)
    assert(self.parent, "No parent")
    self.parent:setScale(...)
end

function Component:getScale()
    assert(self.parent, "No parent")
    return self.parent:getScale()
end

function Component:setSkew(...)
    assert(self.parent, "No parent")
    self.parent:setSkew(...)
end

function Component:getSkew()
    assert(self.parent, "No parent")
    return self.parent:getSkew()
end

function Component:setOrigin(...)
    assert(self.parent, "No parent")
    self.parent:setOrigin(...)
end

function Component:getOrigin()
    assert(self.parent, "No parent")
    return self.parent:getOrigin()
end

function Component:getTransform()
    assert(self.parent, "No parent")
    return self.parent:getTransform()
end

function Component:findChild(name)
    assert(self.parent, "No parent")
    return self.parent:findChild(name)
end

function Component:getComponent(name)
    assert(self.parent, "No parent")
    return self.parent:getComponent(name)
end

function Component:addComponent(comp)
    assert(self.parent, "No parent")
    self.parent:addComponent(comp)
end

function Component:removeComponent(comp)
    assert(self.parent, "No parent")
    self.parent:removeComponent(comp)
end

function Component:transformPoint(...)
    assert(self.parent, "No parent")
    return self.parent:transformPoint(...)
end

function Component:inverseTransformPoint(...)
    assert(self.parent, "No parent")
    return self.parent:inverseTransformPoint(...)
end

function Component:transformNormal(...)
    assert(self.parent, "No parent")
    return self.parent:transformNormal(...)
end

function Component:inverseTransformNormal(...)
    assert(self.parent, "No parent")
    return self.parent:inverseTransformNormal(...)
end

--[[
	
function Component:drawEditor()
	local keys = sortedKeys(self)
	for index, name in pairs(keys) do
		local value = self[name]
		local t = type(value)
		if type(name) == "string" then
			if t == "number" then
				self[name] = imgui.DragFloat(name, value)
			elseif t == "string" then
				local changed, newValue = imgui.InputText(name, value, #value + 1)
				self[name] = changed and newValue or value
			elseif t == "boolean" then
				self[name] = imgui.Checkbox(name, value)
			end
		end
	end
end\
]]
function Component:getName()
    return "Component"
end

function Component:init(parent, ...)
    assert(self ~= nil)
    assert(parent ~= nil, "No parent")
    assert(Entity, "Entity is not a global")
    assert(isa(parent, Entity), "parent is not an Entity")
    self.parent = parent
    self.children = {}
    parent:addComponent(self)
    for i = 1, select("#", ...) do
        local value = select(i, ...)
        local tValue = type(value)
        if tValue == "table" then
            for k, v in pairs(value) do
                self[k] = v
            end
        elseif tValue == "string" then
            self.text = value
        end
    end
end

return Component
