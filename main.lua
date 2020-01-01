local imgui = require "imgui"
local imguiStyle = require "gui-style"
love.graphics.setDefaultFilter("linear", "nearest")

local CameraClass = require "camera"
local LevelClass = require "level"
local TestingLevel = require ".levels.testing"
local input = require "input"

local level = nil

function love.load()

	imgui.Init()
	imguiStyle.load()

	level = TestingLevel()
end

function love.quit()
	imgui.ShutDown()
end

function love.update(dt)
	imgui.UseGamepad(1)
	imgui.NewFrame()
	level:update(dt)
	input.update(dt)
end

function love.draw()
	local w,
		h = love.graphics.getPixelDimensions()
	love.graphics.setBackgroundColor(colors.black)
	level.camera:dispatch()

	if showFPS then
		love.graphics.setColor(colors.white)
		love.graphics.print("FPS: " .. love.timer.getFPS(), 2, h - 16 - 2, 0, 0.5)
		love.graphics.setColor(colors.black)
		love.graphics.print("FPS: " .. love.timer.getFPS(), 3, h - 16 - 3, 0, 0.5)
	end

	if showDebugTools then
		if imgui.BeginMainMenuBar() then
			if imgui.BeginMenu("Tools") then
				showDebugTools = imgui.Checkbox("Show Debug Tools", showDebugTools)
				showGUIDemo = imgui.Checkbox("Show GUI Demo", showGUIDemo)
				showFPS = imgui.Checkbox("Show FPS", showFPS)
				imgui.EndMenu()
			end
			imgui.EndMainMenuBar()
		end
		if showGUIDemo then
			showGUIDemo = imgui.ShowDemoWindow(true)
		end
	end

	-- Very important... this effects imgui
	love.graphics.setColor(colors.white)
	imgui.Render()
end
