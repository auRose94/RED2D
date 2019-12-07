local module = {}

function C(r, g, b, a)
	a = a or 255
	return { r/255, g/255, b/255, a/255 }
end

--mod.color	=				C(R,		G,		B)		--#HEX
module.white =			C(255,	255,	255)	--#FFFFFF
module.gray =				C(42,		42,		42)		--#424242
module.black =			C(0,		0,		0)		--#000000
module.brown =			C(42,		0,		0)		--#2a0000
module.pansy =			C(120,	1,		79)		--#78014f
module.red =				C(213,	14,		85)		--#d50e55
module.orange =			C(237,	103,	58)		--#ed673a
module.yellow =			C(255,	199,	93)		--#ffc75d
module.darkGreen =	C(3,		118,	11)		--#03760b
module.lightGreen =	C(83,		184,	16)		--#53b810
module.lightBlue =	C(195,	255,	226)	--#c3ffe2
module.purple =			C(143,	17,		186)	--#8f11ba
module.blue =				C(53,		110,	226)	--#356ee2
module.cyan =				C(71,		201,	237)	--#47c9ed
module.eggplant =		C(89,		64,		75)		--#59404b
module.darkPink =		C(146,	118,	145)	--#927691
module.wisteria =		C(203,	156,	220)	--#cb9cdc
module.magenta =		C(228,	39,		198)	--#e427c6

_G.Colors = module
_G.colors = module

return module