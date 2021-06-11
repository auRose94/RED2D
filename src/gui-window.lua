local ComponentClass = require ".src.component"
local guiStyle = require ".src.gui-style"
local WindowClass = inheritsFrom(ComponentClass)

local windowFont = love.graphics.newFont(guiStyle.fontPath, 9, guiStyle.fontType)

function WindowClass:getName()
    return "WindowClass"
end

function WindowClass:init(parent, ...)
    ComponentClass.init(self, parent, ...)
    parent.drawOrder = 10
    self.title = "New Window"
    self.lineWidth = 0.25
    self.textSize = self.textSize or 16
    self.fontScale = self.fontScale or 0.5
    self.elements = {}
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
    local mx, my = love.mouse.getPosition()
    local width, height = self.width, self.height
    local titleObj = self.titleObj
    local tW, tH = titleObj:getDimensions()
    if tW > width then
        width = tW
    end
    if tH > height then
        height = tH
    end

    local v = {}
    v[1] = {love.graphics.transformPoint(self.x, self.y)}
    v[2] = {love.graphics.transformPoint(self.x + width, self.y)}
    v[3] = {love.graphics.transformPoint(self.x + width, self.y + height)}
    v[4] = {love.graphics.transformPoint(self.x, self.y + height)}

    return polyPoint(v, mx, my)
end

function WindowClass:handleUI()
    local mx, my = love.mouse.getPosition()
    local wmx, wmy = love.graphics.inverseTransformPoint(mx, my)
    local mdown = love.mouse.isDown(1)
    if self:mouseInside() then
        if mdown and not self.lastDown then
            self.ox = self.x - wmx
            self.oy = self.y - wmy
        end
        if mdown and self.lastDown then
            self.x = self.ox + wmx
            self.y = self.oy + wmy
        end
    end
    self.lastDown = mdown
    love.graphics.translate(self.x, self.y + 8)
    for _, element in pairs(self.elements) do
        if element and type(element.draw) == "function" then
            love.graphics.push()
            element:draw()
            love.graphics.pop()
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
