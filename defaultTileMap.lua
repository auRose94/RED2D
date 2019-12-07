
local module = {}

function StandardRect(x, y)
	return love.physics.newRectangleShape(x, y, 64, 64)
end

function TransformPoints(transform, points)
	local returnValue = {}
	local build = {}
	for _, v in ipairs(points) do
		if type(v) == "array" then
			for k,v in pairs(v) do build[k] = v end
		elseif type(v) == "number" then
			table.insert(build, v)
		end
		if #build == 2 then
			local vx, vy = transform:transformPoint(unpack(build))
			table.insert(returnValue, vx)
			table.insert(returnValue, vy)
			build = {}
		end
	end
	return returnValue
end

function SlopedSurface(x, y, angle)
	local transform = love.math.newTransform(x, y, angle, 1, 1)
	local points = TransformPoints(transform, {
		32, 32,
		32, -32,
		-32, -32
	})
	return love.physics.newPolygonShape(unpack(points))
end

function SlopedSurface1(x, y)
	return SlopedSurface(x, y, math.rad(90 * 0))
end

function SlopedSurface2(x, y)
	return SlopedSurface(x, y, math.rad(90 * 1))
end

function SlopedSurface3(x, y)
	return SlopedSurface(x, y, math.rad(90 * 2))
end

function SlopedSurface4(x, y)
	return SlopedSurface(x, y, math.rad(90 * 3))
end

function module.registerTiles(tileMap)
	tileMap:registerTile("#000000FF", {
		quad = love.graphics.newQuad(0, 1, 64, 64, 520, 520),
		shape = StandardRect,
		density = 1
	})

	tileMap:registerTile("#202020FF", {
		quad = love.graphics.newQuad(0, 65, 64, 64, 520, 520),
		shape = StandardRect,
		density = 1
	})

	tileMap:registerTile("#200000FF", {
		quad = love.graphics.newQuad(0, 196, 64, 64, 520, 520),
		shape = SlopedSurface3,
		density = 1
	})

	tileMap:registerTile("#400000FF", {
		quad = love.graphics.newQuad(0, 131, 64, 64, 520, 520),
		shape = SlopedSurface2,
		density = 1
	})

	tileMap:registerTile("#600000FF", {
		quad = love.graphics.newQuad(0, 326, 64, 64, 520, 520),
		shape = SlopedSurface1,
		density = 1
	})

	tileMap:registerTile("#800000FF", {
		quad = love.graphics.newQuad(0, 261, 64, 64, 520, 520),
		shape = SlopedSurface4,
		density = 1
	})

end

return module