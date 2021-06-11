-- Setup GUI Style
local module = {}
-- local imgui = require".src.imgui"

local fontPath = "assets/unifont.ttf"
local fontSize = 32
local fontType = "mono"
local font = love.graphics.newFont(fontPath, fontSize, fontType)
font:setFilter("linear", "nearest", 0)

module.font = font
module.fontSize = fontSize
module.fontType = fontType
module.fontPath = fontPath

function module.load()
    love.graphics.setFont(font)
end

return module
