module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:hasBgMask()
	return false
end

--[[
	注册账号 1
	绑定推广码 2
	首次充值 3
	绑定手机 4
	限制金额
]]

function prototype:enter(data)
	self:bindModelEvent("User.EVT.PUSH_GIVECOIN_CONFIG", "onPushGiveCoinConfig")
	--获取推广信息
	--Model:get("Account"):getPromotionInfo(bind(self.initPromotionInfo, self))
	self:initPromotionInfo()
	
	local shareGold=Model:get("User"):getShareGold()
	if #shareGold < 1 then
		Model:get("User"):requestShare()
		self.fontCoin_1:setVisible(false)
		self.fontCoin_2:setVisible(false)
		self.fontCoin_3:setVisible(false)
		self.fontCoin_4:setVisible(false)
	else
		self:onPushGiveCoinConfig(shareGold)
	end
end

function prototype:onCaptureScreenClick()
	local accountLogin=Model:get("Account"):isAccountLogin()
	if accountLogin then
		util:captureScreenToCamera()
	else
		util:captureScreen()
	end
end

function prototype:initPromotionInfo()
	local userInfo = Model:get("Account"):getUserInfo()
	local isEnabledPromotion = Model:get("Account"):isEnabledPromotion()
	--dump(userInfo,"userInfo")
	if isEnabledPromotion then
		if userInfo.redeemCode and userInfo.redeemCode ~= "" then
			self.fontCoin_10:setString(userInfo.redeemCode)
		else
			self.fontCoin_10:setString("未绑定")
		end
	else
		if userInfo.isPromote then--推广员
			self.fontCoin_10:setString(userInfo.redeemCode)
		else
			if userInfo.pRedeemCode and userInfo.pRedeemCode~="" then
				self.fontCoin_10:setString(userInfo.pRedeemCode)
			else
				self.fontCoin_10:setString("未绑定")
			end
		end
	end
end



function prototype:onPushGiveCoinConfig(shareGold)
	if shareGold and #shareGold > 0 then
		self.fontCoin_1:setString(shareGold[1]/100)
		self.fontCoin_2:setString(shareGold[2]/100)
		self.fontCoin_3:setString(shareGold[3]/100)
		self.fontCoin_4:setString(shareGold[4]/100)
		self.fontCoin_1:setVisible(true)
		self.fontCoin_2:setVisible(true)
		self.fontCoin_3:setVisible(true)
		self.fontCoin_4:setVisible(true)
		if Model:get("Account"):isAccountLogin() == false then
			self.fontCoin_4:setVisible(false)
		end
	end
end

function prototype:onPanelCloseClick()
	self:close()
end