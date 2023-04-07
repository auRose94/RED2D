local module = {}

local CircleShape = require "comp.shape.circle"
local RectangleShape = require "comp.shape.rectangle"

local OraLoader = require "engine.ora-loader"
local bodyDrone = OraLoader("assets/body-drone2.ora")

local legsImage = bodyDrone:getImage("Legs")
local baseImage = bodyDrone:getImage("Base")

module.robot = true

module.headMount = {8, 1}
module.bodySize = {9, 8}
module.offsetX = 7.5
module.offsetY = 10
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
    self.bodyFixture:setCategory(6)
    self.bodyFixture:setMask(2, 3, 6)
    self.bodyFixture:setUserData(self)

    self.bottomShape = CircleShape(self.parent, 0, ballYOffset, 10)
    self.bottomFixture = self.physComp:newFixture(self.bottomShape, 2)
    self.bottomFixture:setRestitution(0.015)
    self.bottomFixture:setFriction(0.25)
    self.bottomFixture:setCategory(6)
    self.bottomFixture:setMask(2, 3, 6)
    self.bottomFixture:setUserData(self)
end

function NewBase(x, y)
    return {baseImage, love.graphics.newQuad(x, y, 16, 16, baseImage:getPixelDimensions()), 0}
end

function NewLeg(x, y)
    return {legsImage, love.graphics.newQuad(x, y, 16, 16, legsImage:getPixelDimensions()), 0}
end

module.left = {
    center = {7, 6},
    base = {
        default = NewBase(0, 0),
        worn = NewBase(16, 0),
        striped = NewBase(32, 0),
        unpainted = NewBase(48, 0),
        blue = NewBase(64, 0),
        yellow = NewBase(80, 0),
        purple = NewBase(96, 0),
        green = NewBase(112, 0)
    },
    legs = {
        standing = NewLeg(0, 16),
        animation = {
            NewLeg(16, 16),
            NewLeg(16 * 2, 16),
            NewLeg(16 * 3, 16),
            NewLeg(16 * 4, 16),
            NewLeg(16 * 5, 16),
            NewLeg(16 * 6, 16),
            NewLeg(16 * 7, 16)
        }
    }
}

module.right = {
    center = {10, 6},
    base = {
        default = NewBase(0, 16),
        worn = NewBase(16, 16),
        striped = NewBase(32, 16),
        unpainted = NewBase(48, 16),
        blue = NewBase(64, 16),
        yellow = NewBase(80, 16),
        purple = NewBase(96, 16),
        green = NewBase(112, 16)
    },
    legs = {
        standing = NewLeg(0, 0),
        animation = {
            NewLeg(16, 0),
            NewLeg(16 * 2, 0),
            NewLeg(16 * 3, 0),
            NewLeg(16 * 4, 0),
            NewLeg(16 * 5, 0),
            NewLeg(16 * 6, 0),
            NewLeg(16 * 7, 0)
        }
    }
}

return module
