--local imgui = require"imgui"
local FileDialog = inheritsFrom()

local UnixLikePath = package.config:sub(1, 1) == "/"
local Seperator = UnixLikePath and "/" or "\\"

function FileDialog:init(options)
	self.onFile = options.onFile or nil
	self.onClose = options.onClose or nil
	self.multiple = options.multiple or nil
	self.max = options.multiple and 1000 or 1
	self.size = options.size or { 200, 200 }
	self.min = 1
	self.mimeTypes = options.mimeTypes or {}
	self.selectButtonText = options.selectButtonText or "select"
	self.title = options.title or nil
	self:changePath(options.path)
	self.selected = {}
end

function FileDialog:fullPath(itemName)
	return self.currentDir .. Seperator .. itemName
end

function FileDialog:changePath(path)
	self.currentDir = path or ""
	self.items = love.filesystem.getDirectoryItems(self.currentDir)
	self.info = {}
	for index, item in ipairs(self.items) do
		local fPath = self:fullPath(item)
		local info = love.filesystem.getInfo(fPath)
		table.insert(self.info, info)
	end
end

function FileDialog:goUp()
	local path = self.currentDir
	path = path:sub(0, (path:find(Seperator.."[^"..Seperator.."]*$") or 0) - 1)
	self:changePath(path)
	return self.currentDir
end

function FileDialog:onPress(item, info)
	local itemPath = self.currentDir .. Seperator .. item
	if info.type == "file" then
		if self.multiple then
			if self.max >= #self.selected + 1 and #self.selected + 1 <= self.min then
				table.insert(self.selected, itemPath)
			end
			if self.max == #self.selected and self.min >= #self.selected then
				self:submit()
			end
		else
			if #self.selected > 0 and self.selected[1] == itemPath then
				self:submit()
			else
				self.selected[1] = itemPath
			end
		end
	elseif info.type == "directory" then
		self:changePath(itemPath)
	end
end

function FileDialog:submit()
	local items = self.selected
	if self.onFile then
		if self.multiple then
			if self.max == #items and self.min >= #items then
				self.onFile(items)
				self.onFile = nil
				imgui.CloseCurrentPopup()
			end
		elseif #items > 0 then
			self.onFile(items)
			self.onFile = nil
			imgui.CloseCurrentPopup()
		end
	end
end

--[[
function FileDialog:draw()
	local title = self.title or "Select a file path"
	assert(type(title) == "string", title .. " is an invalid title")
	imgui.SetNextWindowSizeConstraints(600, 500, 1200, 1000)
	local state = imgui.Begin(title, true, { "ImGuiWindowFlags_Modal" })
	if state then
		local width = imgui.GetWindowContentRegionWidth()
		if imgui.Button("Up") then
			self:goUp()
		end
		imgui.SameLine()
		local pathText = (self.currentDir or "")
		imgui.Text(pathText)
		imgui.BeginGroup()
		local iH = 32
		local x = 0
		local margin = 4
		for index, item in ipairs(self.items) do
			local textSize = imgui.CalcTextSize(item)
			local itemWidth = math.max(textSize+16, 32)
			local info = self.info[index]
			local color = RGB(255, 0, 128)
			if info.type == "file" then
				color = RGB(255,255,255)
			elseif info.type == "directory" then
				color = RGB(55,255,55)
			elseif info.type == "symlink" then
				color = RGB(255,255,0)
			end
			if index > 1 then
				if x + itemWidth + margin < width then
					imgui.SameLine()
				else
					x = 0
				end
			end
			imgui.PushStyleColor(imgui.ImGuiCol_Button, unpack(color))
			local press = imgui.Button(item .. "\tSomething", itemWidth, iH)
			imgui.PopStyleColor()
			x = x + itemWidth + margin

			if press then
				self:onPress(item, info)
				break
			end
		end
		imgui.EndGroup()
		if imgui.Button(self.selectButtonText) then
			self:submit()
			state = false
		end
	end
	imgui.End()

	if not state and self.onClose ~= nil then
		self.onClose()
		self.onClose = nil
	end
	return state
end
]]

return FileDialog