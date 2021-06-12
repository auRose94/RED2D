local BodyComponent = require ".src.body"
local Human = inheritsFrom(BodyComponent)

function Human:init(parent, data, ...)
    BodyComponent.init(self, parent, data, ...)

    self.parent.drawOrder = 1

    self:setScale(2, 2)

    self.inventory = InventoryClass(parent, self, true)

    -- self.headEntity:setPosition(8, 8)
    local headParent = self:findChild("head")
    assert(headParent, "No head point found")
    local headComp = HeadComponent(headParent, HeadRedData)
    self.headComp = headComp

    self.joystickIndex = joystickIndex or 1
    self.playerIndex = playerIndex or 1
    self:registerControls()

    self.statusWindow = StatusWindow(parent)
end

function Human:draw()

end

return Human
