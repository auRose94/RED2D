local LevelClass = require "level"
local EntityClass = require "entity"
local PlayerClass = require "comp.player"
local TileMapClass = require "comp.tilemap"
local ItemClass = require "comp.item"
local WeaponClass = require "comp.weapon"
local OraLoader = require "ora-loader"

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
    self.tilemap = tilemap

    local playerEntity = EntityClass(self, "Player", tilemap:getOffset(30, 19))
    PlayerClass(playerEntity)

    camera:setTransformOffset(tilemap:getOffset(30, 19))
    camera.followTarget = playerEntity

    self:newItem("ammo_9mm_1", "ammo_9mm", 30, 19)
    self:newItem("ammo_45mm_1", "ammo_45mm", 29, 19)
    self:newItem("ammo_556mm_1", "ammo_556mm", 31, 19)

    self:newWeapon("9mmHandgun_01", "9mm_handgun", 30, 19)
end

return level
