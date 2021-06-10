local ElementClass = require".src.element"
local guiStyle = require".src.gui-style"
local Button = inheritsFrom(ElementClass)

local buttonFont =
    love.graphics.newFont(guiStyle.fontPath, 9, guiStyle.fontType)

function Button:init(...)
    ElementClass.init(self, ...)
    local text = self.text or ""
    self.lineWidth = self.lineWidth or 0.5
    self.textSize = self.textSize or 16
    self.fontScale = self.fontScale or 0.5
    self.width = self.width or 75
    self.height = self.height or 8
    self.callback = self.callback or nil
    self.maxWidth = self.maxWidth or 500
    self.maxHeight = self.maxHeight or self.textSize
    self:updateText(text)
end

function Button:updateText(text)
    self.text = text
    local font = self.font or buttonFont
    local textSize = font:getLineHeight()
    if textSize ~= self.textSize then
        font = love.graphics.newFont(
            guiStyle.fontPath, self.textSize, guiStyle.fontType)
        self.font = font
    end
    self.textObj = love.graphics.newText(font, text)
end

function Button:mouseInside()
    local mx, my = love.mouse.getPosition( )
    local width, height = self.width, self.height
    local textObj = self.textObj
    local tW, tH = textObj:getDimensions()
    if tW > width then width = tW end
    if tH > height then height = tH end
    if self.maxHeight < height then height = self.maxHeight end
    if self.maxWidth < height then height = self.maxWidth end

    local v = {}
    v[1] = {love.graphics.transformPoint(self.x, self.y)}
    v[2] = {love.graphics.transformPoint(self.x + width, self.y)}
    v[3] = {love.graphics.transformPoint(self.x + width, self.y + height)}
    v[4] = {love.graphics.transformPoint(self.x, self.y + height)}

    return polyPoint(v, mx, my)
end

function Button:draw()
    local fontScale = self.fontScale
    local x, y = self.x, self.y
    local textObj = self.textObj
    local width, height = self.width, self.height
    local tW, tH = textObj:getDimensions()
    if tW > width then width = tW end
    if tH > height then height = tH end
    if self.maxHeight < height then height = self.maxHeight end
    if self.maxWidth < height then height = self.maxWidth end

    local textWidth, textHeight = textObj:getDimensions()
    local textX, textY = x + (width - (textWidth*self.fontScale)) / 2, y + (height - (textHeight * fontScale)) / 2

    local bgColor = colors.darkPink
    if self:mouseInside() then
        bgColor = colors.red
    end

    love.graphics.setColor(bgColor)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(colors.white)
    love.graphics.setLineWidth(self.lineWidth)
    love.graphics.rectangle("line", x, y, width, height)
    love.graphics.setColor(colors.white)
    love.graphics.draw(textObj, textX, textY, 0, self.fontScale, self.fontScale)
end

return Button