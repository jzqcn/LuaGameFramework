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

function prototype:onBtnSpadeAreaClick()
	self:fireUIEvent("Dantiao.SpadeBet")
end

function prototype:getBetPos()
	local x, y = self.panelBetArea:getPosition()
	x = RANDOM(x - 70, x + 70)
	y = RANDOM(y - 50, y + 40)
	-- log("right bet pos : x = " .. x .. ", y = " .. y)
	return cc.p(self.pos.x + x, self.pos.y + y)
end
