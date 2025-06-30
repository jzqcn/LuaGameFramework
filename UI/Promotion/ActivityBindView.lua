module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:hasBgMask()
	return false
end

function prototype:enter()
	--[[local function actionOver()
		self.action:dispose()
		self.action = nil
	end

	self.action = self:createJumpOutBezierConfig(self.imgPop, actionOver)]]	
end

function prototype:onBtnGotoBindClick()
	ui.mgr:open("Promotion/PromotionBindCodeView")
	self:close()
end

function prototype:onImageExitClick()
	self:close()
end

