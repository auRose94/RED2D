local ComponentClass = require"component"
local PhysicsComponent = require"comp-physics"
local InventoryClass = require"comp-inventory"
local StatusWindow = require"comp-status-window"
local HeadComponent = require"comp-head"
local BodyComponent = require"comp-body"
local HeadRedData = require"head-red"
local BodyRedData = require"body-red"
local input = require"input"

local PlayerComponent = inheritsFrom(BodyComponent)

function PlayerComponent:getName()
	return "PlayerComponent"
end

function PlayerComponent:init(parent, playerIndex, joystickIndex)
	BodyComponent.init(self, parent, BodyRedData)

	self:setScale(2, 2)

	self.inventory = InventoryClass(parent, self, true)

	--self.headEntity:setPosition(8, 8)
	local headParent = self:findChild("head")
	assert(headParent, "No head point found")
	local headComp = HeadComponent(headParent, HeadRedData)
	self.headComp = headComp

	self.joystickIndex = joystickIndex or 1
	self.playerIndex = playerIndex or 1
	self:registerControls()

	self.statusWindow = StatusWindow(parent)
end

function PlayerComponent:registerControls()
	local playerIndex, joystickIndex = self.playerIndex, self.joystickIndex
	self.leftControl = input.createInput(
		playerIndex,
		{
			name = "Move Left",
			keyboard = {
				key = "a",
				altKey = "left"
			},
			joystick = {
				axis = "leftx",
				axisMin = 0.75,
				direction = -1
			}
		},
		joystickIndex
	)
	self.rightControl = input.createInput(
		playerIndex,
		{
			name = "Move Right",
			keyboard = {
				key = "d",
				altKey = "right"
			},
			joystick = {
				axis = "leftx",
				axisMin = 0.75,
				direction = 1
			}
		},
		joystickIndex
	)
	self.upControl = input.createInput(
		playerIndex,
		{
			name = "Move Up",
			keyboard = {
				key = "w",
				altKey = { "up", "space" }
			},
			joystick = {
				button = "y",
				axis = "lefty",
				axisMin = 0.75,
				direction = -1
			}
		},
		joystickIndex
	)
	self.downControl = input.createInput(
		playerIndex,
		{
			name = "Move Down",
			keyboard = {
				key = "s",
				altKey = "down"
			},
			joystick = {
				axis = "lefty",
				axisMin = 0.5,
				direction = 1
			}
		},
		joystickIndex
	)
	self.inventoryControl = input.createInput(
		playerIndex,
		{
			name = "Inventory",
			keyboard = {
				key = "tab",
				altKey = "rctrl"
			},
			joystick = { button = "back" }
		},
		joystickIndex
	)
	self.interactControl = input.createInput(
		playerIndex,
		{
			name = "Interact",
			keyboard = {
				key = "e",
				altKey = "kp0"
			},
			joystick = { button = "a" }
		},
		joystickIndex
	)
	self.guiPrimary = input.createInput(playerIndex, {
		name = "GUI Left Click",
		keyboard = {
			key = "e",
			altKey = "kp0"
		},
		mouse = { button = 1 },
		joystick = { button = "a" }
	})
	self.guiSecondary = input.createInput(playerIndex, {
		name = "GUI Right Click",
		keyboard = {
			key = "q",
			altKey = "kp."
		},
		mouse = { button = 2 },
		joystick = { button = "x" }
	})
	self.backControl = input.createInput(playerIndex, {
		name = "Back",
		keyboard = { key = "backspace" },
		joystick = { button = "b" }
	})
	self.reloadControl = input.createInput(playerIndex, {
		name = "Reload",
		keyboard = {
			key = "r",
			altKey = "/"
		},
		joystick = { button = "x" }
	})
	self.aimControl = input.createInput(
		playerIndex,
		{
			name = "Aim",
			mouse = { button = 2 }
		},
		joystickIndex
	)
	self.fire1Control = input.createInput(
		playerIndex,
		{
			name = "Primary Fire",
			mouse = { button = 1 },
			joystick = { axis = "triggerright" }
		},
		joystickIndex
	)
	self.fire2Control = input.createInput(
		playerIndex,
		{
			name = "Secondary Fire",
			mouse = { button = 3 },
			joystick = { axis = "triggerleft" }
		},
		joystickIndex
	)
	self.aimDirControl = input.createInput(
		playerIndex,
		{
			name = "Aim Direction",
			joystick = {
				axis = { "rightx", "righty" },
				axisMin = 0.15
			}
		},
		joystickIndex
	)
end

function PlayerComponent:getAimNormal(invertY)
	local aim = self.aimDirControl
	if aim:held() then
		-- Joystick
		local rDirX, rDirY = unpack(aim.value)
		local width, height = love.graphics.getPixelDimensions()
		rDirX, rDirY = rDirX * (width / 4), rDirY * (height / 4)
		if invertY then
			rDirY = -rDirY
		end
		return rDirX, rDirY
		-- Mouse
	else
		local camera = self.parent.level.camera
		local mx, my = self:inverseTransformPoint(camera:mousePosition())
		if invertY then
			my = -my
		end
		return mx, my
	end
	return 0, 0
end

function PlayerComponent:update(dt)
	local inventory = self.inventory

	local right = self.rightControl
	local left = self.leftControl
	local up = self.upControl
	local down = self.downControl
	local inv = self.inventoryControl
	local interact = self.interactControl
	local aim = self.aimControl
	local aimDir = self.aimDirControl
	local fire1 = self.fire1Control
	local fire2 = self.fire2Control

	if inv:pressed() then
		self.statusWindow:toggleWindow()
	end

	inventory.pickup = interact:pressed()

	self.moveRight = right:held()
	self.moveLeft = left:held()
	self.moveUp = up:held()
	self.moveDown = down:held()

	self.headComp.direction = self.direction

	if aim:held() or aimDir:held() then
		self.leftAim = true
		self.rightAim = true
		self.headComp:lookAt({ self:getAimNormal() })
	else
		self.leftAim = false
		self.rightAim = false
		self.headComp:lookAt(0, 0)
	end

	local leftWeapon = self.weapons[1]
	local rightWeapon = self.weapons[2]

	if leftWeapon and rightWeapon then
		leftWeapon.firing = fire1:held()
		rightWeapon.firing = fire2:held()
	elseif leftWeapon then
		leftWeapon.firing = fire1:held()
		if leftWeapon.altFiring ~= nil then
			leftWeapon.altFiring = fire2:held()
		end
	elseif rightWeapon then
		rightWeapon.firing = fire1:held()
		if rightWeapon.altFiring ~= nil then
			rightWeapon.altFiring = fire2:held()
		end
	end

	BodyComponent.update(self, dt)
end

_G.PlayerComponent = PlayerComponent

return PlayerComponent