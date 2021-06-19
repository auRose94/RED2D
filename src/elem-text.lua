local ElementClass = require ".src.element"
local guiStyle = require ".src.gui-style"
local TextElement = inheritsFrom(ElementClass)

local buttonFont = love.graphics.newFont(guiStyle.fontPath, 9, guiStyle.fontType)

function TextElement:init(...)
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
    self.disabled = self.disabled or false

    self.defaultTextColor = self.defaultTextColor or colors.white
    self.pressTextColor = self.pressTextColor or colors.black
    self.hoverTextColor = self.hoverTextColor or colors.white
    self.disabledTextColor = self.disabledTextColor or colors.white

    self:updateText(text)
end

function TextElement:updateText(text)
    self.text = text
    local font = self.font or buttonFont
    local textSize = font:getLineHeight()
    if textSize ~= self.textSize then
        font = love.graphics.newFont(guiStyle.fontPath, self.textSize, guiStyle.fontType)
        self.font = font
    end
    self.textObj = love.graphics.newText(font)
    self.textObj:addf(text, self.maxWidth, "left")
    self.width, self.height = self.textObj:getDimensions()
end

function TextElement:draw()
    if not self.hide then
        local fontScale = self.fontScale
        local x, y = self.x, self.y
        local textObj = self.textObj
        local width, height = self.width, self.height
        local mdown = love.mouse.isDown(1)

        if self.maxWidth < width then
            width = self.maxWidth
        end
        if self.maxHeight < height then
            height = self.maxHeight
        end

        local textWidth, textHeight = textObj:getDimensions()
        local textX, textY = x, y

        local textColor = self.defaultTextColor
        if not self.disabled then
            if type(self.callback) == "function" and self:mouseInside() then
                if mdown then
                    textColor = self.pressTextColor
                    if not self.lastDown then
                        self:callback()
                    end
                else
                    textColor = self.hoverTextColor
                end
            end
            self.lastDown = mdown
        else
            textColor = self.disabledTextColor
        end

        love.graphics.setColor(textColor)
        love.graphics.draw(textObj, textX, textY, 0, self.fontScale, self.fontScale)
    end
end

return TextElement
