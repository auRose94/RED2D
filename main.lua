love.graphics.setDefaultFilter("linear", "nearest")

local CameraClass = require "camera"
local LevelClass = require "level"
local TestingLevel = require ".levels.testing"
local input = require "input"

local platform = {}

local level = nil

function love.load()
	platform.width = love.graphics.getWidth()
	platform.height = love.graphics.getHeight()

	local font = love.graphics.newFont("assets/unifont.ttf", 32, "mono")
	font:setFilter("linear", "nearest", 0)
	love.graphics.setFont(font)

	platform.x = 0
	platform.y = platform.height / 2

	level = TestingLevel()
end

function love.update(dt)
	level:update(dt)
	input.update(dt)
end

function love.draw()
	love.graphics.setBackgroundColor(colors.lightBlue)
	level.camera:dispatch()

	love.graphics.setColor(colors.white)
	love.graphics.print("FPS: " .. love.timer.getFPS(), 2, 2, 0, 0.5)
	love.graphics.setColor(colors.black)
	love.graphics.print("FPS: " .. love.timer.getFPS(), 3, 3, 0, 0.5)
end