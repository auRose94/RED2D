
local ItemImage = love.graphics.newImage("assets/Items.png")
ItemImage:setFilter("linear", "nearest")

local ItemTypes = {
	["ammo_9mm"] = {
		["name"] = "9mm bullet",
		["rect"] = {34, 131, 29, 23},
		["image"] = ItemImage,
		["price"] = 5,
		["count"] = 64,
		["ox"] = 14.5,
		["oy"] = 11.5,
		["shape"] = function ()
			return love.physics.newRectangleShape(29, 23)
		end
	},
	["ammo_45mm"] = {
		["name"] = "45mm bullet",
		["rect"] = {1, 155, 31, 23},
		["image"] = ItemImage,
		["price"] = 7.5,
		["count"] = 32,
		["ox"] = 14.5,
		["oy"] = 11.5,
		["shape"] = function ()
			return love.physics.newRectangleShape(31, 23)
		end
	},
	["ammo_556mm"] = {
		["name"] = "5.56×45mm bullet",
		["rect"] = {1, 131, 31, 23},
		["image"] = ItemImage,
		["price"] = 10,
		["count"] = 32,
		["ox"] = 14.5,
		["oy"] = 11.5,
		["shape"] = function ()
			return love.physics.newRectangleShape(31, 23)
		end
	},
	["ammo_buck"] = {
		["name"] = "Buck shotgun round",
		["rect"] = {33, 155, 31, 23},
		["image"] = ItemImage,
		["price"] = 6,
		["count"] = 24,
		["ox"] = 14.5,
		["oy"] = 11.5,
		["shape"] = function ()
			return love.physics.newRectangleShape(31, 23)
		end
	},
	["ammo_launcher_grenade"] = {
		["name"] = "Grenade launcher explosive",
		["rect"] = {66, 131, 31, 19},
		["image"] = ItemImage,
		["price"] = 100,
		["count"] = 4,
		["ox"] = 15.5,
		["oy"] = 9.5,
		["shape"] = function ()
			return love.physics.newRectangleShape(31, 19)
		end
	},
	["healthkit"] = {
		["name"] = "Healthkit",
		["rect"] = {66, 90, 34, 39},
		["image"] = ItemImage,
		["weight"] = 10,
		["price"] = 25,
		["ox"] = 17,
		["oy"] = 19.5,
		["shape"] = function ()
			return love.physics.newRectangleShape(34, 39)
		end
	},
	["full_repairkit"] = {
		["name"] = "Repairkit",
		["rect"] = {1, 72, 52, 28},
		["image"] = ItemImage,
		["weight"] = 50,
		["price"] = 100,
		["ox"] = 26,
		["oy"] = 14,
		["shape"] = function ()
			return love.physics.newRectangleShape(0, -3, 52, 25)
		end
	},
	["half_repairkit"] = {
		["name"] = "Reduced repairkit",
		["rect"] = {1, 101, 52, 28},
		["image"] = ItemImage,
		["weight"] = 25,
		["price"] = 50,
		["ox"] = 26,
		["oy"] = 14,
		["shape"] = function ()
			return love.physics.newRectangleShape(0, -3, 52, 25)
		end
	},
	--Weapons
	["9mm_handgun"] = {
		["name"] = "9mm electronic handgun",
		["rect"] = {1, 26, 29, 18},
		["frames"] = {
			{1, 26, 29, 18},
			{1, 46, 29, 18}
		},
		["typeID"] = "balistic",
		["crosshairType"] = 0,
		["crosshairFrames"] = {
			{35, 1, 3, 2}, -- Top
			{39, 4, 2, 3}, -- Right
			{35, 8, 3, 2}, -- Bottom
			{32, 4, 2, 3}, -- Left

			{35, 4, 3, 3}, -- Center Hit
		},
		["image"] = ItemImage,
		["fireRate"] = 0.4,
		["altFireRate"] = 0.01,
		["weight"] = 25,
		["price"] = 200,
		["ox"] = 14.5,
		["oy"] = 9,
		["trigger"] = { 9, 7 },
		["aimPoint"] = { 29, 3 },
		["shape"] = function ()
			return love.physics.newRectangleShape(29, 18)
		end
	}
}

return ItemTypes