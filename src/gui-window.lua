local ComponentClass = require ".src.component"
local WindowClass = inheritsFrom(ComponentClass)

function WindowClass:getName()
	return "WindowClass"
end

function WindowClass:init(parent, data)
	ComponentClass.init(self, parent, data)
    parent.drawOrder = 10
    self.width = 300
    self.height = 100
    self.x = -275
    self.y = -10
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
end

function WindowClass:draw()
    local width, height = self.width, self.height
    local x, y = self.x, self.y
    self:handleUI()
    if self.show then
        love.graphics.setColor(colors.red)
        love.graphics.rectangle("fill", x, y, width, height)
        love.graphics.setColor(colors.white)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", x, y, width, height)
    end
end

return WindowClass