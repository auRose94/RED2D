local LevelClass = require".src.level"
local EntityClass = require".src.entity"
local PlayerClass = require".src.comp-player"
local TileMapClass = require".src.comp-tilemap"
local ItemClass = require".src.comp-item"
local WeaponClass = require".src.comp-weapon"
local OraLoader = require".src.ora-loader"

local level = inheritsFrom(LevelClass)

function level:init()
	LevelClass.init(self)
	local camera = self.camera

	local oraLoader = OraLoader("levels/testing.ora")

	local tilemapObj = EntityClass(self, "Tilemap")

	local backTilemap = TileMapClass(tilemapObj, "assets/Tileset.png", 64)
	backTilemap:loadDefault()
	backTilemap:loadLevel(oraLoader:getImageData("background"), false)

	local tilemap = TileMapClass(tilemapObj, "assets/Tileset.png", 64)
	tilemap:loadDefault()
	tilemap:loadLevel(oraLoader:getImageData("base"))

	local playerEntity = EntityClass(self, "Player", tilemap:getOffset(30, 19))
	PlayerClass(playerEntity)

	camera:setTransformOffset(tilemap:getOffset(30, 19))

	ItemClass(EntityClass(self, "Ammo_0", tilemap:getOffset(29, 20)), "ammo_9mm")
	ItemClass(EntityClass(self, "Ammo_1", tilemap:getOffset(30, 20)), "ammo_45mm")
	ItemClass(
		EntityClass(self, "Ammo_2", tilemap:getOffset(31, 20)),
		"ammo_556mm"
	)

	WeaponClass(
		EntityClass(self, "9mmHandgun_01", tilemap:getOffset(30, 19)),
		"9mm_handgun"
	)

	camera.followTarget = playerEntity
end

return level