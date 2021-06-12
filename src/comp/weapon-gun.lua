local WeaponClass = require ".src.comp.weapon"
local GunClass = inheritsFrom(WeaponClass)

function GunClass:init(parent, ...)
    WeaponClass.init(self, parent, ...)
end
