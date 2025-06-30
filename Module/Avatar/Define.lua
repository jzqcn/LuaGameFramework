
module(..., package.seeall)

numToDir = {
	"left",
	"right",
	"up",
	"down",
	"leftup",
	"leftdown",
	"rightup", 
	"rightdown",
}

dir =
{
	["left"] 		= "left",
	["right"] 		= "right",
	["up"] 			= "up",
	["down"] 		= "down",
	["leftup"] 		= "leftup",
	["leftdown"] 	= "leftdown",
	["rightup"] 	= "rightup",
	["rightdown"] 	= "rightdown",
}

imageDir = 
{
	["left"] 		= "right",
	["right"] 		= "right",
	["up"] 			= "up",
	["down"] 		= "down",
	["leftup"] 		= "rightup",
	["leftdown"] 	= "rightdown",
	["rightup"] 	= "rightup",
	["rightdown"] 	= "rightdown",
}

flip =
{
	["left"] 		= true,
	["right"] 		= false,
	["up"] 			= false,
	["down"] 		= false,
	["leftup"] 		= true,
	["leftdown"] 	= true,
	["rightup"] 	= false,
	["rightdown"] 	= false,
}

order = 
{
	["default"] = enum
	{
		"mount",
		"wing",
		"body",
		"weapon",
	},

	["up"] = enum
	{
		"mount",
		"body",
		"weapon",
		"wing",
	},
}
order["leftup"] = order["up"]
order["rightup"] = order["up"]
order["left"] = order["up"]
order["right"] = order["up"]


action =
{
	["idle"] 	= "idle",
	["run"] 	= "run",
	["attack"] 	= "attack",
	["attack2"] = "attack",
	["attack3"] = "attack",
	["die"] 	= "die",
}

mountAction =
{
	["idle"]	= "mount_idle",
	["run"]		= "mount_run", 
}

loopAction =
{
	["idle"] 	= true,
	["run"] 	= true,
	["attack"] 	= false,
	["attack2"] = true,
	["attack3"] = true,
	["die"] 	= false,
}

offset =
{
	-- ["body"] = 
	-- {
	-- 	["right"] = {x=0, y=30},
	-- 	["down"]  = {x=0, y=30},
	-- 	["up"] 	  = {x=0, y=30},
	-- },
	-- ["mount_body"] =
	-- {
	-- 	["right"] = {x=0, y=90},
	-- 	["down"]  = {x=0, y=90},
	-- 	["up"] 	  = {x=0, y=30},
	-- },
	-- ["mount"] = 
	-- {
	-- 	["right"] = {x=15, y=50},
	-- 	["down"]  = {x=0, y=30},
	-- 	["up"] 	  = {x=0, y=30},
	-- },

	-- ["weapon"] = 
	-- {
	-- 	["right"] = {x=27, y=5},
	-- 	["down"]  = {x=-3, y=5},
	-- 	["up"] 	  = {x=0, y=23},
	-- },
}

shader = enum
{
	"gray",
	"shade",
	"shade2",
}
