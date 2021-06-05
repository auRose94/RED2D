function floatEqual(left, right, precision)
	precision = precision or 0.1
	local diff = math.abs(left - right)
	return diff < precision
end

local PathNode = inheritsFrom()
local PathMap = inheritsFrom()

function PathNode:init(x, y)
	self.x = x or 0
	self.y = y or 0
	self.neighbors = {}
end

function PathNode:chain(node, userdata)
	local distance = math.dist(self.x, self.y, node.x, node.y)
	table.insert(self.neighbors, { distance, node, userdata })
	table.insert(node.neighbors, { distance, self, userdata })
end

function PathNode:remove(node)
	local index = 0
	for i, v in ipairs(self.neighbors) do
		local d, n = unpack(v)
		if n == node then
			index = i
		end
	end
	if index ~= 0 then
		table.remove(self.neighbors, index)
	end
end

function PathNode:canFuse()
	if #self.neighbors == 2 then
		local aEdge, bEdge = unpack(self.neighbors)
		local aDist, aNode, aUserdata = unpack(aEdge)
		local bDist, bNode, bUserdata = unpack(bEdge)
		if aUserdata == bUserdata then
			return true
		end
	end
	return false
end

function PathNode:fuse()
	if #self.neighbors == 2 then
		local aEdge, bEdge = unpack(self.neighbors)
		local aDist, aNode, aUserdata = unpack(aEdge)
		local bDist, bNode, bUserdata = unpack(bEdge)
		if aUserdata == bUserdata then
			aNode:remove(self)
			bNode:remove(self)
			aNode:chain(bNode, aUserdata)
		end
	end
end

function PathMap:init()
	self.nodes = {}
end

function PathMap:getNode(x, y)
	for i, v in ipairs(self.nodes) do
		if floatEqual(v.x, x) and floatEqual(v.y, y) then
			return v
		end
	end
	return PathNode(x, y)
end

function PathMap:addEdge(x1, y1, x2, y2, userdata)
	local n1 = self:getNode(x1, y1)
	local n2 = self:getNode(x2, y2)
	n1:chain(n2, userdata)
	UniquePush(self.nodes, n1)
	UniquePush(self.nodes, n2)
end

function PathMap:simplify()
	local toRemove = {}
	for i, node in ipairs(self.nodes) do
		if node:canFuse() then
			local aEdge, bEdge = unpack(node.neighbors)
			local aDist, aNode = unpack(aEdge)
			local bDist, bNode = unpack(bEdge)
			local aDirX, aDirY = math.normalize(node.x - aNode.x, node.y - aNode.y)
			local bDirX, bDirY = math.normalize(node.x - bNode.x, node.y - bNode.y)
			if floatEqual(aDirX, -bDirX) and floatEqual(aDirY, -bDirY) then
				table.insert(toRemove, i)
			end
		end
	end
	local nodes = {}
	for i, node in ipairs(self.nodes) do
		if CheckValue(toRemove, i) then
			node:fuse()
		else
			table.insert(nodes, node)
		end
	end
	self.nodes = nodes
end

function PathMap.hasEdge(t, a, b)
	for i, chain in ipairs(t) do
		local oA, oB = unpack(chain)
		if (oA == a and oB == b) or (oB == a and oA == b) then
			return true
		end
	end
	return false
end

function PathMap:getEdges()
	local paths = {}
	for i, node in ipairs(self.nodes) do
		for n, edge in ipairs(node.neighbors) do
			local dist, other, userdata = unpack(edge)
			if not PathMap.hasEdge(paths, node, other) then
				table.insert(paths, { node, other, userdata })
			end
		end
	end
	local edges = {}
	for i, path in ipairs(paths) do
		local a, b, userdata = unpack(path)
		table.insert(edges, { a.x, a.y, b.x, b.y, userdata })
	end
	return edges
end

return PathMap