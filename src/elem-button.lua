local ElementClass = require ".src.element"
local guiStyle = require ".src.gui-style"
local Button = inheritsFrom(ElementClass)

local buttonFont = love.graphics.newFont(guiStyle.fontPath, 9, guiStyle.fontType)

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
        font = love.graphics.newFont(guiStyle.fontPath, self.textSize, guiStyle.fontType)
        self.font = font
    end
    self.textObj = love.graphics.newText(font, text)
end

function Button:draw()
    if not self.hide then
        local fontScale = self.fontScale
        local x, y = self.x, self.y
        local textObj = self.textObj
        local width, height = self.width, self.height
        local tW, tH = textObj:getDimensions()
        local mdown = love.mouse.isDown(1)

        if tW > width then
            width = tW
        end
        if tH > height then
            height = tH
        end
        if self.maxWidth < width then
            width = self.maxWidth
        end
        if self.maxHeight < height then
            height = self.maxHeight
        end

        local textWidth, textHeight = textObj:getDimensions()
        local textX, textY = x + (width - (textWidth * fontScale)) / 2, y + (height - (textHeight * fontScale)) / 2

        local bgColor = colors.darkPink
        if self:mouseInside() then
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
        love.graphics.rectangle("fill", x, y, width, height)
        love.graphics.setColor(colors.white)
        love.graphics.setLineWidth(self.lineWidth)
        love.graphics.rectangle("line", x, y, width, height)
        love.graphics.setColor(colors.white)
        love.graphics.draw(textObj, textX, textY, 0, self.fontScale, self.fontScale)

    end
end

return Button
