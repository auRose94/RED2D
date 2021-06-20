local Component = require "component"
local defaultTileMap = require "defaultTileMap"
local PathMap = require "path-map"
local ROT = require "rot"
local TileMap = inheritsFrom(Component)

function floatEqual(left, right, precision)
    precision = precision or 0.1
    local diff = math.abs(left - right)
    return diff < precision
end

function CheckValue(t, value)
    for i, v in ipairs(t) do
        if v == value then
            return true
        end
    end
    return false
end

function UniquePush(t, value)
    if not CheckValue(t, value) then
        table.insert(t, value)
    end
end

function TileMap:init(parent, location, tileSize, ...)
    Component.init(self, parent, ...)
    self.image = love.graphics.newImage(location)
    self.image:setFilter("linear", "nearest")
    self.tileSize = tileSize or self.tileSize or 0
    self.tiles = self.tiles or {}
    self.data = self.data or {}
    self.body = nil
    self.parent.drawOrder = -1
end

function TileMap:setStarMap(x, y, value)
    if type(self.starMap[y]) ~= "table" then
        self.starMap[y] = {}
    end
    self.starMap[y][x] = value
end

function TileMap:getStarPoint(x, y)
    if type(self.starMap[y]) ~= "table" then
        return 0
    end
    return self.starMap[y][x] or 0
end

function TileMap:calcPath(sx, sy, ex, ey)
    local dijkstra =
        ROT.Path.Dijkstra(
        sx,
        sy,
        function(x, y)
            self:getStarPoint(x, y)
        end
    )
    local path = {}
    dijkstra:compute(
        ex,
        ey,
        function(x, y)
            table.insert(path, {x, y})
        end
    )
    return path
end

function TileMap:loadLevel(location, usePhysics)
    usePhysics = usePhysics or true
    local image = nil
    if type(location) == "string" then
        image = love.image.newImageData(location)
    else
        image = location
    end
    assert(image ~= nil)
    local width = image:getWidth()
    local height = image:getHeight()
    self.spriteBatch = love.graphics.newSpriteBatch(self.image, width * height)
    if usePhysics then
        self.body = self.body or love.physics.newBody(self.parent.level.world, 0, 0, "static")
    end
    self.indexMap = {}
    self.fixturesMap = {}
    self.shapesMap = {}
    self.edgeTable = {}
    self.starMap = {}
    local size = self.tileSize

    for x = 0, width - 1 do
        for y = 0, height - 1 do
            local index = y * width + x
            local r, g, b, a = image:getPixel(x, y)
            local tileData = nil
            r = math.ceil(r * 255)
            g = math.ceil(g * 255)
            b = math.ceil(b * 255)
            a = math.ceil(a * 255)
            if a ~= 0 then
                local key = convert2HEX(r, g, b, a)
                tileData = self:getTileData(key)
                if tileData then
                    local shapes = {}
                    local fixtures = {}
                    if tileData.quad then
                        self.indexMap[index] = self.spriteBatch:add(tileData.quad, (x * size), (y * size), 0, 1)
                    end
                    if usePhysics then
                        if tileData.edges then
                            self:setStarMap(x * size, y * size, 1)
                            local edges = tileData.edges(x * size, y * size)
                            for ei, edge in ipairs(edges) do
                                table.insert(self.edgeTable, {edge, tileData})
                            end
                        end
                        if tileData.shape then
                            local shape = tileData.shape(x * size, y * size)
                            local fixture = love.physics.newFixture(self.body, shape, tileData.density)
                            fixture:setFriction(tileData.friction)
                            fixture:setRestitution(tileData.restitution)
                            if #tileData.category > 0 then
                                fixture:setCategory(unpack(tileData.category))
                            end
                            if #tileData.mask > 0 then
                                fixture:setMask(unpack(tileData.mask))
                            end
                            table.insert(self.fixturesMap, fixture)
                            table.insert(self.shapesMap, shape)
                        end
                    end
                else
                    print(key .. " Missing from Tilemap on ", x, y)
                end
            end
            table.insert(self.data, {x, y, tileData})
        end
    end
    self.spriteBatch:flush()
    if usePhysics then
        local pathMap = PathMap()
        -- Optimize edges, remove double edges
        local toRemove = {} -- Add index of doubles
        for iA, packA in ipairs(self.edgeTable) do
            local aEdge, aTileData = unpack(packA)
            aX1, aY1, aX2, aY2 = unpack(aEdge) -- x1, y1, x2, y2
            for iB, packB in ipairs(self.edgeTable) do
                if packA ~= packB then
                    local bEdge, bTileData = unpack(packB)
                    bX1, bY1, bX2, bY2 = unpack(bEdge) -- x1, y1, x2, y2
                    -- Duplicate test
                    local sameP1 = floatEqual(aX1, bX1) and floatEqual(aY1, bY1)
                    local sameP1R = floatEqual(aX1, bX2) and floatEqual(aY1, bY2)
                    local sameP2 = floatEqual(aX2, bX2) and floatEqual(aY2, bY2)
                    local sameP2R = floatEqual(aX2, bX1) and floatEqual(aY2, bY1)
                    if (sameP1 or sameP1R) and (sameP2 or sameP2R) then
                        UniquePush(toRemove, iA)
                        UniquePush(toRemove, iB)
                        break
                    end
                end
            end
        end
        -- We still need to optimize the edges more
        for i, pack in ipairs(self.edgeTable) do
            local edge, tileData = unpack(pack)
            if not CheckValue(toRemove, i) then
                local x1, y1, x2, y2 = unpack(edge)
                -- Special path tool that checks for uniqueness and optimizes it
                pathMap:addEdge(x1, y1, x2, y2, tileData)
            end
        end
        pathMap:simplify() -- Magic
        local edges = pathMap:getEdges() -- {x1, y1, x2, y2, tileData}[]
        for i, v in ipairs(edges) do
            local x1, y1, x2, y2, tileData = unpack(v)
            self:setStarMap(x1, y1, 1)
            self:setStarMap(x2, y2, 1)
            local shape = love.physics.newEdgeShape(x1, y1, x2, y2)
            local fixture = love.physics.newFixture(self.body, shape, tileData.density)
            fixture:setFriction(tileData.friction)
            fixture:setRestitution(tileData.restitution)
            if #tileData.category > 0 then
                fixture:setCategory(unpack(tileData.category))
            end
            if #tileData.mask > 0 then
                fixture:setMask(unpack(tileData.mask))
            end

            table.insert(self.shapesMap, shape)
            table.insert(self.fixturesMap, fixture)
        end
    end

    self.width = width
    self.height = height
