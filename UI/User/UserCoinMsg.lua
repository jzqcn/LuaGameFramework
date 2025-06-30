module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self:bindModelEvent("SynData.EVT.PUSH_SYN_USER_DATA", "onPushSynUserData")
	self:bindModelEvent("Announce.EVT.PUSH_RECHARGE_MSG", "onPushRechargeMsg")
	self:bindModelEvent("Hall.EVT.PUSH_HALL_USER_DATA", "onPushHallUserData")

	self:onPushSynUserData()
end

function prototype:onPushSynUserData()
	local accountInfo = Model:get("Account"):getUserInfo()
	if accountInfo then
		self.fntGold:setString(Assist.NumberFormat:amount2Hundred(accountInfo.gold))
		self.fntCard:setString(tostring(accountInfo.cardNum))
	end
end

function prototype:onPushRechargeMsg()
	local accountInfo = Model:get("Account"):getUserInfo()
	if accountInfo then
		self.fntGold:setString(Assist.NumberFormat:amount2Hundred(accountInfo.gold))
		self.fntCard:setString(tostring(accountInfo.cardNum))
	end
end

function prototype:onPushHallUserData()
	local accountInfo = Model:get("Account"):getUserInfo()
	if accountInfo then
		self.fntGold:setString(Assist.NumberFormat:amount2Hundred(accountInfo.gold))
		self.fntCard:setString(tostring(accountInfo.cardNum))
	end
end

function prototype:onBtnAddGoldTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		ui.mgr:open("Shop/ShopView", 1)
	end
end

function prototype:onBtnAddCardTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		ui.mgr:open("Shop/ShopView", 2)
	end
end

function prototype:hideCoinBtn()
	self.btnAddSilver:setVisible(false)
	self.btnAddGold:setVisible(false)
	self.panel_click1:setVisible(false)
	self.panel_click2:setVisible(false)
end
