-- local imgui = require"imgui"
local input = {}

input.joysticks = {}
input.jIndices = {}
input.allJoysticks = love.joystick.getJoysticks()
for i, j in pairs(input.allJoysticks) do
    if j:isGamepad() and j:getAxisCount() <= 6 then
        table.insert(input.jIndices, i)
        table.insert(input.joysticks, j)
    end
end
input.players = {}
input.GUIJoystick = 1

_G.playerOneKeyboardMouse = true
_G.playerOneUseController = true

local InputController = inheritsFrom()

function InputController:init(player)
    self.player = player
    self.value = 0
    self.lastValue = 0
end

function InputController:isKeyboardMouse()
    return self.keyboard and (self.mouse or self.touch)
end

function InputController:isJoystick()
    return self.joystick and self.joystick.index ~= nil
end

function InputController:setUpKeyboard(data)
    local keyboard = {}
    self.keyboard = keyboard
    keyboard.key = data.key or nil
    keyboard.scancode = data.scancode or nil
    keyboard.altKey = data.altKey or nil
    keyboard.altScancode = data.altScancode or nil
end

function InputController:setUpMouse(data)
    local mouse = {}
    self.mouse = mouse
    mouse.axis = data.axis or nil
    mouse.button = data.button or nil
end

function InputController:setUpTouch(data)
    local touch = {}
    self.touch = touch
    touch.pressureMin = data.pressureMin or 0
end

function InputController:getJoystick()
    if self.joystick and self.joystick.index ~= nil then
        return self.joystick.index
    end
    local index = self.player or 1
    if playerOneUseController then
        if self.player > 1 then
            index = index + 1
        end
    elseif self.player == 1 then
        index = nil
    end
    if index > #input.joysticks and not playerOneKeyboardMouse then
        return nil
    end
    return index
end

function InputController:setUpJoystick(data, index)
    index = index or self:getJoystick()
    if index ~= nil then
        local joystick = {}
        self.joystick = joystick
        joystick.index = index or self.player
        if data.axis then
            joystick.axis = data.axis or nil
            joystick.axisMin = data.axisMin or nil
            joystick.direction = data.direction or nil
        end
        joystick.button = data.button or nil
    end
end

function InputController:getTouchValue()
    -- Update if touch
    local value = 0
    local touch = self.touch
    if touch then
        local pressureMin = touch.pressureMin
        local touches = love.touch.getTouches()
        if #touches > 0 then
            local first = touches[1]
            local x, y = love.touch.getPosition(first)
            local pressure = love.touch.getPressure(first)
            value = {x, y, pressure}
            if pressureMin ~= nil then
                if pressureMin > pressure then
                    value = 0
                end
            end
        end
    end
    return value
end

function InputController:getMouseValue()
    -- Update if mouse
    local value = 0
    local mouse = self.mouse
    if mouse then
        -- if mouse axis
        if mouse.axis == 1 or mouse.axis == "x" then
            value = love.mouse.getX()
        elseif mouse.axis == 2 or mouse.axis == "y" then
            value = love.mouse.getY()
        elseif mouse.axis == "xy" then
            value = {love.mouse.getPosition()}
        end
        -- if mouse button
        if mouse.button then
            value = InputController.convert(love.mouse.isDown(mouse.button))
        end
    end
    return value
end

function InputController:getKeyboardValue()
    -- Update if keyboard
    local value = 0
    local keyboard = self.keyboard
    if keyboard then
        local alts = {}
        -- scancode overides key
        if keyboard.scancode then
            local scancode = keyboard.scancode
            local altScancode = keyboard.altScancode
            if type(altScancode) == "table" then
                alts = altScancode
            elseif type(altScancode) == "string" then
                alts = {altScancode}
            end
            value = love.keyboard.isScancodeDown(scancode, unpack(alts))
        elseif keyboard.key then
            local key = keyboard.key
            local altKey = keyboard.altKey
            if type(altKey) == "table" then
                alts = altKey
            elseif type(altKey) == "string" then
                alts = {altKey}
            end
            value = love.keyboard.isDown(key, unpack(alts))
        end
    end
    value = InputController.convert(value)
    return value
end

function InputController:getJoystickValue()
    -- Update if joystick
    local value = 0
    local joy = self.joystick
    if joy and joy.index <= #input.joysticks then
        local joystick = input.joysticks[joy.index]
        if joystick then
            local button = joy.button
            local axis = joy.axis
            local axisMin = joy.axisMin or nil
            local direction = joy.direction or nil

            if button then
                -- if button
                if type(button) == "number" then
                    value = joystick:isDown(button)
                elseif type(button) == "string" then
                    value = joystick:isGamepadDown(button)
                elseif type(button) == "table" then
                    for _bi, bk in ipairs(button) do
                        local t = false
                        if type(bk) == "number" then
                            t = joystick:isDown(button)
                        elseif type(bk) == "string" then
                            t = joystick:isGamepadDown(button)
                        end

                        if t then
                            value = t
                            break
                        end
                    end
                end
                value = InputController.convert(value)
            end

            if axis then
                -- if table of axises or single axis
                if type(axis) == "table" and #axis == 2 then
                    local ax, ay = joystick:getGamepadAxis(axis[1]), joystick:getGamepadAxis(axis[2])
                    if type(axisMin) == "number" then
                        local dist = math.dist(0, 0, ax, ay)
                        if axisMin < dist then
                            value = {ax, ay}
                        end
                    end
                elseif type(axis) == "number" or type(axis) == "string" then
                    local t = joystick:getGamepadAxis(axis)
                    if type(direction) == "number" then
                        if direction < 0 then
                            if t >= 0 then
                                t = 0
                            end
                        elseif direction > 0 then
                            if t <= 0 then
                                t = 0
                            end
                        end
                    end
                    if type(axisMin) == "number" then
                        if math.abs(axisMin) > math.abs(t) then
                            t = 0
                        end
                    end
                    if t ~= 0 then
                        value = t
                    end
                end
            end
        end
    end
    return value
