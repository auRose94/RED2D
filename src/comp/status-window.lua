-- local imgui = require"imgui"
local Inventory = require "comp.inventory"
local Component = require "component"
local Element = require "element"
local Button = require "elem-button"
local Text = require "elem-text"
local Scroll = require "elem-scroll"
local Window = require "gui-window"
local StatusWindow = inheritsFrom(Component)

local CategoryNames = {"Any", "Weapons", "Accessories", "Aid", "Tool", "Ammunition", "Junk", "Quest"}
local SortNames = {"Name", "Weight", "Price", "Rarity", "Count"}

function StatusWindow:getName()
    return "StatusWindow"
end

function StatusWindow:init(parent)
    Component.init(self, parent)
    self.inventory = self:getComponent(Inventory)
    local PlayerComponent = _G.PlayerComponent or require "comp.player"
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
    local window =
        Window(
        self.parent,
        {
            width = 274,
            height = 125,
            x = -295,
            y = -100,
            title = "Status"
        }
    )
    self.window = window
    self.scrollWidth = self.window.width / 2
    self.scrollHeight = self.window.height - 24

    self:createOptionsBar()

    self:createInfoSection()
    self:createItemSection()
    self:createQuestSection()

    self:createItemSelectedSection()

    self:regenQuest()
    self:regenItems()
    self:regenInfo()
end

function StatusWindow:createOptionsBar()
    local inc = self.window.width / 3
    self.infoButton =
        Button(
        "Info",
        {
            x = inc * 0,
            width = inc,
            disabled = self.state.selected == 1,
            callback = function()
                self:changeTab(1)
                self:regenInfo()
            end
        }
    )
    self.itemButton =
        Button(
        "Items",
        {
            x = inc * 1,
            width = inc,
            disabled = self.state.selected == 2,
            callback = function()
                self:changeTab(2)
                self:regenItems()
            end
        }
    )
    self.questButton =
        Button(
        "Quests",
        {
            x = inc * 2,
            width = inc,
            disabled = self.state.selected == 3,
            callback = function()
                self:changeTab(3)
                self:regenQuest()
            end
        }
    )
    self.optionsBar =
        Element(
        {
            height = 16,
            width = self.window.width
        },
        self.infoButton,
        self.itemButton,
        self.equipButton,
        self.questButton
    )
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
    self.questSection.hide = true
    if tab == 1 then
        self.infoSection.hide = false
    elseif tab == 2 then
        self.itemSection.hide = false
    elseif tab == 3 then
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
        height = self.window.height - 24
    }
end

function StatusWindow:updateEverything()
    self:createOptionsBar()

    self:createInfoSection()
    self:createItemSection()
    self:createQuestSection()

    self:createItemSelectedSection()

    self:regenQuest()
    self:regenItems()
    self:regenInfo()
end

function StatusWindow:createInfoSection()
    self.infoScroll = Scroll(self:getScrollConfig())

    self.infoSection =
        Element(
        self.infoScroll,
        self:getSectionConfig(),
        {
            hide = self.state.selected == 0
        }
    )
    self.window:addElement(self.infoSection)
end

function StatusWindow:createItemSection()
    self.itemScroll = Scroll(self:getScrollConfig())

    self.itemSection =
        Element(
        self.itemScroll,
        self:getSectionConfig(),
        {
            hide = self.state.selected == 1
        }
    )
    self.window:addElement(self.itemSection)
end

function StatusWindow:createQuestSection()
    self.questScroll = Scroll(self:getScrollConfig())

    self.questSection =
        Element(
        self.questScroll,
        self:getSectionConfig(),
        {
            hide = self.state.selected == 2
        }
    )
    self.window:addElement(self.questSection)
end

