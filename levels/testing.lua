local Level = require "level"
local Entity = require "entity"
local Player = require "comp.player"
local EnemyDrone = require "comp.enemy-drone"
local TileMap = require "comp.tilemap"
local Item = require "comp.item"
local Weapon = require "comp.weapon"
local OraLoader = require "ora-loader"

local level = inheritsFrom(Level)

function level:init()
    self:load("levels/testing.ora")

    local enemyX, enemyY = self.oraLoader:getOffset("player start")
    local enemyEntity = Entity(self, "Drone#1", self.tilemap:getOffset(enemyX, enemyY))
    EnemyDrone(enemyEntity)
end

return level
