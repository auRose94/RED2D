local Component = require "component"
local guiStyle = require "gui-style"
local Element = require "element"
local Window = inheritsFrom(Component)

local windowFont = love.graphics.newFont(guiStyle.fontPath, 9, guiStyle.fontType)

function Window:getName()
    return "Window"
end

function Window:init(parent, ...)
    Component.init(self, parent, ...)
    parent.drawOrder = 10
    self.title = self.title or "New Window"
    self.lineWidth = self.lineWidth or 0.25
    self.textSize = self.textSize or 16
    self.fontScale = self.fontScale or 0.5
    self.elements = {}
    self.offsetX = 0
    self.offsetY = 0
    self.resizeX = 0
    self.resizeY = 0
    self:updateText(self.title)
end

function Window:updateText(text)
    self.title = text
    local font = self.font or windowFont
    local textSize = font:getLineHeight()
    if textSize ~= self.textSize then
        font = love.graphics.newFont(guiStyle.fontPath, self.textSize, guiStyle.fontType)
        self.font = font
    end
    self.titleObj = love.graphics.newText(font, text)
end

function Window:addElement(element)
    table.insert(self.elements, element)
end

function Window:removeElement(entity)
    for i = 1, #self.elements do
        if self.elements[i] == entity then
            table.remove(self.elements, i)
            break
        end
    end
end

function Window:mouseInside()
    local width, height = self.width, self.height
    local titleObj = self.titleObj
    local tW, tH = titleObj:getDimensions()
    if tW > width then
        width = tW
    end
    if tH > height then
        height = tH
    end

    return Window:mouseInsideRect(self.x, self.y, width, height)
end

function Window:mouseInsideRect(rX, rY, rW, rH)
    local v = {}
    v[1] = {love.graphics.transformPoint(rX, rY)}
    v[2] = {love.graphics.transformPoint(rX + rW, rY)}
    v[3] = {love.graphics.transformPoint(rX + rW, rY + rH)}
    v[4] = {love.graphics.transformPoint(rX, rY + rH)}

    return polyPoint(v, love.mouse.getPosition())
end

function Window:draw()
    if self.show then
        local width, height = self.width, self.height
        local mx, my = love.mouse.getPosition()
        local wmx, wmy = love.graphics.inverseTransformPoint(mx, my)
        local mdown = love.mouse.isDown(1)
        local crSize = 8
        if self:mouseInsideRect(self.x, self.y, self.width, self.textSize * self.fontScale) then
            if mdown and not self.lastDown then
                self.offsetX = self.x - wmx
                self.offsetY = self.y - wmy
            end
        end

        local coColor = colors.darkPink
        if self:mouseInsideRect(self.x + self.width - crSize, self.y + self.height - crSize, crSize, crSize) then
            if mdown and not self.lastDown then
                self.resizeX = self.x + self.width - wmx
                self.resizeY = self.y + self.height - wmy
            end
        end
        if self.lastDown and not mdown then
            self.offsetX = 0
            self.offsetY = 0
            self.resizeX = 0
            self.resizeY = 0
        end
        if mdown and self.lastDown then
            if self.offsetX ~= 0 or self.offsetY ~= 0 then
                self.x = self.offsetX + wmx
                self.y = self.offsetY + wmy
            end
            if self.resizeX ~= 0 or self.resizeY ~= 0 then
                coColor = colors.orange
                self.width = self.resizeX - self.x + wmx
                self.height = self.resizeY - self.y + wmy
            end
        end

        love.graphics.push()

        if self.parent == self.parent.level.camera then
            love.graphics.origin()
        end

        love.graphics.setColor(colors.red)
        love.graphics.rectangle("fill", self.x, self.y, width, height)
        love.graphics.setColor(colors.white)
        love.graphics.setLineWidth(self.lineWidth)
        love.graphics.rectangle("line", self.x, self.y, width, height)
        love.graphics.setColor(coColor)
        love.graphics.rectangle("fill", self.x + self.width - crSize, self.y + self.height - crSize, crSize, crSize)
        love.graphics.setColor(colors.white)
        love.graphics.draw(self.titleObj, self.x + 3, self.y, 0, self.fontScale, self.fontScale)

        self.lastDown = mdown

        self.transform =
            love.math.newTransform(self.x, self.y, self.r, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
        local x1, y1 = love.graphics.transformPoint(self.x, self.y)
        local x2, y2 = love.graphics.transformPoint(self.x + self.width, self.y + self.height)
        local width, height = math.abs(x2 - x1), math.abs(y2 - y1)
        love.graphics.applyTransform(self.transform)
        love.graphics.translate(0, 8)

        for _, elem in ipairs(self.elements) do
            if elem and not elem.hide and type(elem.draw) == "function" then
                love.graphics.setScissor(x1, y1, width, height)
                love.graphics.push()
                elem:draw()
                love.graphics.pop()
                love.graphics.setScissor()
            end
        end
        love.graphics.pop()
    end
end

return Window
