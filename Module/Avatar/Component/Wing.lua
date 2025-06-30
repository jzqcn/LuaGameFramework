local Component = require "Avatar.Component.Component"

module (..., package.seeall)

local _existAction =
{
	["idle"] 		= "idle",
	["run"] 		= "idle",
	["die"] 		= "die",
	["attack"] 		= "idle",
	["mount_idle"] 	= "idle",
	["mount_run"] 	= "idle",
}


class = Component.class:subclass()

function class:initialize(name)
    super.initialize(self, name)
end

function class:dispose()
    super.dispose(self)
end

function class:playAction(actionName, dir, loop)
	if not _existAction[actionName] then
		log4model:warn("action not found:" .. actionName)
		return
	end

	super.playAction(self, _existAction[actionName], dir, loop)
end
