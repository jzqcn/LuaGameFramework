local Animation = require "UI.Animation"

module (..., package.seeall)

class = UI.Animation.class:subclass()

function class:initialize(name)
    super.initialize(self, name)
end

function class:dispose()
    super.dispose(self)
end

function class:play(actionName, loop)
	local fullName = self.name .. "/" .. actionName
	if not Animation:existAction(fullName) then
		return
	end
	
	super.play(self, actionName, loop)
end

function class:playAction(actionName, dir, loop)
	if dir then
		actionName = actionName .. "/" .. dir
	end
	self:play(actionName, loop)
end

