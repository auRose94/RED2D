local Element = require ".src.element"
local ScrollClass = inheritsFrom(Element)

function ScrollClass:init(...)
    Element.init(self, ...)
    self.scrollY = 0
    self.scrollBarWidth = self.scrollBarWidth or 8
    self.scrollBarHeight = self.scrollBarHeight or 32
end

function ScrollClass:addElement(elem)
    local size = #self.elements
    if size >= 1 then
        local last = self.elements[size]
        elem.y = last.y + last.height
    end
    local width = elem.width - (self.scrollBarWidth or 8)
    elem.width = width
    elem.maxWidth = width
    Element.addElement(self, elem)
end

function ScrollClass:draw()
    if not self.hide then
        local x1, y1 = love.graphics.transformPoint(self.x, self.y)
        local x2, y2 = love.graphics.transformPoint(self.x + self.width, self.y + self.height)
        local width, height = x2 - x1, y2 - y1
        local sw, sh = love.graphics.getDimensions()
        local mdown = love.mouse.isDown(1)

        love.graphics.setScissor(x1, y1, math.abs(width), math.abs(height))
        -- love.graphics.intersectScissor(x1, y1, math.abs(width), math.abs(height))
        Element.draw(self)
        love.graphics.setScissor()

        local bgColor = colors.darkPink
        local _, height = self:getInnerSize()
        local rel = self.height / height
        self.scrollBarHeight = rel * self.height
        local x = self.width - self.scrollBarWidth
        local y = self.y + self.scrollY
        if self:mouseInsideRect(x, y, self.scrollBarWidth, self.scrollBarHeight) then
            if mdown then
                bgColor = colors.magenta
                if not self.lastDown and type(self.callback) == "function" then
                    self:callback()
                end
            else
                bgColor = colors.red
            end
            self.lastDown = mdown
        end
        love.graphics.setColor(bgColor)

        love.graphics.rectangle("fill", x, y, self.scrollBarWidth, self.scrollBarHeight)
    end
end

return ScrollClass
