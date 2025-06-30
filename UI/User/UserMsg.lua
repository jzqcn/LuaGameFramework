module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self:bindModelEvent("SynData.EVT.PUSH_SYN_USER_DATA", "onPushSynUserData")

	local accountInfo = Model:get("Account"):getUserInfo()
	if accountInfo then
		self.fntGold:setString(Assist.NumberFormat:amount2Hundred(accountInfo.gold))
		self.fntCard:setString(tostring(accountInfo.cardNum))
	end
end

function prototype:onPushSynUserData(data)
	-- log(data)
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

--战绩
function prototype:onBtnRecordTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		
	end
end

--排行榜
function prototype:onBtnRankTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		ui.mgr:open("Rank/RankView")
	end
end

