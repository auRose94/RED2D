local module = {}

function _G.RGB(r, g, b, a)
    a = a or 255
    return {r / 255, g / 255, b / 255, a / 255}
end

function _G.uRGB(r, g, b, a)
    return unpack(RGB(r, g, b, a))
end

-- mod.color	=	RGB(R,		G,		B)
module.white = RGB(255, 255, 255)
module.gray = RGB(42, 42, 42)
module.black = RGB(0, 0, 0)
module.brown = RGB(42, 0, 0)
module.pansy = RGB(120, 1, 79)
module.red = RGB(213, 14, 85)
module.orange = RGB(237, 103, 58)
module.yellow = RGB(255, 199, 93)
module.darkGreen = RGB(3, 118, 11)
module.lightGreen = RGB(83, 184, 16)
module.lightBlue = RGB(195, 255, 226)
module.purple = RGB(143, 17, 186)
module.blue = RGB(53, 110, 226)
module.cyan = RGB(71, 201, 237)
module.eggplant = RGB(89, 64, 75)
module.darkPink = RGB(146, 118, 145)
module.wisteria = RGB(203, 156, 220)
module.magenta = RGB(228, 39, 198)

_G.Colors = module
_G.colors = module

return module
