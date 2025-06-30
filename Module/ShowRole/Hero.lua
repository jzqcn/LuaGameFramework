local Base = require "ShowRole.Base"
local Define = require "Map.Define"

module(..., package.seeall)

class = Base.class:subclass()

function class:initialize(...)
    super.initialize(self, ...)
end

function class:dispose()
    super.dispose(self)
end

function class:getRoleType()
	return Define.ROLE_TYPE.HERO
end

function class:getBindPos(bindPoint)
	if bindPoint == "head" then
		return 0, 120
	elseif bindPoint == "chest" then
		return 0, 80
	elseif bindPoint == "weapon" then
		return 30, 40
	elseif bindPoint == "foot" then
		return 0, 0
	elseif bindPoint == "leftHand" then
		return -30, 70
	elseif bindPoint == "rightHand" then
		return 60, 70
	else
		return 0, 70
	end
end