end

function InputController:update(dt)
    self.lastValue = self.value or 0
    self.value = 0

    if self.joystick then
        local jv = self:getJoystickValue()
        if jv ~= 0 and jv ~= nil then
            self.value = jv
            return jv
        end
    end

    if self.keyboard then
        local kv = self:getKeyboardValue()
        if kv ~= 0 and kv ~= nil then
            self.value = kv
            return kv
        end
    end

    if self.mouse then
        local mv = self:getMouseValue()
        if mv ~= 0 and mv ~= nil then
            self.value = mv
            return mv
        end
    end

    if self.touch then
        local tv = self:getTouchValue()
        if tv ~= 0 and tv ~= nil then
            self.value = tv
            return tv
        end
    end

    return self.value
end

function InputController.convert(value)
    if value == true or value == 1 then
        return 1
    elseif value == false or value == 0 then
        return 0
    end
end

function InputController:boolean()
    if self.value == false or self.value == 0 then
        return false
    end
    return true
end

function InputController:pressed()
    return self.lastValue == 0 and self.value ~= 0
end

function InputController:released()
    return self.lastValue ~= 0 and self.value == 0
end

function InputController:held()
    local vType = type(self.value)
    local lvType = type(self.lastValue)
    if (vType == "number" or vType == "boolean") and (lvType == "number" or lvType == "boolean") then
        return self.lastValue ~= 0 and self.value ~= 0
    elseif type(self.value) == "table" and lvType == "table" then
        local changed = false
        for vn, vi in pairs(self.value) do
            if vi ~= 0 then
                changed = true
            end
        end
        if changed then
            changed = false
            for ln, li in pairs(self.lastValue) do
                if li ~= 0 then
                    changed = true
                end
            end
        end
        return changed
    elseif vType == "table" and (lvType == "number" or self.lastValue == nil) then
        return true
    end
end

function InputController:changed()
    if type(self.value) == "number" and type(self.lastValue) == "number" then
        return self.value ~= self.lastValue
    elseif type(self.value) == "table" and type(self.lastValue) == "table" then
        for vn, vi in pairs(self.value) do
            if self.lastValue[vn] ~= vi then
                return true
            end
        end
        return false
    elseif type(self.value) == "table" and (type(self.lastValue) == "number" or self.lastValue == nil) then
        return true
    end
end

function input.createInput(player, data, index)
    assert(type(data.name) == "string", "Name not a string")
    assert(data.name ~= "", "Name is blank")
    local item = InputController(player)
    local name = data.name
    if index == nil or (player == 1 and playerOneKeyboardMouse) then
        if data.keyboard then
            item:setUpKeyboard(data.keyboard)
        end
        if data.mouse then
            item:setUpMouse(data.mouse)
        end
        if data.touch then
            item:setUpTouch(data.touch)
        end
    end
    if data.joystick then
        item:setUpJoystick(data.joystick, index)
    end
    if type(input.players[player]) ~= "table" then
        input.players[player] = {}
    end
    input.players[player][name] = item
    return item
end

function input.getInput(player, name)
    -- Returns the first and last input of something
    assert(type(player) == "number", "Player index required, " .. type(player) .. " given")
    assert(type(name) == "string", "Input name needs to be string, " .. type(name) .. " given")
    local players = input.players
    local playerInputs = players[player]
    if player <= #players and playerInputs then
        return playerInputs[name]
    end
    return false
end

function input.removePlayer(player)
    local copy = input.players[player]
    input.players[player] = nil
    return copy
end

function input.removeInput(player, name)
    assert(input.players[player])
    local playerObj = input.players[player]
    local copy = playerObj[name]
    playerObj[name] = nil
    return copy
end

function input.update(dt)
    for _, playerInputs in pairs(input.players) do
        for _, item in pairs(playerInputs) do
            item:update(dt)
        end
    end
end

function input.controllerFocusToggle()
    input.controllerFocusOnGUI = not input.controllerFocusOnGUI
end

function input.handleGUIControls()
    if input.controllerFocusOnGUI then
        if input.isConnected(input.GUIJoystick) then
        -- imgui.UseGamepad(input.GUIJoystick)
        end
    end
end

function input.isConnected(joystick)
    assert(joystick >= 1)
    return input.allJoysticks[input.jIndices[joystick]] ~= nil
end

--[[
function love.textinput(t)
	imgui.TextInput(t)
end

function love.keypressed(key)
	imgui.KeyPressed(key)
	if not imgui.GetWantCaptureKeyboard() then
		if key == "`" then
			showDebugTools = not showDebugTools
		elseif key == "f4" then
			showFPS = not showFPS
		end
	end
end

function love.keyreleased(key)
	imgui.KeyReleased(key)
end

function love.mousemoved(x, y)
	imgui.MouseMoved(x, y)
end

function love.mousepressed(x, y, button)
	imgui.MousePressed(button)
end

function love.mousereleased(x, y, button)
	imgui.MouseReleased(button)
end

function love.wheelmoved(x, y)
	imgui.WheelMoved(y)
end
]]
_G.input = input

return input
