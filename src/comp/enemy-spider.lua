local Component = require "component"
local Body = require "comp.body"
local SpiderBot = inheritsFrom(Body)

function SpiderBot:getName()
    return "SpiderBot"
end

function SpiderBot:init()
    Body.init(self, parent, BodyRedData, ...)
    self.parent.drawOrder = 1

    self:setScale(2, 2)

    self.inventory = Inventory(parent, self, true)
end

function PlayerComponent:update(dt)
    Body.update(self, dt)
end

return SpiderBot
