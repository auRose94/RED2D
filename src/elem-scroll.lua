
local ElementClass = require ".src.element"
local ScrollClass = inheritsFrom(ElementClass)

function ScrollClass:init(...)
    ElementClass.init(self, ...)
end

function ScrollClass:draw()
    local x1, y1 = love.graphics.transformPoint(self.x, self.y)
    local x2, y2 = love.graphics.transformPoint(self.x + self.width, self.y + self.height)
    local width, height = x2 - x1, y2 - y1
    love.graphics.setScissor(x1, y1, width, height)
    ElementClass.draw(self)
    love.graphics.setScissor()
end

return ScrollClass