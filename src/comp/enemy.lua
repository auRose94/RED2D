local Component = require "component"
local Body = require "comp.body"
local Enemy = inheritsFrom()

function Enemy:getName()
    return "Enemy"
end

function Enemy:init()
    Body.init(self, parent, BodyRedData, ...)
    self.parent.drawOrder = 0.01

    self.inventory = Inventory(parent, self, true)
end

function Enemy:update(dt)
    Body.update(self, dt)
end

return Enemy
