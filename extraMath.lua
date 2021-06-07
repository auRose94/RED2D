local module = {}

-- Averages an arbitrary number of angles (in radians).
function module.averageAngles(...)
	local x, y = 0, 0
	for i = 1, select("#", ...) do
		local a = select(i, ...)
		x, y = x + math.cos(a), y + math.sin(a)
	end
	return math.atan2(y, x)
end

-- Returns the distance between two points.
function module.dist(x1, y1, x2, y2)
	return ((x2 - x1) ^ 2 + (y2 - y1) ^ 2) ^ 0.5
end
-- Distance between two 3D points:
function module.dist2(x1, y1, z1, x2, y2, z2)
	return ((x2 - x1) ^ 2 + (y2 - y1) ^ 2 + (z2 - z1) ^ 2) ^ 0.5
end

function module.angle2(x1, y1, x2, y2)
	return math.atan2(x1 * y2 - y1 * x2, x1 * x2 + y1 * y2)
end

function module.angle3(x1, y1, x2, y2)
	return math.atan2(y2, x2) - math.atan2(y1, x1)
end

-- Returns the angle between two points.
function module.angle(x1, y1, x2, y2)
	return math.atan2(y2 - y1, x2 - x1)
end

-- Returns the closest multiple of 'size' (defaulting to 10).
function module.multiple(n, size)
	size = size or 10
	return math.round(n / size) * size
end

-- Clamps a number to within a certain range.
function module.clamp(low, n, high)
	return math.min(math.max(low, n), high)
end

function module.angleClamp(rad)
	local TWO_PI = math.pi * 2
	local center = math.rad(180)
	return rad - TWO_PI * math.floor((rad + math.pi - center) / TWO_PI)
end

-- Linear interpolation between two numbers.
function module.lerp(a, b, t)
	return (1 - t) * a + t * b
end
function module.lerp2(a, b, t)
	return a + (b - a) * t
end

-- Cosine interpolation between two numbers.
function module.cerp(a, b, t)
	local f = (1 - math.cos(t * math.pi)) * .5
	return a * (1 - f) + b * f
end

function module.angleLerp(a, b, t)
	local startP = math.deg(a)
	local endP = math.deg(b)
	local difference = math.abs(endP - startP)
	if difference > 180 then
		if endP > startP then
			startP = startP + 360
		else
			endP = endP + 360
		end
	end
	local value = (startP + ((endP - startP) * t))
	local rangeZero = 360
	if value >= 0 and value <= 360 then
		return math.rad(value)
	end
	return math.rad(value % rangeZero)
end

-- Normalize two numbers.
function module.normalize(x, y)
	local l = (x * x + y * y) ^ .5
	if l == 0 then
		return 0, 0, 0
	else
		return x / l, y / l, l
	end
end

-- Returns 'n' rounded to the nearest decimals (defaulting whole numbers).
function module.round(n, decimal)
	decimal = 10 ^ (decimal or 0)
	return math.floor(n * decimal + .5) / decimal
end

-- Randomly returns either -1 or 1.
function module.rSign()
	return love.math.random(2) == 2 and 1 or -1
end

-- Returns 1 if number is positive, -1 if it's negative, or 0 if it's 0.
function module.sign(n)
	return n > 0 and 1 or n < 0 and -1 or 0
end

-- Gives a precise random decimal number given a minimum and maximum
function module.pRandom(min, max)
	return love.math.random() * (max - min) + min
end

-- Checks if two line segments intersect. Line segments are given in form of ({x,y},{x,y}, {x,y},{x,y}).
function module.checkIntersect(l1p1, l1p2, l2p1, l2p2)
	local function checkDir(pt1, pt2, pt3)
		return math.sign(
			((pt2.x - pt1.x) * (pt3.y - pt1.y)) - ((pt3.x - pt1.x) * (pt2.y - pt1.y))
		)
	end
	return (checkDir(l1p1, l1p2, l2p1) ~= checkDir(
		l1p1,
		l1p2,
		l2p2
	)) and (checkDir(l2p1, l2p2, l1p1) ~= checkDir(l2p1, l2p2, l1p2))
end

-- Checks if two lines intersect (or line segments if seg is true)
-- Lines are given as four numbers (two coordinates)
function module.findIntersect(
l1p1x,
	l1p1y,
	l1p2x,
	l1p2y,
	l2p1x,
	l2p1y,
	l2p2x,
	l2p2y,
	seg1,
	seg2
)
	local a1, b1, a2, b2 =
		l1p2y - l1p1y,
		l1p1x - l1p2x,
		l2p2y - l2p1y,
		l2p1x - l2p2x
	local c1, c2 = a1 * l1p1x + b1 * l1p1y, a2 * l2p1x + b2 * l2p1y
	local det, x, y = a1 * b2 - a2 * b1
	if det == 0 then
		return false, "The lines are parallel."
	end
	x, y = (b2 * c1 - b1 * c2) / det, (a1 * c2 - a2 * c1) / det
	if seg1 or seg2 then
		local min, max = math.min, math.max
		if seg1 and not (min(l1p1x, l1p2x) <= x and x <= max(l1p1x, l1p2x) and min(
			l1p1y,
			l1p2y
		) <= y and y <= max(l1p1y, l1p2y)) or seg2 and not (min(
			l2p1x,
			l2p2x
		) <= x and x <= max(l2p1x, l2p2x) and min(l2p1y, l2p2y) <= y and y <= max(
			l2p1y,
			l2p2y
		)) then
			return false, "The lines don't intersect."
		end
	end
	return x, y
end

function module.invert(...)
	local response = {}
	for i = 1, select("#", ...) do
		table.insert(response, select(i, ...))
	end
	return unpack(response)
end

for key, value in pairs(module) do
	if type(value) == "function" and _G.math[key] == nil then
		_G.math[key] = value
	end
end

return module