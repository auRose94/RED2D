local module = {}

local CircleShape = require "comp.shape.circle"
local RectangleShape = require "comp.shape.rectangle"

local OraLoader = require "ora-loader"
local bodySpider = OraLoader("assets/body-spider.ora")

local eyesImage = bodySpider:getImage("eyes")
local bodyImage = bodySpider:getImage("body")
local extraImage = bodySpider:getImage("extra")

module.robot = true

module.headMount = nil
module.bodySize = {6, 9}
module.offsetX = 12
module.offsetY = 16
module.walkingFrameSpeed = 2
module.speed = 600
module.flySpeed = 500
module.jumpPower = 350
module.gravity = 980
module.touchAngle = 0.005
module.knockOutSpeed = 1500
module.topSpeed = 450
module.rotSpeed = 40

function module.createPhysics(self)
    local ballYOffset = 2
    local w, h = unpack(module.bodySize)
    w, h = w * 2, h * 2
    self.bodyShape = RectangleShape(self.parent, 0, -10, w, h)
    self.bodyFixture = self.physComp:newFixture(self.bodyShape, 4)
    self.bodyFixture:setRestitution(0.015)
    self.bodyFixture:setCategory(3)
    self.bodyFixture:setMask(2)
    self.bodyFixture:setUserData(self)

    self.bottomShape = CircleShape(self.parent, 0, ballYOffset, 10)
    self.bottomFixture = self.physComp:newFixture(self.bottomShape, 2)
    self.bottomFixture:setRestitution(0.015)
    self.bottomFixture:setFriction(0.25)
    self.bottomFixture:setCategory(3)
    self.bottomFixture:setMask(2)
    self.bottomFixture:setUserData(self)
end

function NewEyes(x, y)
    return {eyesImage, love.graphics.newQuad(x, y, 24, 24, eyesImage:getPixelDimensions()), 1}
end

function NewBody(x, y)
    return {bodyImage, love.graphics.newQuad(x, y, 24, 24, bodyImage:getPixelDimensions()), 0}
end

function NewExtra(x, y)
    return {extraImage, love.graphics.newQuad(x, y, 24, 24, extraImage:getPixelDimensions()), -1}
end

module.extra = {
    broken = NewExtra(120, 120),
    brokenIce = NewExtra(120, 96),
    brokenFire = NewExtra(120, 72),
    poison = {NewExtra(0, 120), NewExtra(24, 120), NewExtra(48, 120), NewExtra(72, 120), NewExtra(72, 120)},
    ice = {NewExtra(0, 96), NewExtra(24, 96), NewExtra(48, 96), NewExtra(72, 96), NewExtra(72, 96)},
    fire = {NewExtra(0, 72), NewExtra(24, 72), NewExtra(48, 72), NewExtra(72, 72), NewExtra(72, 72)},
    origin = {{12, 19}, {12, 20}, {12, 21}, {12, 22}, {12, 23}}
}

module.left = {
    center = {12, 20},
    standing = {
        body = NewBody(0, 48),
        eyes = NewEyes(0, 48),
        extraPos = {16, 13},
        extraRot = 0
    },
    walking = {
        {
            body = NewBody(24, 48),
            eyes = NewEyes(24, 48),
            extraPos = {16, 13},
            extraRot = 0
        },
        {
            body = NewBody(48, 48),
            eyes = NewEyes(48, 48),
            extraPos = {16, 13},
            extraRot = 0
        }
    },
    attack = {
        {
            body = NewBody(96, 48),
            eyes = NewEyes(96, 48),
            extraPos = {16, 13},
            extraRot = 0
        },
        {
            body = NewBody(72, 48),
            eyes = NewEyes(72, 48),
            extraPos = {13, 13},
            extraRot = 0
        }
    },
    charge = {
        body = NewBody(96, 48),
        eyes = NewEyes(96, 48),
        extraPos = {16, 13},
        extraRot = 0
    },
    dead = {
        body = NewBody(120, 48),
        eyes = NewEyes(120, 48),
        extraPos = {17, 18},
        extraRot = 0
    }
}

module.right = {
    center = {12, 20},
    standing = {
        body = NewBody(0, 24),
        eyes = NewEyes(0, 24),
        extraPos = {8, 13},
        extraRot = 0
    },
    walking = {
        {
            body = NewBody(24, 24),
            eyes = NewEyes(24, 24),
            extraPos = {8, 13},
            extraRot = 0
        },
        {
            body = NewBody(48, 24),
            eyes = NewEyes(48, 24),
            extraPos = {8, 13},
            extraRot = 0
        }
    },
    attack = {
        {
            body = NewBody(96, 24),
            eyes = NewEyes(96, 24),
            extraPos = {11, 13},
            extraRot = 0
        },
        {
            body = NewBody(72, 24),
            eyes = NewEyes(72, 24),
            extraPos = {8, 13},
            extraRot = 0
        }
    },
    charge = {
        body = NewBody(96, 24),
        eyes = NewEyes(96, 24),
        extraPos = {8, 13},
        extraRot = 0
    },
    dead = {
        body = NewBody(120, 24),
        eyes = NewEyes(120, 24),
        extraPos = {8, 18},
        extraRot = 0
    }
}

module.top = {
    center = {12, 19},
    standing = {
        body = NewBody(0, 0),
        eyes = NewEyes(0, 0),
        extraPos = {12, 7},
        extraRot = 0
    },
    walking = {
        {
            body = NewBody(24, 0),
            eyes = NewEyes(24, 0),
            extraPos = {12, 7},
            extraRot = 0
        },
        {
            body = NewBody(48, 0),
            eyes = NewEyes(48, 0),
            extraPos = {12, 7},
            extraRot = 0
        }
    },
    attack = {
        {
            body = NewBody(96, 0),
            eyes = NewEyes(96, 0),
            extraPos = {12, 10},
            extraRot = 0
        },
        {
            body = NewBody(72, 0),
            eyes = NewEyes(72, 0),
            extraPos = {12, 7},
            extraRot = 0
        }
    },
    charge = {
        body = NewBody(96, 0),
        eyes = NewEyes(96, 0),
        extraPos = {12, 7},
        extraRot = 0
    },
    dead = {
        body = NewBody(120, 0),
        eyes = NewEyes(120, 0),
        extraPos = {12, 7},
        extraRot = 0
    }
}

return module
