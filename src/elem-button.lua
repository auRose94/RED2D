local ElementClass = require".src.element"
local guiStyle = require".src.gui-style"
local Button = inheritsFrom(ElementClass)

local buttonFont =
    love.graphics.newFont(guiStyle.fontPath, 16, guiStyle.fontType)

function Button:init(...)
    ElementClass.init(self, ...)
    local text = self.text or ""
    self.x = self.x or 0
    self.y = self.y or 0
    self.textSize = self.textSize or 16
    self.width = self.width or 75
    self.height = self.height or self.textSize
    self.callback = self.callback or nil
    self.maxWidth = self.maxWidth or 500
    self.maxHeight = self.maxHeight or self.textSize
    self:updateText(text)
end

function Button:updateText(text)
    self.text = text
    local font = self.font or buttonFont
    local fontSize = font:getLineHeight()
    if fontSize ~= self.fontSize then
        font = love.graphics.newFont(
            guiStyle.fontPath, self.fontSize, guiStyle.fontType)
        self.font = font
    end
    self.textObj = love.graphics.newText(font, text)
end

function Button:draw()
    local width, height = self.width, self.height
    local x, y = self.x, self.y
    local tW, tH = self.textObj:getDimensions()
    if tW > width then width = tW end
    if tH > height then height = tH end
    if self.maxHeight < height then height = self.maxHeight end
    if self.maxWidth < height then height = self.maxWidth end

    love.graphics.setColor(colors.darkPink)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(colors.white)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, width, height)
    love.graphics.setColor(colors.white)
    love.graphics.draw(self.textObj, 0, 0, 0)
end

return Button