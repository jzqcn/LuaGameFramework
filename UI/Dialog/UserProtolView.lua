module (..., package.seeall)

prototype = Dialog.prototype:subclass()


function prototype:enter()
	self.rootNode:setAnchorPoint(cc.p(0.5, 0.5))
	local function actionOver()
		self.action:dispose()
		self.action = nil
	end
	self.action = self:createJumpOutBezierConfig(self.imgBg, actionOver)
end

function prototype:onBtnOkTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:close()
	end
end

