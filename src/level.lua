local CameraClass = require".src.camera"

local LevelClass = inheritsFrom(nil)

function LevelClass:addParalaxLevel(index, layer)
	self.camera:newLayer(index, layer)
end

function LevelClass:removeEntity(entity)
	for i = 1, #self.entities do
		if self.entities[i] == entity then
			table.remove(self.entities, i)
			break
		end
	end
end

function LevelClass:addEntity(entity)
	entity.level = self
	table.insert(self.entities, entity)
end

function LevelClass:update(dt)
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

function LevelClass:init()
	self.entities = {}
	love.physics.setMeter(64)
	self.world = love.physics.newWorld(0, 0, true)
	self.camera = CameraClass(self)
	self.camera:newEntityLayer(2, self.entities)
	self.accumulator = 0
end

function LevelClass:getRootEntities()
	local roots = {}
	for i, entity in ipairs(self.entities) do
		if entity.parent == nil then
			table.insert(roots, entity)
		end
	end
	return roots
end

return LevelClass