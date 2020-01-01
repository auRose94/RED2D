local imgui = require "imgui"
local InventoryClass = require "comp-inventory"
local ComponentClass = require "component"
local StatusWindow = inheritsFrom(ComponentClass)

function StatusWindow:getName()
	return "StatusWindow"
end

function StatusWindow:init(parent)
	ComponentClass.init(self, parent)
	self.inventory = self:getComponent(InventoryClass)
	self.player = self:getComponent(PlayerComponent or require "comp-player")

	self.showWindow = true
	self.state = {
		current = "status",
		inventory = {
			category = 1, --> Any
			sort = 1,
			selected = {}
		}
	}
end

function StatusWindow:toggleWindow()
	self.showWindow = not self.showWindow
end

function StatusWindow:draw()
	if self.showWindow then
		self.showWindow = imgui.Begin("Status", true, {"ImGuiWindowFlags_AlwaysAutoResize", "ImGuiWindowFlags_MenuBar"})

		self.showBar = imgui.BeginMenuBar()
		if self.showBar then
			if imgui.RadioButton("Status", self.state.current == "status") then
				self.state.current = "status"
			end

			if imgui.RadioButton("Inventory", self.state.current == "inventory") then
				self.state.current = "inventory"
			end

			if imgui.RadioButton("Quests", self.state.current == "quests") then
				self.state.current = "quests"
			end
			imgui.EndMenuBar()
		end

		if self.state.current == "status" then
		elseif self.state.current == "inventory" then
			self.state.inventory.category =
				imgui.Combo(
				"Category",
				self.state.inventory.category,
				{"Any", "Weapons", "Accessories", "Aid", "Tool", "Ammunition", "Junk", "Quest"},
				6
			)
			imgui.SameLine()
			self.state.inventory.sort =
				imgui.Combo(
				"Sort",
				self.state.inventory.sort,
				{
					"Name",
					"Weight",
					"Price",
					"Rarity",
					"Count"
				},
				5
			)
			if self.inventory.items then
				if imgui.ListBoxHeader("") then
					for index, v in ipairs(self.inventory.items) do
						local count, item = unpack(v)
						local name = item.name
						if count > 1 then
							name = name .. " (" .. count .. ")"
						end
						self.state.inventory.selected[index] = imgui.Selectable(name, self.state.inventory.selected[index])
					end
					imgui.ListBoxFooter()
				end
			end
		elseif self.state.current == "quests" then
		end

		imgui.End()
	end
end

return StatusWindow
