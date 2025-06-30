module(..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self.size = self.rootNode:getContentSize()
end

function prototype:show(isFirst)
	isFirst = isFirst or false
	self.btnTip:setVisible(not isFirst)
	
	if isFirst then
		self.btnReset:setPositionX(180)
		self.btnDiscard:setPositionX(410)
	else
		self.btnReset:setPositionX(90)
		self.btnTip:setPositionX(295)
		self.btnDiscard:setPositionX(500)
	end
	
	self.rootNode:setVisible(true)
end

function prototype:checkEnabledButton(beDiscard, beReset)
	self.btnDiscard:setEnabled(beDiscard)
	self.btnReset:setEnabled(beReset)

	if beDiscard then
		Assist:setNodeColorful(self.btnDiscard)
	else
		Assist:setNodeGray(self.btnDiscard)
	end

	if beReset then
		Assist:setNodeColorful(self.btnReset)
	else
		Assist:setNodeGray(self.btnReset)
	end
end

--提示
function prototype:onBtnTipTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:fireUIEvent("Game.DiscardTip")
	end
end

--出牌
function prototype:onBtnDiscardTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:fireUIEvent("Game.DiscardOut")
	end
end

--重选
function prototype:onBtnResetTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:fireUIEvent("Game.DiscardReset")
	end
end



