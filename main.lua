local imgui = require"imgui"
local imguiStyle = require"gui-style"
love.graphics.setDefaultFilter("linear", "nearest")

local CameraClass = require"camera"
local LevelClass = require"level"
local TestingLevel = require".levels.testing"
local input = require"input"
local EditorWindow = require"tree-editor-window"
local PixelEditorWindow = require"pixel-editor-window"

local level = nil
local accumulator = 0

function love.load()
	imgui.Init()
	imguiStyle.load()
	level = TestingLevel()
end

function love.quit()
	imgui.ShutDown()
end

function love.update(dt)
	local joysticks = love.joystick.getJoysticks()
	local joystick = joysticks[1]
	local right, left, down, up =
		math.max(joystick:getGamepadAxis('leftx'),0),
		math.abs(math.min(joystick:getGamepadAxis('leftx'),0)),
		math.abs(math.min(joystick:getGamepadAxis('lefty'),0)),
		math.max(joystick:getGamepadAxis('lefty'),0)
	echo(right, left, down, up)

	imgui.UseGamepad(1)
	imgui.NewFrame()
	level:update(dt)
	input.update(dt)
	collectgarbage()
end

function love.draw()
	local w, h = love.graphics.getPixelDimensions()
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
				debugDrawPhysics =
					imgui.Checkbox("Show debug physics", debugDrawPhysics)
				showPixelEditor = imgui.Checkbox("Show Pixel Editor", showPixelEditor)
				showTreeEditor = imgui.Checkbox("Show Tree Editor", showTreeEditor)
				showDebugTools = imgui.Checkbox("Show Debug Tools", showDebugTools)
				showGUIDemo = imgui.Checkbox("Show GUI Demo", showGUIDemo)
				showFPS = imgui.Checkbox("Show FPS", showFPS)
				imgui.EndMenu()
			end
			if imgui.BeginMenu("Window") then
				if imgui.Checkbox("VSync", math.abs(love.window.getVSync()) == 1) then
					love.window.setVSync(-1)
				else
					love.window.setVSync(0)
				end
				imgui.EndMenu()
			end
			imgui.EndMainMenuBar()
		end
		if showGUIDemo then
			showGUIDemo = imgui.ShowDemoWindow(true)
		end
	end

	if showTreeEditor then
		showTreeEditor = EditorWindow.draw(level)
	end

	if showPixelEditor then
		showPixelEditor = PixelEditorWindow:draw()
	end

	-- Very important... this effects imgui
	love.graphics.setColor(colors.white)
	imgui.Render()
end