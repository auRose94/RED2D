local Element = require "gui.element"
local Scroll = inheritsFrom(Element)

function Scroll:init(...)
    Element.init(self, ...)
    self.scrollY = 0
    self.scrollBarWidth = self.scrollBarWidth or 8
    self.scrollBarHeight = self.scrollBarHeight or 32
end

function Scroll:addElement(elem)
    local size = #self.elements
    if size >= 1 then
        local last = self.elements[size]
        elem.y = last.y + last.height
    end
    local width = elem.width - (self.scrollBarWidth or 8)
    elem.width = width
    Element.addElement(self, elem)
end

function Scroll:clearElements()
    self.elements = {}
    self.scrollY = 0
end

function Scroll:draw()
    if not self.hide then
        local mx, my = love.mouse.getPosition()
        local wmx, wmy = love.graphics.inverseTransformPoint(mx, my)
        local mdown = love.mouse.isDown(1)

        local bgColor = colors.darkPink
        local _, innerHeight = self:getInnerSize()
        local rel = self.height / innerHeight
        self.scrollBarHeight = rel * self.height
        local x = self.x + self.width - self.scrollBarWidth
        local y = self.y + self.scrollY
        if self:mouseInsideRect(x, y, self.scrollBarWidth, self.scrollBarHeight) then
            if mdown then
                bgColor = colors.magenta
                if not self.lastDown then
                    self.offy = self.scrollY - wmy
                    if type(self.callback) == "function" then
                        self:callback()
                    end
                end
            else
                if self.lastDown then
                    self.offy = 0
                end
                bgColor = colors.red
            end
            self.lastDown = mdown
        end
        if mdown and self.lastDown and self.offy ~= 0 then
            local max = (innerHeight - self.height) * rel
            self.scrollY = math.min(math.max((self.offy + wmy), 0), max)
            y = self.y + self.scrollY
        end

        local x1, y1 = love.graphics.transformPoint(self.x, self.y)
        local x2, y2 = love.graphics.transformPoint(self.x + self.width, self.y + self.height)
        local width, height = math.abs(x2 - x1), math.abs(y2 - y1)
        self.transform =
            love.math.newTransform(self.x, self.y, self.r, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)

        love.graphics.setScissor(x1, y1, width, height)
        love.graphics.push()

        for _, elem in ipairs(self.elements) do
            if elem and not elem.hide and type(elem.draw) == "function" then
                love.graphics.applyTransform(self.transform)
                love.graphics.push()
                love.graphics.translate(0, -self.scrollY)
                elem:draw()
                love.graphics.pop()
            end
        end
        love.graphics.pop()

        love.graphics.setColor(bgColor)
        love.graphics.rectangle("fill", x, y, self.scrollBarWidth, self.scrollBarHeight)

        love.graphics.setScissor()
    end
end

return Scroll
