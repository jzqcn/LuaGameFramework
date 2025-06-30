module (..., package.seeall)

prototype = Dialog.prototype:subclass()


function prototype:hasBgMask()
	return false
end

function prototype:enter(clubData)
	self:bindModelEvent("Club.EVT.PUSH_CLUB_GET_INCOME", "onPushClubIncome")
	local function actionOver()
		self.action:dispose()
		self.action = nil
	end

	self.action = self:createJumpOutBezierConfig(self.imgPop, actionOver)
	
	self.txtTotalIncome:setString(Assist.NumberFormat:amount2TrillionText(clubData.totalOwnerProfit))
	self.txtLeftIncome:setString(Assist.NumberFormat:amount2TrillionText(clubData.ownerProfit))

	if clubData.ownerProfit > 0 then
		--Assist:setNodeColorful(self.btnGetCach)
	else
		Assist:setNodeGray(self.btnOk)
	end

	self.clubData = clubData
end

--提现
function prototype:onBtnOkTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		if self.clubData.ownerProfit <= 0 then
			local data = {
				content = "当前还没有可提现收益，继续努力吧！"
			}
			ui.mgr:open("Dialog/DialogView", data)
			Assist:setNodeGray(self.btnOk)
			return
		end

		Model:get("Club"):requestPickupIncome(self.clubData.id)
	else
		Assist:setNodeGray(self.btnOk)
	end
end

--提现成功
function prototype:onPushClubIncome()
	ui.mgr:open("Promotion/ShareAwardView", {type = Common_pb.Gold, value = self.clubData.ownerProfit})
	-- Assist:setNodeGray(self.btnOk)

	self.clubData.ownerProfit = 0
	self:close()
end

function prototype:onImageCloseClick()
	self:close()
end

