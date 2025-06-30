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
	self.rootNode:setVisible(false)
end

function prototype:onBtnSnatch1Touch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:fireUIEvent("Game.Snatch", true, 1)
		self.rootNode:setVisible(false)
	end
end

function prototype:onBtnSnatch2Touch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:fireUIEvent("Game.Snatch", true, 2)
		self.rootNode:setVisible(false)
	end
end

function prototype:onBtnSnatch3Touch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:fireUIEvent("Game.Snatch", true, 3)
		self.rootNode:setVisible(false)
	end
end

function prototype:onBtnSnatch4Touch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:fireUIEvent("Game.Snatch", true, 4)
		self.rootNode:setVisible(false)
	end
end

function prototype:onBtnUnsnatchTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:fireUIEvent("Game.Snatch", false)
		self.rootNode:setVisible(false)
	end
end

