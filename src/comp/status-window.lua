-- local imgui = require".src.imgui"
local InventoryClass = require ".src.comp.inventory"
local ComponentClass = require ".src.component"
local Element = require ".src.element"
local Button = require ".src.elem-button"
local Scroll = require ".src.elem-scroll"
local WindowClass = require ".src.gui-window"
local StatusWindow = inheritsFrom(ComponentClass)

local CategoryNames = {"Any", "Weapons", "Accessories", "Aid", "Tool", "Ammunition", "Junk", "Quest"}
local SortNames = {"Name", "Weight", "Price", "Rarity", "Count"}

function StatusWindow:getName()
    return "StatusWindow"
end

function StatusWindow:init(parent)
    ComponentClass.init(self, parent)
    self.inventory = self:getComponent(InventoryClass)
    local PlayerComponent = _G.PlayerComponent or require ".src.comp.player"
    self.player = self:getComponent(PlayerComponent)

    self.state = {
        selected = 1,
        info = {
            selected = 1
        },
        inventory = {
            category = 1, -- > Any
            sort = 1,
            selected = 1,
            showItemTabs = 1
        }
    }
    local window = WindowClass(self.parent, {
        parent = self.parent,
        width = 274,
        height = 125,
        x = -295,
        y = -100,
        title = "Status"
    })
    self.window = window
    self.scrollWidth = self.window.width / 2
    self.scrollHeight = 16 * 6

    self:createOptionsBar()

    self:createInfoSection()
    self:createItemSection()
    self:createEquipSection()
    self:createQuestSection()

    self:regenQuest()
    self:regenEquip()
    self:regenItems()
    self:regenInfo()
end

function StatusWindow:createOptionsBar()
    local inc = self.window.width / 4
    self.infoButton = Button("Info", {
        x = inc * 0,
        width = inc,
        disabled = self.state.selected == 1,
        callback = function()
            self:changeTab(1)
            self:regenInfo()
        end
    })
    self.itemButton = Button("Items", {
        x = inc * 1,
        width = inc,
        disabled = self.state.selected == 2,
        callback = function()
            self:changeTab(2)
            self:regenItems()

        end
    })
    self.equipButton = Button("Equip", {
        x = inc * 2,
        width = inc,
        disabled = self.state.selected == 3,
        callback = function()
            self:changeTab(3)
            self:regenEquip()
        end
    })
    self.questButton = Button("Quests", {
        x = inc * 3,
        width = inc,
        disabled = self.state.selected == 4,
        callback = function()
            self:changeTab(4)
            self:regenQuest()
        end
    })
    self.optionsBar = Element({
        height = 16,
        width = self.window.width
    }, self.infoButton, self.itemButton, self.equipButton, self.questButton)
    self.window:addElement(self.optionsBar)

end

function StatusWindow:changeTab(tab)
    local last = self.optionsBar.elements[self.state.selected]
    local button = self.optionsBar.elements[tab]
    if last ~= nil then
        last.disabled = false
    end
    button.disabled = true
    self.state.selected = tab
    self.infoSection.hide = true
    self.itemSection.hide = true
    self.equipSection.hide = true
    self.questSection.hide = true
    if tab == 1 then
        self.infoSection.hide = false
    elseif tab == 2 then
        self.itemSection.hide = false
    elseif tab == 3 then
        self.equipSection.hide = false
    elseif tab == 4 then
        self.questSection.hide = false
    end
end

function StatusWindow:getScrollConfig()
    return {
        width = self.scrollWidth,
        height = self.scrollHeight,
        y = 16
    }
end

function StatusWindow:getSectionConfig()
    return {
        width = self.window.width,
        height = self.window.height - 32
    }
end

function StatusWindow:updateEverything()
    self:createOptionsBar()

    self:createInfoSection()
    self:createItemSection()
    self:createEquipSection()
    self:createQuestSection()

    self:regenQuest()
    self:regenEquip()
    self:regenItems()
    self:regenInfo()
end

function StatusWindow:createInfoSection()

    self.infoScroll = Scroll(self:getScrollConfig())

    self.infoSection = Element(self.infoScroll, self:getSectionConfig(), {
        hide = self.state.selected == 0
    })
    self.window:addElement(self.infoSection)
end

function StatusWindow:createItemSection()

    self.itemScroll = Scroll(self:getScrollConfig())

    self.itemSection = Element(self.itemScroll, self:getSectionConfig(), {
        hide = self.state.selected == 1
    })
    self.window:addElement(self.itemSection)
end

function StatusWindow:createEquipSection()
    self.equipScroll = Scroll(self:getScrollConfig())

    self.equipSection = Element(self.equipScroll, self:getSectionConfig(), {
        hide = self.state.selected == 2
    })
    self.window:addElement(self.equipSection)
end

function StatusWindow:createQuestSection()

    self.questScroll = Scroll(self:getScrollConfig())

    self.questSection = Element(self.questScroll, self:getSectionConfig(), {
        hide = self.state.selected == 3
    })
    self.window:addElement(self.questSection)
end

function StatusWindow:onPickUp(item)
    local id = findFirstIndexOf(self.inventory.items, function(v, i)
        local count, vItem = unpack(v)
        return vItem == item
    end)
    self.state.inventory.selected = id
end

function StatusWindow:regenItems()
    self.itemScroll.elements = {}
    local width = self.window.width / 2
    for i, v in ipairs(self.inventory.items) do
        local count, item = unpack(v)
        local name = item.name
        if count > 1 then
            name = name .. " (" .. count .. ")"
        end

        function ItemSelected(button)
            local last = self.itemScroll.elements[self.state.inventory.selected]
            if last ~= nil then
                last.disabled = false
            end
            button.disabled = true
            self.state.inventory.selected = button.id
        end

        local elem = Button(name, {
            width = width,
            maxWidth = width,
            fontScale = 0.35,
            callback = ItemSelected,
            item = item,
            count = count,
            id = i,
            disabled = self.state.inventory.selected == i
        })
        self.itemScroll:addElement(elem)
    end
end

function StatusWindow:regenInfo()
    self.infoScroll.elements = {}
    local width = self.window.width / 2
    local coreButtonConfig = {
        fontScale = 0.35,
        width = width,
        maxWidth = width
    }
    function infoCallback(button)
        local last = self.infoScroll.elements[self.state.info.selected]
        if last then
            last.disabled = false
        end
        self.state.info.selected = button.id
        button.disabled = true
    end
    self.infoScroll:addElement(Button("Health", coreButtonConfig, {
        id = 1,
        disabled = self.state.info.selected == 1,
        callback = infoCallback
    }))
    self.infoScroll:addElement(Button("Stats", coreButtonConfig, {
        id = 2,
        disabled = self.state.info.selected == 2,
        callback = infoCallback
    }))
    self.infoScroll:addElement(Button("Log", coreButtonConfig, {
        id = 3,
        disabled = self.state.info.selected == 3,
        callback = infoCallback
    }))
    self.healthSection = Element("Health Section")
    self.statsSection = Element("Stats Section")
    self.logSection = Element("Log Section")
end

function StatusWindow:regenEquip()
    self.equipScroll.elements = {}
end

function StatusWindow:regenQuest()
    self.questScroll.elements = {}
end

function StatusWindow:toggleWindow()
    if not self.window.show then
        self.justOpened = true
    end
    self.window.show = not self.window.show
end

function StatusWindow:update()
    self.justOpened = false
    local trans = self:getTransform()
    trans = trans:inverse()
    local x, y = trans:inverseTransformPoint(0, 0)
    -- self.windowObject:setPosition(x, y)
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
