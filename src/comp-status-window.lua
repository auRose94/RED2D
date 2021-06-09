--local imgui = require".src.imgui"
local InventoryClass = require".src.comp-inventory"
local ComponentClass = require".src.component"
local WindowClass = require ".src.gui-window"
local StatusWindow = inheritsFrom(ComponentClass)

local CategoryNames =
	{
		"Any",
		"Weapons",
		"Accessories",
		"Aid",
		"Tool",
		"Ammunition",
		"Junk",
		"Quest"
	}
local SortNames = { "Name", "Weight", "Price", "Rarity", "Count" }

function StatusWindow:getName()
	return "StatusWindow"
end

function StatusWindow:init(parent)
	ComponentClass.init(self, parent)
	self.inventory = self:getComponent(InventoryClass)
	self.player = self:getComponent(PlayerComponent or require".src.comp-player")

	self.state = {
		inventory = {
			category = 1, -- > Any
			sort = 1,
			selected = nil,
			showItemTabs = 1
		}
	}
	--self.windowObject = EntityClass(parent.level, "Status Window", 0, 0)
	self.window = WindowClass(self.parent)
end

function StatusWindow:toggleWindow()
	if not self.window.show then
		self.justOpened = true	
	end
	self.window.show = not self.window.show
end

function StatusWindow:selectItem(item)
	self.state.inventory.selected = item
end

function StatusWindow:update()
	self.justOpened = false
	local trans = self:getTransform()
	trans = trans:inverse()
	local x, y = trans:inverseTransformPoint(0, 0)
	--self.windowObject:setPosition(x, y)
end

--[[
function StatusWindow:draw()
	if self.showWindow then
		if self.justOpened then
			self.justOpened = nil
			imgui.SetNextWindowFocus()
		end
		self.showWindow =
			imgui.Begin("Status", true, { "ImGuiWindowFlags_AlwaysAutoResize" })

		if imgui.BeginTabBar("Status") then
			if imgui.BeginTabItem("Status") then
				imgui.EndTabItem()
			end

			if imgui.BeginTabItem("Inventory") then
				imgui.BeginGroup()
				imgui.BeginGroup()
				imgui.PushID("Category")
				imgui.SetNextItemWidth(208)
				self.state.inventory.category =
					imgui.Combo(
						"",
						self.state.inventory.category,
						CategoryNames,
						#CategoryNames
					)
				imgui.PopID()
				imgui.PushID("Sort")
				imgui.SetNextItemWidth(208)
				self.state.inventory.sort =
					imgui.Combo("", self.state.inventory.sort, SortNames, #SortNames)
				imgui.PopID()
				imgui.EndGroup()

				if self.inventory.items then
					imgui.BeginGroup()
					imgui.PushID("Items")
					if imgui.ListBoxHeader("", #self.inventory.items) then
						for index, v in ipairs(self.inventory.items) do
							local count, item = unpack(v)
							local name = item.name
							if count > 1 then
								name = name .. " (" .. count .. ")"
							end
							local selected =
								imgui.Selectable(name, self.state.inventory.selected == item)
							if selected then
								self:selectItem(item)
								self.state.inventory.dropDialog = false
							end
						end
						imgui.ListBoxFooter()
					end
					imgui.PopID()
					imgui.EndGroup()
				end
				imgui.EndGroup()

				imgui.SameLine()
				imgui.BeginGroup()
				imgui.PushID("ItemBar")
				imgui.AlignTextToFramePadding(0)
				if self.state.inventory.selected ~= nil then
					local item = self.state.inventory.selected
					imgui.BeginGroup()
					if item:canEquip() then
						if imgui.Button("Equip") then
							item:equip(self.player)
						end
						imgui.SameLine()
					end
					if item:canInteract() then
						if imgui.Button("Use") then
							item:use(self.inventory)
						end
						imgui.SameLine()
					end
					if item:canDrop() then
						if imgui.Button("Drop") then
							if item.count > 1 then
								self.state.inventory.dropCount = 1
								self.state.inventory.dropDialog = true
							else
								self:selectItem(nil)
								self.inventory:drop(item, 1)
							end
						end
						imgui.SameLine()
					end
					imgui.NewLine()
					imgui.EndGroup()
					local xOffset = imgui.GetItemRectSize()
					if imgui.BeginTabBar("ItemBar") then
						if imgui.BeginTabItem("Description") then
							imgui.PushTextWrapPos(xOffset + 500)
							imgui.TextWrapped(item.description)

							imgui.EndTabItem()
						end

						if imgui.BeginTabItem("Stats") then
							item:drawStats()
							imgui.EndTabItem()
						end
						imgui.EndTabBar()
					end
				else
					imgui.Text("Select an item first...")
				end
				imgui.PopID()
				imgui.EndGroup()

				imgui.EndTabItem()
			end

			if imgui.BeginTabItem("Quests") then
				imgui.EndTabItem()
			end
			imgui.EndTabBar()
		end
		imgui.End()
	end

	if self.state.inventory.dropDialog and self.state.inventory.selected then
		local item = self.state.inventory.selected
		self.state.inventory.dropDialog =
			imgui.Begin("Drop items", true, { "ImGuiWindowFlags_AlwaysAutoResize" })
		if self.state.inventory.dropDialog then
			local count = imgui.InputInt("Count", self.state.inventory.dropCount)
			count = math.max(1, math.min(item.count, count))
			self.state.inventory.dropCount = count
			if imgui.Button("Drop") and count >= 1 then
				self:selectItem(nil)
				self.inventory:drop(item, count)
			end
			imgui.End()
		end
	end
end
]]

return StatusWindow