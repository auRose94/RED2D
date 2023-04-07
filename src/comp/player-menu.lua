-- local imgui = require"imgui"
local Inventory = require "comp.inventory"
local Component = require "engine.component"
local Element = require "gui.element"
local Button = require "gui.elem-button"
local Text = require "gui.elem-text"
local Scroll = require "gui.elem-scroll"
local Window = require "gui.gui-window"
local PlayerMenu = inheritsFrom(Component)

local CategoryNames = {"Any", "Weapons", "Accessories", "Aid", "Tool", "Ammunition", "Junk", "Quest"}
local SortNames = {"Name", "Weight", "Price", "Rarity", "Count"}
local StateNames = {"info", "items", "quests"}

function PlayerMenu:getName()
    return "PlayerMenu"
end

function PlayerMenu:init(parent)
    Component.init(self, parent)
    self.player = self:getComponent(Player)
    self.hide = true
    self:registerControls()
    self.state = 1
end

function PlayerMenu:toggle()
    self.hide = not self.hide
end

function PlayerMenu:registerControls()
    local playerIndex, joystickIndex = self.player.playerIndex, self.player.joystickIndex
    self.leftControl =
        input.createInput(
        playerIndex,
        {
            name = "Move Left",
            keyboard = {
                key = "a",
                altKey = "left"
            },
            joystick = {
                button = "dpleft",
                axis = "leftx",
                axisMin = 0.75,
                direction = -1
            }
        },
        joystickIndex
    )
    self.rightControl =
        input.createInput(
        playerIndex,
        {
            name = "Move Right",
            keyboard = {
                key = "d",
                altKey = "right"
            },
            joystick = {
                button = "dpright",
                axis = "leftx",
                axisMin = 0.75,
                direction = 1
            }
        },
        joystickIndex
    )
    self.upControl =
        input.createInput(
        playerIndex,
        {
            name = "Move Up",
            keyboard = {
                key = "w",
                altKey = {"up", "space"}
            },
            joystick = {
                button = {"y", "dpup"},
                axis = "lefty",
                axisMin = 0.75,
                direction = -1
            }
        },
        joystickIndex
    )
    self.downControl =
        input.createInput(
        playerIndex,
        {
            name = "Move Down",
            keyboard = {
                key = "s",
                altKey = "down"
            },
            joystick = {
                button = "dpdown",
                axis = "lefty",
                axisMin = 0.5,
                direction = 1
            }
        },
        joystickIndex
    )
    self.guiPrimary =
        input.createInput(
        playerIndex,
        {
            name = "GUI Primary",
            keyboard = {
                key = "e",
                altKey = "kp0"
            },
            joystick = {
                button = "a"
            }
        }
    )
    self.guiSecondary =
        input.createInput(
        playerIndex,
        {
            name = "GUI Secondary",
            keyboard = {
                key = "q",
                altKey = "kp."
            },
            joystick = {
                button = "x"
            }
        }
    )
    self.backControl =
        input.createInput(
        playerIndex,
        {
            name = "Back",
            keyboard = {
                key = "backspace"
            },
            joystick = {
                button = "b"
            }
        }
    )
    self.reloadControl =
        input.createInput(
        playerIndex,
        {
            name = "Reload",
            keyboard = {
                key = "r",
                altKey = "/"
            },
            joystick = {
                button = "x"
            }
        }
    )
    self.aimDirControl =
        input.createInput(
        playerIndex,
        {
            name = "Aim Direction",
            joystick = {
                axis = {"rightx", "righty"},
                axisMin = 0.15
            }
        },
        joystickIndex
    )
end

function PlayerMenu:drawInfo()
    echo("Hello World")
end

function PlayerMenu:drawItems()
end

function PlayerMenu:drawQuests()
end

function PlayerMenu:drawGUI()
    if not self.hide then
        local width, height = love.graphics.getDimensions()
        love.graphics.push()
        love.graphics.origin()

        love.graphics.setColor(colors.red)
        love.graphics.rectangle("fill", 0, 0, width, height)

        love.graphics.setColor(colors.white)
        love.graphics.rectangle("line", 0, 0, width, height)

        local states = {self.drawInfo, self.drawItems, self.drawQuests}
        states[self.state](self)

        love.graphics.pop()
    end
end

return PlayerMenu
