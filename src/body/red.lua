local module = {}

local CircleShapeComponent = require ".src.comp.shape.circle"
local RectangleShapeComponent = require ".src.comp.shape.rectangle"

local OraLoader = require ".src.ora-loader"
local bodyRed = OraLoader("assets/body-red.ora")

local topImage = bodyRed:getImage("Top")
local legsImage = bodyRed:getImage("Legs")
local baseImage = bodyRed:getImage("Base")
local bottomImage = bodyRed:getImage("Bottom")

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
    self.bodyShape = RectangleShapeComponent(self.parent, 0, -10, 18, 16)
    self.bodyFixture = self.physComp:newFixture(self.bodyShape, 4)
    self.bodyFixture:setRestitution(0.015)
    self.bodyFixture:setCategory(3)
    self.bodyFixture:setMask(2)

    self.bottomShape = CircleShapeComponent(self.parent, 0, ballYOffset, 10)
    self.bottomFixture = self.physComp:newFixture(self.bottomShape, 2)
    self.bottomFixture:setRestitution(0.015)
    self.bottomFixture:setFriction(0.25)
    self.bottomFixture:setCategory(3)
    self.bottomFixture:setMask(2)
end

function NewBase(x, y)
    return {baseImage, love.graphics.newQuad(x, y, 16, 16, baseImage:getPixelDimensions()), 0}
end

function NewTopArm(x, y)
    return {topImage, love.graphics.newQuad(x, y, 16, 16, topImage:getPixelDimensions()), 1}
end

function NewBottomArm(x, y)
    return {bottomImage, love.graphics.newQuad(x, y, 16, 16, bottomImage:getPixelDimensions()), -1}
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
    arms = {
        left = {
            base = {11, 3},
            rotations = {NewTopArm(0, 48), NewTopArm(16, 48), NewTopArm(16 * 2, 48), NewTopArm(16 * 3, 48),
                         NewTopArm(16 * 4, 48), NewTopArm(16 * 5, 48), NewTopArm(16 * 6, 48), NewTopArm(16 * 7, 48)},
            points = {{7, 7}, {7, 3}, {9, 3}, {16, 3}, {16, 7}, {16, 11}, {12, 11}, {8, 10}}
        },
        right = {
            base = {5, 3},
            rotations = {NewBottomArm(0, 16), NewBottomArm(16, 16), NewBottomArm(16 * 2, 16), NewTopArm(16 * 3, 32),
                         NewTopArm(16 * 4, 32), NewTopArm(16 * 5, 32), NewBottomArm(16 * 6, 16),
                         NewBottomArm(16 * 7, 16)},
            points = {{1, 7}, {1, 3}, {3, 3}, {8, 3}, {8, 6}, {8, 10}, {5, 11}, {2, 10}}
        }
    },
    legs = {
        standing = NewLeg(0, 16),
        animation = {NewLeg(16, 16), NewLeg(16 * 2, 16), NewLeg(16 * 3, 16), NewLeg(16 * 4, 16), NewLeg(16 * 5, 16),
                     NewLeg(16 * 6, 16), NewLeg(16 * 7, 16)}
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
    arms = {
        left = {
            base = {11, 3},
            rotations = {NewTopArm(0, 0), NewTopArm(16, 0), NewTopArm(16 * 2, 0), NewTopArm(16 * 3, 0),
                         NewTopArm(16 * 4, 0), NewTopArm(16 * 5, 0), NewTopArm(16 * 6, 0), NewTopArm(16 * 7, 0)},
            points = {{1, 7}, {1, 3}, {8, 3}, {10, 3}, {10, 7}, {9, 10}, {6, 11}, {1, 11}}
        },
        right = {
            base = {5, 3},
            rotations = {NewTopArm(0, 16), NewTopArm(16, 16), NewBottomArm(16 * 2, 0), NewBottomArm(16 * 3, 0),
                         NewBottomArm(16 * 4, 0), NewBottomArm(16 * 5, 0), NewBottomArm(16 * 6, 0),
                         NewTopArm(16 * 7, 16)},
            points = {{10, 8}, {10, 5}, {14, 3}, {16, 3}, {16, 7}, {15, 10}, {12, 11}, {10, 10}}
        }
    },
    legs = {
        standing = NewLeg(0, 0),
        animation = {NewLeg(16, 0), NewLeg(16 * 2, 0), NewLeg(16 * 3, 0), NewLeg(16 * 4, 0), NewLeg(16 * 5, 0),
                     NewLeg(16 * 6, 0), NewLeg(16 * 7, 0)}
    }
}

return module
