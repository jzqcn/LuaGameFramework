module(..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()

end

function prototype:show(delay)
	delay = delay or 0
	self.rootNode:runAction(cc.Sequence:create(cc.DelayTime:create(delay), cc.CallFunc:create(function ()
		self.rootNode:setVisible(true)
	end)))
end

function prototype:hide()
	self.rootNode:stopAllActions()
	self.rootNode:setVisible(false)
end

function prototype:onBtnSnatchTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:fireUIEvent("Game.Snatch", true)
		self.rootNode:setVisible(false)
	end
end

function prototype:onBtnUnsnatchTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:fireUIEvent("Game.Snatch", false)
		self.rootNode:setVisible(false)
	end
end