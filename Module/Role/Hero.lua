local Player = require "Role.Player"

module(..., package.seeall)

STATUS = enum
{
	"STAND",
	"MOVING",
	"ATTACK",
}

class = Player.class:subclass()

function class:initialize(...)
    super.initialize(self, ...)
    if self.id == 999 then
    	return 
    end

    self.aiEvent = self:createEvent("heroAI"..self.id, "doRandomMove")

    util.timer:repeats(10000, self.aiEvent)
end

function class:dispose()
	if self.aiEvent then
		self.aiEvent:unbind()
	end
    super.dispose(self)
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

function class:doRandomMove()
	local x,y = self:getPos()
	x = math.random(500, 1300)
	y = math.random(1000, 1600)
	local dir = self:computeDir(x, y)
	self.avatar:setDir(dir)


	if self.status ~= STATUS.MOVING then
		self.avatar:play("run")
		self.status = STATUS.MOVING
	end

    local callEnd = cc.CallFunc:create(function()
				self.avatar:play("idle")
	    		self.status = STATUS.STAND
        end)

    local dis = cc.pGetDistance(cc.p(self:getPos()), cc.p(x, y))
    local time = dis / self.speed
    local moveto = cc.MoveTo:create(time, cc.p(x, y))
    
    local action = cc.Sequence:create({moveto, callEnd})
    action = cc.Speed:create(action, 1)
    self.avatar:runAction(action)

end
