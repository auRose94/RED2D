local EntityModel = require "entity"
local defaultTileMap = require "defaultTileMap"
local TileMapClass = inheritsFrom(EntityModel)

function TileMapClass:init(level, location, tileSize)
	EntityModel.init(self, level, "TileMap("..location..")")
	self.image = love.graphics.newImage(location)
	self.image:setFilter("linear", "nearest")
	self.tileSize = tileSize
	self.tiles = {}
end

function TileMapClass:loadLevel(location)
	self.name = "Level("..location..")"
	local image = love.image.newImageData(location)
	assert(image ~= nil)
	local width = image:getWidth()
	local height = image:getHeight()
	local spriteBatch = love.graphics.newSpriteBatch(self.image, width*height)
	local physicsBody = love.physics.newBody(self.level.world, 0, 0, "static")
	local indexMap = {}
	local fixtureMap = {}
	local shapeMap = {}
	local size = self.tileSize

	for i = 0, width-1 do
		for j = 0, height-1 do
			local index = j * width + i
			local r, g, b, a = image:getPixel(i, j)
			r = math.ceil(r * 255)
			g = math.ceil(g * 255)
			b = math.ceil(b * 255)
			a = math.ceil(a * 255)
			if a ~= 0 then
				local key = convert2HEX(r, g, b, a)
				local data = self:getTileData(key)
				if data then
					if data.quad then
						indexMap[index] = spriteBatch:add(
							data.quad,
							(i * size),
							(j * size),
							0,
							1)
					end
					if data.shape then
						local shape = data.shape(i * size, j * size)
						shapeMap[index] = shape
						local fixture = love.physics.newFixture(
							physicsBody,
							shape,
							data.density)
						fixture:setFriction(data.friction)
						fixture:setRestitution(data.restitution)
						if #data.catagory > 0 then
							fixture:setCategory(unpack(data.catagory))
						end
						if #data.mask > 0 then
							fixture:setMask(unpack(data.mask))
						end
						fixtureMap[index] = fixture
					end
				else
					print(key .. " Missing from Tilemap on ", i, j)
				end
			end
		end
	end
	spriteBatch:flush()
	self.spriteBatch = spriteBatch
	self.indexMap = indexMap
	self.fixtureMap = fixtureMap
	self.shapeMap = shapeMap
	self.body = physicsBody
	self.width = width
	self.height = height
end

function TileMapClass:getOffset(x, y)
	return
		self.transform:inverseTransformPoint(
			(x * self.tileSize),
			(y * self.tileSize)
		)
end

function TileMapClass:registerTile(key, data)
	self.tiles[key] = {
		quad = data.quad or nil,
		shape = data.shape or nil,
		density = data.density or 1,
		friction = data.friction or 0.25,
		restitution = data.restitution or 0,
		catagory = data.catagory or {1},
		mask = data.mask or {}
	}
end

function TileMapClass:getTileData(key)
	return self.tiles[key]
end

function TileMapClass:loadDefault()
	defaultTileMap.registerTiles(self)
end

function TileMapClass:draw()
	local spriteBatch = self.spriteBatch
	local shapeMap = self.shapeMap
	local width = self.width
	local height = self.height
	local body = self.body
	local tileSize = self.tileSize
	local transform = self:getTransform()

	love.graphics.applyTransform(transform)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(spriteBatch, -tileSize/2, -tileSize/2, 0, 1)
	if _G.debugDrawPhysics then
		for ix = 0, width-1 do
			for iy = 0, height-1 do
				love.graphics.setColor(0.76, 0.18, 0.05, 0.5)
				local shape = shapeMap[iy * width + ix]
				if shape then
					if shape:getType() == "polygon" then
						love.graphics.polygon(
							"fill",
							body:getWorldPoints(shape:getPoints()))
					else
						love.graphics.circle(
							"fill",
							body:getX(),
							body:getY(),
							shape:getRadius())
					end
				end
			end
		end
	end
end

return TileMapClass