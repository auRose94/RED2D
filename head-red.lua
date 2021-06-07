local module = {}

local OraLoader = require"ora-loader"
local texture = OraLoader("assets/head-red.ora")

local image = texture:getImage("Primary")

module.robot = true
module.headBase = { 9, 9 }

local tw, th = texture.width, texture.height
local w = 16
local h = 9

function NewQuad(x, y, z)
	z = z or 0
	return { image, love.graphics.newQuad(x, y, w, h, tw, th), z }
end

module.right = {
	face = NewQuad(102, 40),
	faceblushing = NewQuad(0, 60),
	facebroken = NewQuad(17, 60),
	eyes = {
		rotations = {
			NewQuad(0, 0, 1),
			NewQuad(17, 0, 1),
			NewQuad(34, 0, 1),
			NewQuad(51, 0, 1),
			NewQuad(68, 0, 1),
			NewQuad(85, 0, 1),
			NewQuad(102, 0, 1),
			NewQuad(0, 20, 1)
		},
		dead = NewQuad(17, 20, 1),
		happy = NewQuad(34, 20, 1),
		heart = NewQuad(51, 20, 1),
		hurt = NewQuad(68, 20, 1),
		center = NewQuad(85, 20, 1),
		blink = NewQuad(102, 20, 1),
		mad = NewQuad(0, 40, 1)
	},
	mouth = {
		frown = NewQuad(17, 40, 1),
		smile = NewQuad(34, 40, 1),
		open = NewQuad(51, 40, 1),
		close = NewQuad(68, 40, 1),
		grit = NewQuad(85, 40, 1)
	}
}
module.left = {
	face = NewQuad(102, 50),
	faceblushing = NewQuad(0, 70),
	facebroken = NewQuad(17, 70),
	eyes = {
		rotations = {
			NewQuad(0, 10, 1),
			NewQuad(17, 10, 1),
			NewQuad(34, 10, 1),
			NewQuad(51, 10, 1),
			NewQuad(68, 10, 1),
			NewQuad(85, 10, 1),
			NewQuad(102, 10, 1),
			NewQuad(0, 30, 1)
		},
		dead = NewQuad(17, 30, 1),
		happy = NewQuad(34, 30, 1),
		heart = NewQuad(51, 30, 1),
		hurt = NewQuad(68, 30, 1),
		center = NewQuad(85, 30, 1),
		blink = NewQuad(102, 30, 1),
		mad = NewQuad(0, 50, 1)
	},
	mouth = {
		frown = NewQuad(17, 50, 1),
		smile = NewQuad(34, 50, 1),
		open = NewQuad(51, 50, 1),
		close = NewQuad(68, 50, 1),
		grit = NewQuad(85, 50, 1)
	}
}

return module