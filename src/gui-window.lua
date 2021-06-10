local ComponentClass = require ".src.component"
local WindowClass = inheritsFrom(ComponentClass)

function WindowClass:getName()
	return "WindowClass"
end

function WindowClass:init(parent, data)
	ComponentClass.init(self, parent, data)
    parent.drawOrder = 10
    self.width = 250
    self.height = 150
    self.x = -295
    self.y = -100
    self.elements = {}
end

function WindowClass:addElement(element)
    table.insert(self.elements, element)
end

function WindowClass:removeElement(entity)
	for i = 1, #self.elements do
		if self.elements[i] == entity then
			table.remove(self.elements, i)
			break
		end
	end
end

function WindowClass:handleUI()
    local mx, my = love.mouse.getPosition( )
    local wmx, wmy = love.graphics.inverseTransformPoint(mx, my)
    local mdown = love.mouse.isDown(1)
    if mdown and not self.lastDown then
        self.ox = self.x - wmx
        self.oy = self.y - wmy
    end 
    if mdown and self.lastDown then
        self.x = self.ox + wmx
        self.y = self.oy + wmy
    end
    self.lastDown = mdown
    love.graphics.translate(self.x, self.y+8)
    for _, element in pairs(self.elements) do
        if element and type(element.draw) == "function" then
            love.graphics.push()
            element:draw()
            love.graphics.pop()
        end
    end
end

function WindowClass:draw()
    local width, height = self.width, self.height
    local x, y = self.x, self.y
    if self.show then
        love.graphics.setColor(colors.red)
        love.graphics.rectangle("fill", x, y, width, height)
        love.graphics.setColor(colors.white)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", x, y, width, height)
        self:handleUI()
    end
end

return WindowClass