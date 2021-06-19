local ComponentClass = require "component"
local guiStyle = require "gui-style"
local Element = require "element"
local WindowClass = inheritsFrom(ComponentClass)

local windowFont = love.graphics.newFont(guiStyle.fontPath, 9, guiStyle.fontType)

function WindowClass:getName()
    return "WindowClass"
end

function WindowClass:init(parent, ...)
    ComponentClass.init(self, parent, ...)
    parent.drawOrder = 10
    self.title = self.title or "New Window"
    self.lineWidth = self.lineWidth or 0.25
    self.textSize = self.textSize or 16
    self.fontScale = self.fontScale or 0.5
    self.elements = {}
    self.offx = 0
    self.offy = 0
    self:updateText(self.title)
end

function WindowClass:updateText(text)
    self.title = text
    local font = self.font or windowFont
    local textSize = font:getLineHeight()
    if textSize ~= self.textSize then
        font = love.graphics.newFont(guiStyle.fontPath, self.textSize, guiStyle.fontType)
        self.font = font
    end
    self.titleObj = love.graphics.newText(font, text)
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

function WindowClass:mouseInside()
    local width, height = self.width, self.height
    local titleObj = self.titleObj
    local tW, tH = titleObj:getDimensions()
    if tW > width then
        width = tW
    end
    if tH > height then
        height = tH
    end

    return WindowClass:mouseInsideRect(self.x, self.y, width, height)
end

function WindowClass:mouseInsideRect(rX, rY, rW, rH)
    local v = {}
    v[1] = {love.graphics.transformPoint(rX, rY)}
    v[2] = {love.graphics.transformPoint(rX + rW, rY)}
    v[3] = {love.graphics.transformPoint(rX + rW, rY + rH)}
    v[4] = {love.graphics.transformPoint(rX, rY + rH)}

    return polyPoint(v, love.mouse.getPosition())
end

function WindowClass:handleUI()
    local mx, my = love.mouse.getPosition()
    local wmx, wmy = love.graphics.inverseTransformPoint(mx, my)
    local mdown = love.mouse.isDown(1)
    if self:mouseInsideRect(self.x, self.y, self.width, self.textSize * self.fontScale) then
        if mdown and not self.lastDown then
            self.offx = self.x - wmx
            self.offy = self.y - wmy
        end
    end
    if self.lastDown and not mdown then
        self.offx = 0
        self.offy = 0
    end
    if mdown and self.lastDown and (self.offx ~= 0 or self.offy ~= 0) then
        self.x = self.offx + wmx
        self.y = self.offy + wmy
    end
    self.lastDown = mdown
    love.graphics.translate(self.x, self.y + 8)
    local x1, y1 = love.graphics.transformPoint(self.x, self.y)
    local x2, y2 = love.graphics.transformPoint(self.x + self.width, self.y + self.height)
    local width, height = math.abs(x2 - x1), math.abs(y2 - y1)

    for _, elem in ipairs(self.elements) do
        if elem and not elem.hide and type(elem.draw) == "function" then
            love.graphics.setScissor(x1, y1, width, height)
            love.graphics.push()
            elem:draw()
            love.graphics.pop()
            love.graphics.setScissor()
        end
    end
end

function WindowClass:draw()
    if self.show then
        local width, height = self.width, self.height
        local x, y = self.x, self.y
        local textX, textY = x + 3, y

        love.graphics.setColor(colors.red)
        love.graphics.rectangle("fill", x, y, width, height)
        love.graphics.setColor(colors.white)
        love.graphics.setLineWidth(self.lineWidth)
        love.graphics.rectangle("line", x, y, width, height)
        love.graphics.draw(self.titleObj, textX, textY, 0, self.fontScale, self.fontScale)
        self:handleUI()
    end
end

return WindowClass
