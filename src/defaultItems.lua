local ItemImage = love.graphics.newImage("assets/Items.png")
ItemImage:setFilter("linear", "nearest")

local ItemTypes = {
    ammo_9mm = {
        type = "ammo",
        name = "9mm bullet",
        description = "Standard 9mm bullet modified to be safe for use in space... but definitely not safe for most lifeforms. Used in handguns and some hunting rifles.",
        rect = {34, 131, 29, 23},
        image = ItemImage,
        price = 5,
        count = 64,
        ox = 14.5,
        oy = 11.5,
        shape = function()
            return love.physics.newRectangleShape(29, 23)
        end
    },
    ammo_45mm = {
        type = "ammo",
        name = "45mm bullet",
        description = "The heavy modified 45mm bullet is capable of more knockback with less damage done to the internal structures of space crafts and while still being very light. Used in hand guns and most sub machines guns.",
        rect = {1, 155, 31, 23},
        image = ItemImage,
        price = 7.5,
        count = 32,
        ox = 14.5,
        oy = 11.5,
        shape = function()
            return love.physics.newRectangleShape(31, 23)
        end
    },
    ammo_556mm = {
        type = "ammo",
        name = "5.56×45mm bullet",
        description = "A rifle bullet designed for penetration and range...  Made slightly less penetrative for use in space.",
        rect = {1, 131, 31, 23},
        image = ItemImage,
        price = 10,
        count = 32,
        ox = 14.5,
        oy = 11.5,
        shape = function()
            return love.physics.newRectangleShape(31, 23)
        end
    },
    ammo_buck = {
        type = "ammo",
        name = "Buck shotgun round",
        description = "You won't find any long horn buck to shoot in space.  You can still buck someone into a long orbit with this however.",
        rect = {33, 155, 31, 23},
        image = ItemImage,
        price = 6,
        count = 24,
        ox = 14.5,
        oy = 11.5,
        shape = function()
            return love.physics.newRectangleShape(31, 23)
        end
    },
    ammo_launcher_grenade = {
        type = "ammo",
        name = "Grenade launcher explosive",
        description = "Let's hope the space station can deal with the explosives. These explosives have enough power to kill most organic life...  More ammo is recommended for synthetics and bioengineered  lifeforms.",
        rect = {66, 131, 31, 19},
        image = ItemImage,
        price = 100,
        count = 4,
        ox = 15.5,
        oy = 9.5,
        shape = function()
            return love.physics.newRectangleShape(31, 19)
        end
    },
    healthkit = {
        type = "consumable",
        name = "Healthkit",
        description = "It heals only humanoids and some organic life forms. It will not heal a robot...  no matter how much it believes to be human.",
        rect = {66, 90, 34, 39},
        image = ItemImage,
        weight = 10,
        price = 25,
        ox = 17,
        oy = 19.5,
        shape = function()
            return love.physics.newRectangleShape(34, 39)
        end
    },
    full_repairkit = {
        type = "consumable",
        name = "Repairkit",
        description = 'It "heals" only robots to a more refurbished status.  Intended exclusively for robots. While the kit can do amputations, it\'s not recommended.',
        rect = {1, 72, 52, 28},
        image = ItemImage,
        weight = 50,
        price = 100,
        ox = 26,
        oy = 14,
        shape = function()
            return love.physics.newRectangleShape(0, -3, 52, 25)
        end
    },
    half_repairkit = {
        type = "consumable",
        name = "Reduced repairkit",
        description = 'It "heals" only robots to a more modest status. This kit is missing tools to do a full service.',
        rect = {1, 101, 52, 28},
        image = ItemImage,
        weight = 25,
        price = 50,
        ox = 26,
        oy = 14,
        shape = function()
            return love.physics.newRectangleShape(0, -3, 52, 25)
        end
    },
    -- Weapons
    ["9mm_handgun"] = {
        type = "weapon",
        name = "9mm handgun",
        ammo = "ammo_9mm",
        description = "This shoots bullets with a 9mm caliber electronically.   The bullet is fired without a firing pin, instead uses high powered miniature lasers or capacitors to heat the caps. It can also send tweets and notify next of kin... or it's just a gun with an LED.",
        rect = {1, 26, 29, 18},
        frames = {{1, 26, 29, 18}, {1, 46, 29, 18}},
        typeID = "ballistic",
        crosshairType = 0,
        crosshairFrames = {
            {35, 1, 3, 2}, -- Top
            {39, 4, 2, 3}, -- Right
            {35, 8, 3, 2}, -- Bottom
            {32, 4, 2, 3}, -- Left
            {35, 4, 3, 3} -- Center Hit
        },
        image = ItemImage,
        fireRate = 0.4,
        altFireRate = 0.01,
        weight = 25,
        price = 200,
        ox = 14.5,
        oy = 9,
        trigger = {9, 7},
        aimPoint = {29, 3},
        shape = function()
            return love.physics.newRectangleShape(29, 18)
        end
    }
}

return ItemTypes
