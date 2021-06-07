--local imgui = require"imgui"
--local imguiStyle = require"gui-style"
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
	--imgui.Init()
	--imguiStyle.load()
	level = TestingLevel()
end

function love.quit()
	--imgui.ShutDown()
end

function love.update(dt)
	input.handleGUIControls()
	--imgui.NewFrame()
	level:update(dt)
	input.update(dt)
	collectgarbage()
end

function love.draw()
	local w, h = love.graphics.getPixelDimensions()
	love.graphics.setBackgroundColor(colors.black)
	level.camera:dispatch()

	if showFPS then
		local rFPS = 1/love.timer.getDelta()
		local fps = love.timer.getFPS()
		local string = "CFPS: " .. fps .. "    AFPS: " .. rFPS
		love.graphics.setColor(colors.white)
		love.graphics.print(string, 2, h - 16 - 2, 0, 1.5)
		love.graphics.setColor(colors.black)
		love.graphics.print(string, 3, h - 16 - 3, 0, 1.5)
	end
--[[ 
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
	end ]]

	if input.controllerFocusOnGUI then
		love.graphics.setColor(RGB(0, 0, 0, 120))
		love.graphics.rectangle("fill", 0, 0, love.graphics.getPixelDimensions())
	end

	-- Very important... this effects imgui
	love.graphics.setColor(colors.white)
	--imgui.Render()
end

function love.run()
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
 
	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end
 
	local dt = 0
 
	-- Main loop time.
	return function()
		local width, height, flags = love.window.getMode( )		-- Process events.

		local target = (1/_G.maxFrameRate)
		if dt-target >= 0 then
			love.timer.sleep(dt-target)
		end
		
		-- Update dt, as we'll be passing it to update
		if love.timer then dt = love.timer.step() end 


		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end
 
		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
 
		if love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())
 
			if love.draw then love.draw() end
 
			love.graphics.present()
		end


	end
end