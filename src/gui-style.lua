-- Setup GUI Style
local module = {}
--local imgui = require".src.imgui"

local font = love.graphics.newFont("assets/unifont.ttf", 32, "mono")
font:setFilter("linear", "nearest", 0)
module.font = font

function module.load()
	love.graphics.setFont(font)

	imgui.SetStyleColorV4(imgui.ImGuiCol_TabActive, 0.00, 0.44, 1.00, 1.00)
	imgui.SetStyleColorV4(imgui.ImGuiCol_TabHovered, 0.26, 0.42, 0.98, 0.80)
	imgui.SetStyleColorV4(imgui.ImGuiCol_Tab, 0.00, 0.07, 0.79, 0.86)
	imgui.SetStyleColorV4(imgui.ImGuiCol_ResizeGripActive, 0.44, 0.26, 0.98, 0.95)
	imgui.SetStyleColorV4(
		imgui.ImGuiCol_ResizeGripHovered,
		0.26,
		0.98,
		0.87,
		0.67
	)
	imgui.SetStyleColorV4(imgui.ImGuiCol_ResizeGrip, 0.29, 0.26, 0.98, 0.25)
	imgui.SetStyleColorV4(imgui.ImGuiCol_SeparatorActive, 0.01, 0.00, 1.00, 1.00)
	imgui.SetStyleColorV4(imgui.ImGuiCol_SeparatorHovered, 0.01, 0.00, 1.00, 0.78)
	imgui.SetStyleColorV4(imgui.ImGuiCol_Separator, 1.00, 1.00, 1.00, 0.50)
	imgui.SetStyleColorV4(imgui.ImGuiCol_HeaderActive, 0.98, 0.31, 0.26, 1.00)
	imgui.SetStyleColorV4(imgui.ImGuiCol_HeaderHovered, 0.98, 0.10, 0.10, 0.80)
	imgui.SetStyleColorV4(imgui.ImGuiCol_Header, 1.00, 0.07, 0.00, 0.45)
	imgui.SetStyleColorV4(imgui.ImGuiCol_ButtonActive, 0.98, 0.06, 0.30, 1.00)
	imgui.SetStyleColorV4(imgui.ImGuiCol_ButtonHovered, 0.98, 0.26, 0.50, 1.00)
	imgui.SetStyleColorV4(imgui.ImGuiCol_Button, 1.00, 0.00, 0.46, 0.40)
	imgui.SetStyleColorV4(imgui.ImGuiCol_SliderGrabActive, 0.98, 0.86, 0.26, 1.00)
	imgui.SetStyleColorV4(imgui.ImGuiCol_SliderGrab, 0.88, 0.79, 0.24, 1.00)
	imgui.SetStyleColorV4(imgui.ImGuiCol_CheckMark, 0.98, 0.90, 0.26, 1.00)
	imgui.SetStyleColorV4(
		imgui.ImGuiCol_ScrollbarGrabActive,
		0.00,
		0.91,
		0.90,
		1.00
	)
	imgui.SetStyleColorV4(
		imgui.ImGuiCol_ScrollbarGrabHovered,
		1.00,
		0.43,
		0.00,
		1.00
	)
	imgui.SetStyleColorV4(imgui.ImGuiCol_ScrollbarGrab, 0.81, 1.00, 0.00, 1.00)
	imgui.SetStyleColorV4(imgui.ImGuiCol_ScrollbarBg, 0.97, 0.48, 0.00, 0.09)
	imgui.SetStyleColorV4(imgui.ImGuiCol_MenuBarBg, 0.45, 0.00, 0.18, 1.00)
	imgui.SetStyleColorV4(imgui.ImGuiCol_TitleBgCollapsed, 1.00, 0.00, 0.00, 0.51)
	imgui.SetStyleColorV4(imgui.ImGuiCol_TitleBgActive, 1.00, 0.00, 0.27, 1.00)
	imgui.SetStyleColorV4(imgui.ImGuiCol_TitleBg, 0.64, 0.00, 0.19, 1.00)
	imgui.SetStyleColorV4(imgui.ImGuiCol_FrameBgActive, 0.98, 0.26, 0.49, 0.67)
	imgui.SetStyleColorV4(imgui.ImGuiCol_FrameBgHovered, 0.98, 0.26, 0.74, 0.39)
	imgui.SetStyleColorV4(imgui.ImGuiCol_FrameBg, 0.00, 0.48, 0.39, 0.55)
	imgui.SetStyleColorV4(imgui.ImGuiCol_BorderShadow, 0.00, 0.02, 1.00, 0.00)
	imgui.SetStyleColorV4(imgui.ImGuiCol_Border, 0.00, 1.00, 0.98, 0.50)
	imgui.SetStyleColorV4(imgui.ImGuiCol_PopupBg, 0.27, 0.28, 0.15, 1.00)
	imgui.SetStyleColorV4(imgui.ImGuiCol_ChildBg, 0.28, 0.15, 0.26, 0.78)
	imgui.SetStyleColorV4(imgui.ImGuiCol_WindowBg, 0.23, 0.12, 0.28, 0.78)
	imgui.SetStyleColorV4(imgui.ImGuiCol_TextDisabled, 0.39, 0.39, 0.39, 1.00)
	imgui.SetStyleColorV4(imgui.ImGuiCol_Text, 0.00, 0.95, 1.00, 1.00)
	imgui.SetStyleColorV4(imgui.ImGuiCol_TextSelectedBg, 0.14, 0.16, 0.00, 1.00)

	imgui.SetStyleValue("WindowRounding", 0)
	imgui.SetStyleValue("WindowBorderSize", 0)
	imgui.SetStyleValue("WindowPadding", 10, 10)
	imgui.SetStyleValue("ChildRounding", 0)
	imgui.SetStyleValue("ChildBorderSize", 0)
	imgui.SetStyleValue("PopupRounding", 0)
	imgui.SetStyleValue("PopupBorderSize", 0)
	imgui.SetStyleValue("FrameRounding", 0)
	imgui.SetStyleValue("FramePadding", 8, 4)
	imgui.SetStyleValue("ItemSpacing", 4, 4)
	imgui.SetStyleValue("ItemInnerSpacing", 4, 4)
	imgui.SetStyleValue("IndentSpacing", 16)
	imgui.SetStyleValue("ScrollbarSize", 16)
	imgui.SetStyleValue("GrabMinSize", 8)
	imgui.SetStyleValue("FrameBorderSize", 0)
	imgui.SetStyleValue("ScrollbarRounding", 0)
	imgui.SetStyleValue("GrabRounding", 0)
	imgui.SetStyleValue("TabRounding", 0)
	imgui.SetStyleValue("AntiAliasedLines", 1)
	imgui.SetStyleValue("AntiAliasedFill", 1)

	--imgui.SetGlobalFontFromFileTTF("assets/unifont.ttf", 32, 0, 0, 0, 0)
end

return module