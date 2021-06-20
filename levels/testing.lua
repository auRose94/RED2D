local Level = require "level"
local Entity = require "entity"
local Player = require "comp.player"
local TileMap = require "comp.tilemap"
local Item = require "comp.item"
local Weapon = require "comp.weapon"
local OraLoader = require "ora-loader"

local level = inheritsFrom(Level)

function level:init()
    level:load("levels/testing.ora")
end

return level
