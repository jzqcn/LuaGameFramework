module (..., package.seeall)


prototype = Window.prototype:subclass()

function prototype:onBtnBgOutside()
	-- self:close()
end

-- function prototype:addBgMask()

-- end

function prototype:hasBgMask()
	return false
end

function prototype:enter(data)
	self.txtTip:setString(data.content or "")
	
	self.okFunc = data.okFunc
	self.cancelFunc = data.cancelFunc

	self.rootNode:setAnchorPoint(cc.p(0.5, 0.5))

	local function actionOver()
		self.action:dispose()
		self.action = nil
	end

	self.action = self:createJumpOutBezierConfig(self.imgBg, actionOver)
end

function prototype:onBtnOkTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		if self.okFunc then
			self.okFunc()
		end

		self:close()
	end
end

function prototype:onBtnCancelTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		if self.cancelFunc then
			self.cancelFunc()
		end

		self:close()
	end
end
