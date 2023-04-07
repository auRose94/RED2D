-- local imgui = require"imgui"
local guiStyle = require "gui.gui-style"
love.graphics.setDefaultFilter("linear", "nearest")

local Camera = require "engine.camera"
local Level = require "engine.level"
local TestingLevel = require ".levels.testing"
local input = require "engine.input"
local Entity = require "engine.entity"
local Player = require "comp.player"
local TileMap = require "comp.tilemap"
local Item = require "comp.item"
local Weapon = require "comp.weapon"
local OraLoader = require "engine.ora-loader"

local DebugTools = require "engine.debug-tools"
local debugTools = nil

local level = nil
local accumulator = 0
local lastDebugDown = false

print(love.graphics.getRendererInfo())

function love.load()
    -- imgui.Init()
    guiStyle.load()
    level = TestingLevel()
    _G.level = level
    debugTools = DebugTools(level)
end

function love.quit()
    -- imgui.ShutDown()
end

function love.update(dt)
    input.handleGUIControls()
    local debugDown = love.keyboard.isDown("f12")
    if debugDown and not lastDebugDown then
        _G.showDebugTools = not _G.showDebugTools
    end
    lastDebugDown = debugDown
    -- imgui.NewFrame()
    level:update(dt)
    input.update(dt)
    collectgarbage()
end

function love.draw()
    love.graphics.origin()
    local w, h = love.graphics.getPixelDimensions()
    love.graphics.setBackgroundColor(colors.black)
    level.camera:dispatch()
    if showDebugTools then
        debugTools:draw()
    end

    if showFPS then
        local rFPS = 1 / love.timer.getDelta() -- real
        local fps = love.timer.getFPS() -- calculated
        local string = "CFPS: " .. fps .. "    AFPS: " .. string.format("%.3f", rFPS)
        local scale = 0.5
        love.graphics.setColor(colors.white)
        love.graphics.print(string, 2, h - (32 * scale) - 2, 0, scale)
        love.graphics.setColor(colors.black)
        love.graphics.print(string, 3, h - (32 * scale) - 3, 0, scale)
    end
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
        love.update(dt)

        if love.graphics and love.graphics.isActive() then
            love.graphics.origin()
            love.graphics.clear(love.graphics.getBackgroundColor())

            love.draw()

            love.graphics.present()
        end
    end
end

function love.filedropped(file)
    local filename = file:getFilename()
    local ext = filename:match("^.+(%..+)$")
    if ext == ".lua" then
        -- lua script - Modded Style
        local f = assert(loadfile(filename))
        level = f()()
        debugTools = DebugTools(level)
    elseif ext == ".ora" then
        level = Level()
        level:load(file)
        debugTools = DebugTools(level)
    end
end
