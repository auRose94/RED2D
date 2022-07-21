local Component = require "component"
local defaultPaternGenerator = require "defaultPaternGenerator"
local PathMap = require "path-map"
local ROT = require "rot"
local PaternGenerator = inheritsFrom(Component)

function UniquePush(t, value)
  if not CheckValue(t, value) then
    table.insert(t, value)
  end
end

function PaternGenerator:init(parent, ...)
  Component.init(self, parent, ...)
  self.tiles = self.tiles or {}
  self.data = self.data or {}
end

function PaternGenerator:loadDefault()
  defaultPaternGenerator.registerTiles(self)
end

return PaternGenerator
