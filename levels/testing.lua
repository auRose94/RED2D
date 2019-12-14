local LevelClass = require "level"
local EntityClass = require "entity"
local PlayerClass = require "comp-player"
local TileMapClass = require "tilemap"
local ItemClass = require "comp-item"
local WeaponClass = require "comp-weapon"

local level = inheritsFrom(LevelClass)

function level:init()
	LevelClass.init(self)
	local camera = self.camera

	local tilemap = TileMapClass(self, "assets/Tileset.png", 64)
	tilemap:loadDefault()
	tilemap:loadLevel("levels/testing.png")

	local playerEntity = EntityClass(self, "Player", tilemap:getOffset(30, 19))
	PlayerClass(playerEntity)

	camera:setTransformOffset(tilemap:getOffset(30, 19))

	ItemClass(
		EntityClass(self, "Ammo_0", tilemap:getOffset(29, 20)),
		"ammo_9mm")
	ItemClass(
		EntityClass(self, "Ammo_1", tilemap:getOffset(30, 20)),
		"ammo_45mm")
	ItemClass(
		EntityClass(self, "Ammo_2", tilemap:getOffset(31, 20)),
		"ammo_556mm")

	WeaponClass(
		EntityClass(self, "9mmHandgun_01", tilemap:getOffset(30, 19)),
		"9mm_handgun")

	camera.followTarget = playerEntity
end

return level