function StatusWindow:selectItem(index)
    if type(index) == "table" then
        index =
            findFirstIndexOf(
            self.inventory.items,
            function(v, i)
                local count, vItem = unpack(v)
                return vItem == index
            end
        )
    end
    index = math.min(math.max(1, index), #self.inventory.items + 1)
    local count, item = unpack(self.inventory.items[index])
    self.state.inventory.selected = index
    self.itemDescription:updateText(item.description)
    self.useButton.disabled = not item:canInteract()
    self.equipButton.disabled = not item:canEquip()
    self.dropButton.disabled = not item:canDrop()
end

function StatusWindow:createItemSelectedSection()
    local buttonConfig = {
        width = self.scrollWidth,
        x = 0
    }

    self.useButton =
        Button(
        "Use",
        buttonConfig,
        {
            callback = function()
                local pair = self.inventory.items[self.state.inventory.selected]
                if (pair) then
                    local count, item = unpack(pair)
                    if item:canInteract() then
                        item:use(self.player)
                        self:regenItems()
                    end
                end
            end
        }
    )
    self.equipButton =
        Button(
        "Equip",
        buttonConfig,
        {
            callback = function()
                local pair = self.inventory.items[self.state.inventory.selected]
                if pair then
                    local count, item = unpack(pair)
                    if item:canEquip() then
                        item:equip(self.player)
                    end
                end
            end
        }
    )
    self.dropButton =
        Button(
        "Drop",
        buttonConfig,
        {
            callback = function()
                local pair = self.inventory.items[self.state.inventory.selected]
                if (pair) then
                    local count, item = unpack(pair)
                    if item:canDrop() then
                        self:selectItem(self.state.inventory.selected - 1)
                        self.inventory:drop(item, count)
                        self:regenItems()
                    end
                end
            end
        }
    )
    self.itemDescription =
        Text(
        "Item Description",
        {
            maxWidth = 262
        }
    )
    self.selectScroll =
        Scroll(self:getScrollConfig(), self.useButton, self.equipButton, self.dropButton, self.itemDescription)

    self.selectSection =
        Element(
        self.selectScroll,
        self:getSectionConfig(),
        {
            width = self.scrollWidth,
            hide = self.state.inventory.selected == 0,
            x = self.scrollWidth
        }
    )

    self.itemSection:addElement(self.selectSection)
end

function StatusWindow:onSubtract(item)
    self:regenItems()
end

function StatusWindow:onPickUp(item)
    local id =
        findFirstIndexOf(
        self.inventory.items,
        function(v, i)
            local count, vItem = unpack(v)
            return vItem == item
        end
    )
    self:selectItem(id)
    self:regenItems()
end

function StatusWindow:regenItems()
    self.itemScroll:clearElements()
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
            self:selectItem(button.id)
            self.itemDescription:updateText(button.item.description)
            self.selectScroll.scrollY = 0
        end

        local elem =
            Button(
            name,
            {
                width = width,
                maxWidth = width,
                fontScale = 0.35,
                callback = ItemSelected,
                item = item,
                count = count,
                id = i,
                disabled = self.state.inventory.selected == i
            }
        )
        self.itemScroll:addElement(elem)
    end
end

function StatusWindow:regenInfo()
    self.infoScroll:clearElements()
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
    self.infoScroll:addElement(
        Button(
            "Health",
            coreButtonConfig,
            {
                id = 1,
                disabled = self.state.info.selected == 1,
                callback = infoCallback
            }
        )
    )
    self.infoScroll:addElement(
        Button(
            "Stats",
            coreButtonConfig,
            {
                id = 2,
                disabled = self.state.info.selected == 2,
                callback = infoCallback
            }
        )
    )
    self.infoScroll:addElement(
        Button(
            "Log",
            coreButtonConfig,
            {
                id = 3,
                disabled = self.state.info.selected == 3,
                callback = infoCallback
            }
        )
    )
    self.healthSection = Element("Health Section")
    self.statsSection = Element("Stats Section")
    self.logSection = Element("Log Section")
end

function StatusWindow:regenQuest()
    self.questScroll:clearElements()
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
