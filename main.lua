-- local imgui = require"imgui"
local guiStyle = require "gui-style"
love.graphics.setDefaultFilter("linear", "nearest")

local Camera = require "camera"
local Level = require "level"
local TestingLevel = require ".levels.testing"
local input = require "input"
local EditorWindow = require "tree-editor-window"
local PixelEditorWindow = require "pixel-editor-window"
local Entity = require "entity"
local Player = require "comp.player"
local TileMap = require "comp.tilemap"
local Item = require "comp.item"
local Weapon = require "comp.weapon"
local OraLoader = require "ora-loader"

local level = nil
local accumulator = 0

function love.load()
    -- imgui.Init()
    guiStyle.load()
    level = TestingLevel()
end

function love.quit()
    -- imgui.ShutDown()
end

function love.update(dt)
    input.handleGUIControls()
    -- imgui.NewFrame()
    level:update(dt)
    input.update(dt)
    collectgarbage()
end

function love.draw()
    local w, h = love.graphics.getPixelDimensions()
    love.graphics.setBackgroundColor(colors.black)
    level.camera:dispatch()

    if showFPS then
        local rFPS = 1 / love.timer.getDelta()
        local fps = love.timer.getFPS()
        local string = "CFPS: " .. fps .. "    AFPS: " .. string.format("%.3f", rFPS)
        local scale = 0.5
        love.graphics.setColor(colors.white)
        love.graphics.print(string, 2, h - (32 * scale) - 2, 0, scale)
        love.graphics.setColor(colors.black)
        love.graphics.print(string, 3, h - (32 * scale) - 3, 0, scale)
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
end

function love.run()
    if love.load then
        love.load(love.arg.parseGameArguments(arg), arg)
    end

    -- We don't want the first frame's dt to include time taken by love.load.
    if love.timer then
        love.timer.step()
    end

    local dt = 0

    -- Main loop time.
    return function()
        local width, height, flags = love.window.getMode() -- Process events.

        local target = (1 / _G.maxFrameRate)
        if dt - target >= 0 then
            love.timer.sleep(dt - target)
        end

        -- Update dt, as we'll be passing it to update
        if love.timer then
            dt = love.timer.step()
            if dt > target then
                dt = target
            end
        end

        if love.event then
            love.event.pump()
            for name, a, b, c, d, e, f in love.event.poll() do
                if name == "quit" then
                    if not love.quit or not love.quit() then
                        return a or 0
                    end
                end
                love.handlers[name](a, b, c, d, e, f)
            end
        end

        -- Call update and draw
        if love.update then
            love.update(dt)
        end -- will pass 0 if love.timer is disabled

        if love.graphics and love.graphics.isActive() then
            love.graphics.origin()
            love.graphics.clear(love.graphics.getBackgroundColor())

            if love.draw then
                love.draw()
            end

            love.graphics.present()
        end
    end
end

function love.filedropped(file)
    local filename = file:getFilename()
    local ext = filename:match("^.+(%..+)$")
    if ext == ".lua" then
        -- lua script - Modded Style
    elseif ext == ".ora" then
        Level.init(level) -- clears current level
        local camera = level.camera

        local oraLoader = OraLoader(file)

        local tilemapObj = Entity(level, "Tilemap")

        local backTilemap = TileMap(tilemapObj, "assets/Tileset.png", 64)
        backTilemap:loadDefault()
        backTilemap:loadLevel(oraLoader:getImageData("background"), false)

        local tilemap = TileMap(tilemapObj, "assets/Tileset.png", 64)
        tilemap:loadDefault()
        tilemap:loadLevel(oraLoader:getImageData("base"))
        level.tilemap = tilemap

        local playerEntity = Entity(level, "Player", tilemap:getOffset(30, 19))
        Player(playerEntity)

        camera:setTransformOffset(tilemap:getOffset(30, 19))
        camera.followTarget = playerEntity
    end
end
