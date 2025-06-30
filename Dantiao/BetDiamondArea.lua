module (..., package.seeall)

prototype = Controller.prototype:subclass()

local RANDOM = math.random

function prototype:enter()
	local x1, y1 = self.rootNode:getPosition()
	local size = self.rootNode:getParent():getContentSize()
	local x2, y2 = self.rootNode:getParent():getPosition()
	self.pos = cc.p(x1 + x2 - size.width/2, y1 + y2 - size.height/2)
	-- self.pos = self.rootNode:getWorldPosition()
end

function prototype:onBtnDiamondAreaClick()
	self:fireUIEvent("Dantiao.DiamondBet")
end

function prototype:getBetPos()
	local x, y = self.panelBetArea:getPosition() --self.panelBetArea:getWorldPosition()
	x = RANDOM(x - 90, x + 60)
	y = RANDOM(y - 50, y + 30)
	-- log("center bet pos : x = " .. x .. ", y = " .. y)
	return cc.p(self.pos.x + x, self.pos.y + y)
end
