local ComponentClass = require ".src.component"
local WindowClass = inheritsFrom(ComponentClass)

function WindowClass:getName()
	return "WindowClass"
end

function WindowClass:init(parent, data)
	ComponentClass.init(self, parent, data)
    self.width = 1
    self.height = 1
end

function WindowClass:draw()
    local posX, posY = self:getPosition()
    local width, height = self.width, self.height
    if self.show then
        love.graphics.rectangle("fill", posX, posY, width, height)
        love.graphics.rectangle("line", posX, posY, width, height)
    end
end

return WindowClass