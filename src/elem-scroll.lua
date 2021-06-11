local Element = require ".src.element"
local ScrollClass = inheritsFrom(Element)

function ScrollClass:init(...)
    Element.init(self, ...)
end

function ScrollClass:addElement(elem)
    local size = #self.elements
    if size > 0 then
        local last = self.elements[size]
        elem.y = last.y + last.height
    end
    Element.addElement(self, elem)
end

function ScrollClass:draw()
    if not self.hide then
        local x1, y1 = love.graphics.transformPoint(self.x, self.y)
        local x2, y2 = love.graphics.transformPoint(self.x + self.width, self.y + self.height)
        local width, height = x2 - x1, y2 - y1
        local sw, sh = love.graphics.getDimensions()

        local last = nil
        local y = 0
        for _, item in pairs(self.elements) do
            item:setPosition(0, y)
            love.graphics.push()
            love.graphics.applyTransform(item:getTransform())
            item:draw()
            love.graphics.pop()
            local height = item.height
            if item.maxHeight < height then
                height = item.maxHeight
            end
            y = y + height
        end

        love.graphics.setScissor(0, 0, sw, sh)
        love.graphics.intersectScissor(x1, y1, math.abs(width), math.abs(height))
        love.graphics.translate(self.x, self.y)
        love.graphics.setScissor()
    end
end

return ScrollClass
