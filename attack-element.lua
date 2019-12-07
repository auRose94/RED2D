
local AttackElement = inheritsFrom()

function AttackElement:init(system, attacker, weapon)
	self.x, self.y = weapon:inverseTransformPoint(weapon.aimPoint)
	self.dx, self.dy = weapon:inverseTransformNormal(1, 0)
	self.attacker = attacker
	self.weapon = weapon
	self.system = system
end

function AttackElement:update(dt)

end

function AttackElement:draw()

end

return AttackElement