end

function TileMap:getOffset(x, y)
    x = x or 0
    y = y or 0
    return self.parent.transform:inverseTransformPoint((x * self.tileSize), (y * self.tileSize))
end

function TileMap:registerTile(key, data)
    self.tiles[key] = {
        quad = data.quad or nil,
        shape = data.shape or nil,
        edges = data.edges or nil,
        density = data.density or 1,
        friction = data.friction or 0.25,
        restitution = data.restitution or 0,
        category = data.category or {1},
        mask = data.mask or {}
    }
end

function TileMap:getTileData(key)
    return self.tiles[key]
end

function TileMap:loadDefault()
    defaultTileMap.registerTiles(self)
end

function TileMap:draw(batch)
    local spriteBatch = self.spriteBatch
    local shapesMap = self.shapesMap
    local width = self.width
    local height = self.height
    local body = self.body
    local tileSize = self.tileSize
    local transform = self:getTransform()
    love.graphics.applyTransform(transform)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(spriteBatch, -tileSize / 2, -tileSize / 2, 0, 1)
    if _G.debugDrawPhysics then
        for i, shape in ipairs(shapesMap) do
            local shapeType = shape:getType()
            if shapeType == "polygon" then
                --[[
                    love.graphics.setColor(0.76, 0.18, 0.05, 0.5)
                    love.graphics.polygon(
                        "fill",
                        body:getWorldPoints(shape:getPoints())
                    )]]
            elseif shapeType == "edge" then
                love.graphics.setColor(0, 1, 1, 0.5)
                love.graphics.line(body:getWorldPoints(shape:getPoints()))
                love.graphics.setColor(1, 0.8, 0.5, 0.5)
                love.graphics.setPointSize(6)
                love.graphics.points(body:getWorldPoints(shape:getPoints()))
            elseif shapeType == "circle" then
                love.graphics.setColor(0.76, 0.18, 0.05, 0.5)
                love.graphics.circle("fill", body:getX(), body:getY(), shape:getRadius())
            end
        end
    end
end

return TileMap
