module (..., package.seeall)

prototype = Controller.prototype:subclass()

local RANDOM = math.random

function prototype:enter()
	-- self.pos = self.rootNode:getWorldPosition()
	local x1, y1 = self.rootNode:getPosition()
	local size = self.rootNode:getParent():getContentSize()
	local x2, y2 = self.rootNode:getParent():getPosition()
	self.pos = cc.p(x1 + x2 - size.width/2, y1 + y2 - size.height/2)
end

function prototype:onBtnRightAreaClick()
	self:fireUIEvent("Longhudou.HuBet")
end

function prototype:getBetPos()
	local x, y = self.panelBetArea:getPosition()
	x = RANDOM(x - 90, x + 90)
	y = RANDOM(y - 65, y + 60)
	-- log("right bet pos : x = " .. x .. ", y = " .. y)
	return cc.p(self.pos.x + x, self.pos.y + y)
end
