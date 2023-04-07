-- local imgui = require"imgui"
local Entity = require "engine.entity"
local Component = require "engine.component"
local GUIWindow = require "gui.gui-window"

local module = inheritsFrom(GUIWindow)

module.selected = nil

function module:init(parent)
	self.window = GUIWindow(parent)
end

function module:drawGUI()
	if _G.showTreeEditor then
		self.window:draw()
	end
end

--[[
function module.drawComponent(entity, component)
	imgui.PushID(imgui.GetID(tostring(component)))
	imgui.BeginGroup()
	local others = entity:getComponents(component:class())
	local name = component:getName()
	if #others > 1 then
		local index = 0
		for oi, other in ipairs(others) do
			if other == component then
				index = oi
			end
		end
		name = name .. " (" .. index .. ")"
	end
	imgui.PushStyleColor(imgui.ImGuiCol_Text, uRGB(255, 199, 93))
	local compState =
		imgui.TreeNodeEx(
			name,
			{
				"ImGuiTreeNodeFlags_None",
				"ImGuiTreeNodeFlags_OpenOnDoubleClick",
				"ImGuiTreeNodeFlags_OpenOnArrow"
			}
		)
	imgui.PopStyleColor(1)
	if compState then
		component:drawEditor()
		imgui.TreePop()
	end
	imgui.EndGroup()
	imgui.PopID()
end

function module.drawEntity(entity, depth)
	depth = depth or 1
	local entityTreeFlags =
		{
			"ImGuiTreeNodeFlags_None",
			"ImGuiTreeNodeFlags_OpenOnDoubleClick",
			"ImGuiTreeNodeFlags_OpenOnArrow"
		}
	if #entity.children == 0 and #entity.components == 0 then
		table.insert(entityTreeFlags, "ImGuiTreeNodeFlags_Bullet")
	end
	local color = RGB(0, 242, 255, 255)
	if entity:class() ~= Entity then
		--Nonestandard entity...
		color = RGB(237, 103, 58)
	end
	imgui.PushStyleColor(imgui.ImGuiCol_Text, unpack(color))
	local state = imgui.TreeNodeEx(entity.name, entityTreeFlags)
	if imgui.IsItemClicked(1) then
		module.selected = entity
	end
	imgui.PopStyleColor(1)
	if state then
		for ci, child in ipairs(entity.children) do
			module.drawEntity(child, depth + 1)
		end
		imgui.TreePop()
	end
end

function module.draw(level)
	local state =
		imgui.Begin("Tree Editor", true, { "ImGuiWindowFlags_AlwaysAutoResize" })
	if state then
		local entities = level:getRootEntities()
		imgui.BeginGroup()
		local headerState =
			imgui.TreeNodeEx(
				"Entities",
				{
					"ImGuiTreeNodeFlags_None",
					"ImGuiTreeNodeFlags_OpenOnDoubleClick",
					"ImGuiTreeNodeFlags_OpenOnArrow"
				}
			)
		if headerState then
			for ei, entity in ipairs(entities) do
				module.drawEntity(entity)
			end
			imgui.TreePop()
		end
		imgui.EndGroup()
	end
	local tx, ty = imgui.GetWindowPos()
	local tw = imgui.GetWindowWidth()

	if module.selected then
		imgui.SameLine()
		local inspectorState =
			imgui.BeginChild(
				"Inspector",
				420,
				500,
				{
					"ImGuiWindowFlags_AlwaysAutoResize",
					"ImGuiWindowFlags_NoMove",
					"ImGuiWindowFlags_NoCollapse",
					"ImGuiWindowFlags_NoFocusOnAppearing"
				}
			)
		if inspectorState then
			if module.selected:isa(Entity) then
				local entity = module.selected
				if type(entity) == "table" and entity ~= nil then
					entity:drawEditor()
					for ci, component in ipairs(entity.components) do
						module.drawComponent(entity, component)
					end
				end
			end
		end
		imgui.EndChild()
	end

	imgui.End()

	return state
end
]]
return module
