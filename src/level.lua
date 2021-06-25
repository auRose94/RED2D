local Camera = require "camera"
local Item = require "comp.item"
local Weapon = require "comp.weapon"
local Entity = require "entity"
local TileMap = require "comp.tilemap"
local Player = require "comp.player"
local OraLoader = require "ora-loader"
local DefaultItems = require "defaultItems"
local Level = inheritsFrom(nil)

function Level:addParalaxLevel(index, layer)
    self.camera:newLayer(index, layer)
end

function Level:removeEntity(entityA)
    for i, entityB in ipairs(self.entities) do
        if entityA == entityB then
            table.remove(self.entities, i)
            return nil
        end
    end
end

function Level:addEntity(entity)
    entity.level = self
    table.insert(self.entities, entity)
end

function Level:newItem(name, type, x, y)
    if self.tilemap then
        return Item(Entity(self, name, self.tilemap:getOffset(x, y)), type)
    end
    return nil
end

function Level:newWeapon(name, type, x, y)
    if self.tilemap then
        return Weapon(Entity(self, name, self.tilemap:getOffset(x, y)), type)
    end
    return nil
end

function Level:update(dt)
    local step = 1.0 / 60.0
    self.accumulator = self.accumulator + dt
    while self.accumulator >= step do
        self.world:update(step)
        self.accumulator = self.accumulator - step
    end
    for i = 1, #self.entities do
        local entity = self.entities[i]
        if entity and entity.update then
            entity:update(dt)
        end
    end
end

function Level:calcPath(sx, sy, ex, ey)
    if self.tilemap then
        return self.tilemap:calcPath(sx, sy, ex, ey)
    end
    return nil
end

function Level:init()
    self.entities = {}
    love.physics.setMeter(64)
    self.world = love.physics.newWorld(0, 0, true)
    self.camera = Camera(self)
    self.camera:newEntityLayer(2, self.entities)
    self.accumulator = 0
    self.tilemap = nil
end

function Level:getRootEntities()
    local roots = {}
    for i, entity in ipairs(self.entities) do
        if entity.parent == nil then
            table.insert(roots, entity)
        end
    end
    return roots
end

function Level:load(pathName)
    Level.init(self)
    local camera = self.camera

    local oraLoader = OraLoader(pathName)

    local tilemapObj = Entity(self, "Tilemap")

    local backTilemap = TileMap(tilemapObj, "assets/Tileset.png", 64)
    backTilemap:loadDefault()
    backTilemap:loadLevel(oraLoader:getImageData("background"), false)

    local tilemap = TileMap(tilemapObj, "assets/Tileset.png", 64)
    tilemap:loadDefault()
    tilemap:loadLevel(oraLoader:getImageData("base"))
    self.tilemap = tilemap

    local playerX, playerY = oraLoader:getOffset("player start")
    local playerEntity = Entity(self, "Player", tilemap:getOffset(playerX, playerY))
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
