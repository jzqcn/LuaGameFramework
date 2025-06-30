module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:hasBgMask()
    return false
end

function prototype:enter()
	self:bindModelEvent("User.EVT.PUSH_GIVECOIN_CONFIG", "onPushGiveCoinConfig")

	local shareGold=Model:get("User"):getShareGold()
	if #shareGold < 1 then
		Model:get("User"):requestShare()
		-- util.timer:after(300,function() self:setShareCoin() end)
		self.fontCoin_1:setVisible(false)
	else
		self:setShareCoin()
	end

	self.rootNode:setAnchorPoint(cc.p(0.5, 0.5))
	local function actionOver()
		self.action:dispose()
		self.action = nil
	end
	self.action = self:createJumpOutBezierConfig(self.imgPop, actionOver)
end

function prototype:onPushGiveCoinConfig(shareGoldConfig)
	if shareGoldConfig and #shareGoldConfig > 0 then
		self.fontCoin_1:setString(shareGoldConfig[4]/100)
		self.fontCoin_1:setVisible(true)
	end
end

function prototype:setShareCoin()
	local shareGold=Model:get("User"):getShareGold()
	if #shareGold > 0 then
		self.fontCoin_1:setString(shareGold[4]/100)
	end	
end

function prototype:onBtnRegister()
	ui.mgr:open("User/UserMsgView","Bind_Msg")
	self:close()
end

function prototype:onBtnOkClick()
	self:close()
end
