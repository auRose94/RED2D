-- local imgui = require".src.imgui"
local FileDialog = require ".src.file-dialog"
local PixelEditorWindow = {}

PixelEditorWindow.FileDialog = nil

function PixelEditorWindow:loadFile(filePath)
	echo(filePath)
end

function PixelEditorWindow:saveFile(filePath)
	echo(filePath)
end

--[[
function PixelEditorWindow:draw()
	imgui.SetNextWindowSizeConstraints(300, 300, 2000, 2000)
	local state =
		imgui.Begin("Pixel Editor", true, { "ImGuiWindowFlags_MenuBar" })
	if state then
		if imgui.BeginMenuBar() then
			if imgui.BeginMenu("File") then
				if imgui.MenuItem("Load") then
					PixelEditorWindow.FileDialog = FileDialog({
						title = "Load image",
						onFile = function(items)
							self:loadFile(items[1])
							self.FileDialog = nil
						end,
						onClose = function()
							self.FileDialog = nil
						end
					})
				end
				if imgui.MenuItem("Save") then
					PixelEditorWindow.FileDialog = FileDialog({
						title = "Save image",
						onFile = function(items)
							self:saveFile(items[1])
							self.FileDialog = nil
						end,
						onClose = function()
							self.FileDialog = nil
						end
					})
				end
				imgui.EndMenu()
			end
			imgui.EndMenuBar()
		end
	end
	imgui.End()
	if self.FileDialog then
		local fState = self.FileDialog:draw()
		if not fState then
			self.FileDialog = nil
		end
	end
	return state
end
]]
return PixelEditorWindow
