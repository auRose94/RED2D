local module = {}

function StandardEdgesRect(x, y)
	return {
		{ x + -32, y + -32, x + -32, y + 32 },
		{ x + -32, y + 32, x + 32, y + 32 },
		{ x + 32, y + 32, x + 32, y + -32 },
		{ x + 32, y + -32, x + -32, y + -32 }
	}
end

function StandardRect(x, y)
	return love.physics.newRectangleShape(x, y, 64, 64)
end

function TransformPoints(transform, points)
	local returnValue = {}
	local build = {}
	for _, v in ipairs(points) do
		local tv = type(v)
		if tv == "table" then
			for k, av in pairs(v) do
				build[k] = av
			end
		elseif tv == "number" then
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

function SlopedSurfaceEdge(x, y, angle)
	local transform = love.math.newTransform(x, y, angle, 1, 1)
	local points = TransformPoints(
		transform,
		{
			{ 32, 32 }, -- Edge 1
			{ 32, -32 },
			{ 32, -32 }, -- Edge 2
			{ -32, -32 },
			{ -32, -32 }, -- Edge 3
			{ 32, 32 }
		}
	)
	local edges = {}
	for i = 1, #points, 4 do
		table.insert(
			edges,
			{ points[i + 0], points[i + 1], points[i + 2], points[i + 3] }
		)
	end
	return edges
end

function SlopedSurfaceShape(x, y, angle)
	local transform = love.math.newTransform(x, y, angle, 1, 1)
	local points = TransformPoints(transform, { 32, 32, 32, -32, -32, -32 })
	return love.physics.newPolygonShape(unpack(points))
end

function SlopedSurfaceEdges0(x, y)
	return SlopedSurfaceEdge(x, y, math.rad(90 * 0))
end

function SlopedSurfaceEdges90(x, y)
	return SlopedSurfaceEdge(x, y, math.rad(90 * 1))
end

function SlopedSurfaceEdges180(x, y)
	return SlopedSurfaceEdge(x, y, math.rad(90 * 2))
end

function SlopedSurfaceEdges270(x, y)
	return SlopedSurfaceEdge(x, y, math.rad(90 * 3))
end

function SlopedSurfaceShape0(x, y)
	return SlopedSurfaceShape(x, y, math.rad(90 * 0))
end

function SlopedSurfaceShape90(x, y)
	return SlopedSurfaceShape(x, y, math.rad(90 * 1))
end

function SlopedSurfaceShape180(x, y)
	return SlopedSurfaceShape(x, y, math.rad(90 * 2))
end

function SlopedSurfaceShape270(x, y)
	return SlopedSurfaceShape(x, y, math.rad(90 * 3))
end

function module.registerTiles(tileMap)
	tileMap:registerTile("#FFFFFFFF", {
		quad = love.graphics.newQuad(64, 1, 64, 64, 520, 520),
		--edges = StandardEdgesRect,
		density = 1
	})

	tileMap:registerTile("#000000FF", {
		quad = love.graphics.newQuad(0, 1, 64, 64, 520, 520),
		edges = StandardEdgesRect,
		density = 1
	})

	tileMap:registerTile("#202020FF", {
		quad = love.graphics.newQuad(0, 65, 64, 64, 520, 520),
		edges = StandardEdgesRect,
		density = 1
	})

	tileMap:registerTile("#200000FF", {
		quad = love.graphics.newQuad(0, 196, 64, 64, 520, 520),
		edges = SlopedSurfaceEdges180,
		density = 1
	})

	tileMap:registerTile("#400000FF", {
		quad = love.graphics.newQuad(0, 131, 64, 64, 520, 520),
		edges = SlopedSurfaceEdges90,
		density = 1
	})

	tileMap:registerTile("#600000FF", {
		quad = love.graphics.newQuad(0, 326, 64, 64, 520, 520),
		edges = SlopedSurfaceEdges0,
		density = 1
	})

	tileMap:registerTile("#800000FF", {
		quad = love.graphics.newQuad(0, 261, 64, 64, 520, 520),
		edges = SlopedSurfaceEdges270,
		density = 1
	})
end

return module