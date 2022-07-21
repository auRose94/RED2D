local Camera = require "camera"
local Item = require "comp.item"
local Weapon = require "comp.weapon"
local Entity = require "entity"
local TileMap = require "comp.tilemap"
local Player = require "comp.player"
local OraLoader = require "ora-loader"
local DefaultItems = require "defaultItems"
local Level = inheritsFrom(nil)

function Level:removeEntity(entityA)
    local found = false
    local value = nil
    for index, childB in ipairs(self.children) do
        if entityA == childB then
            value = childB
            found = index
            break
        end
    end
    if found and value then
        -- value:destroy()
        value.parent = nil
        table.remove(self.children, found)
        return value
    end
end

function Level:addEntity(entity)
    entity.level = self
    if entity.parent == nil then
        table.insert(self.children, entity)
    end
end

function Level:newItem(name, type, x, y)
    if self.tilemap then
        local entity = Entity(self, name, self.tilemap:getOffset(x, y))
        entity.drawOrder = 0.01
        return Item(entity, type)
    end
    return nil
end

function Level:newWeapon(name, type, x, y)
    if self.tilemap then
        local entity = Entity(self, name, self.tilemap:getOffset(x, y))
        entity.drawOrder = 0.01
        return Weapon(entity, type)
    end
    return nil
end

function Level:dumpAllEntities(onEntity)
    if type(onEntity) == "function" then
        for _, child in pairs(self.children) do
            onEntity(child)
            child:dumpAllEntities(onEntity)
        end
    end
end

function Level:update(dt)
    local step = 1.0 / 60.0
    self.accumulator = self.accumulator + dt
    while self.accumulator >= step do
        self.world:update(step)
        self.accumulator = self.accumulator - step
    end
    for _, child in pairs(self.children) do
        child:update(dt)
    end
end

function Level:calcPath(sx, sy, ex, ey)
    if self.tilemap then
        return self.tilemap:calcPath(sx, sy, ex, ey)
    end
    return nil
end

function Level:init()
    if not _G.level then
        _G.level = self
    end
    love.physics.setMeter(64)
    self.world = love.physics.newWorld(0, 0, true)
    self.accumulator = 0
    self.tilemap = nil
    self.children = {}
    self.camera = Camera(self)
    self.camera:newEntityLayer(1, self.children)
end

function Level:load(pathName)
    Level.init(self)
    local camera = self.camera

    local oraLoader = OraLoader(pathName)
    self.oraLoader = oraLoader

    local tilemapObj = Entity(self, "Tilemap")
    tilemapObj.drawOrder = -0.01

    local backTilemap = TileMap(tilemapObj, "assets/Tileset.png", 64)
    backTilemap:loadDefault()
    backTilemap:loadLevel(oraLoader:getImageData("background"), false)

    local tilemap = TileMap(tilemapObj, "assets/Tileset.png", 64)
    tilemap:loadDefault()
    tilemap:loadLevel(oraLoader:getImageData("base"))
    self.tilemap = tilemap

    local playerX, playerY = oraLoader:getOffset("player start")
    local playerEntity = Entity(self, "Player", tilemap:getOffset(playerX, playerY))
    playerEntity.drawOrder = 0.01
    Player(playerEntity)

    camera:setTransformOffset(tilemap:getOffset(playerX, playerY))
    camera.followTarget = playerEntity

    for k, item in pairs(DefaultItems) do
        local layer = oraLoader:getLayer(k)
        if layer then
            local image = layer.imageData
            local width = image:getWidth()
            local height = image:getHeight()
            local i = 0
            for x = 0, width - 1 do
                for y = 0, height - 1 do
                    local index = y * width + x
                    local r, g, b, a = image:getPixel(x, y)
                    local tileData = nil
                    r = math.ceil(r * 255)
                    g = math.ceil(g * 255)
                    b = math.ceil(b * 255)
                    a = math.ceil(a * 255)
                    if a >= 1 then
                        i = i + 1
                        if item.type == "weapon" then
                            self:newWeapon(item.name .. "#" .. i, k, x, y)
                        else
                            self:newItem(item.name .. "#" .. i, k, x, y)
                        end
                    end
                end
            end
        end
    end
end

return Level
