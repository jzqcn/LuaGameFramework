module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self:bindModelEvent("User.EVT.PUSH_PROMOTION_PICKUP_INCOME", "onPushPickupIncome")
	self:bindModelEvent("User.EVT.PUSH_PROMOTION_QUERY_INCOME", "onPushQueryIncome")

	self:bindModelEvent("User.EVT.PUSH_BIND_CODE", "onPushBindCode")

	local userInfo = Model:get("Account"):getUserInfo()
	self.txtName:setString(Assist.String:getLimitStrByLen(userInfo.nickName))

	local isEnabledPromotion = Model:get("Account"):isEnabledPromotion()
	if isEnabledPromotion then
		if userInfo.redeemCode and userInfo.redeemCode ~= "" then
			self.txtCode:setString(userInfo.redeemCode)
			self.panelRedeemCode:setVisible(true)
			self.txtCodeTips:setVisible(false)

			self.btnBindCode:setVisible(false)
		else
			self.txtCode:setString("")
			self.panelRedeemCode:setVisible(false)
			self.txtCodeTips:setVisible(true)

			self.btnBindCode:setVisible(true)
		end

	else
		if userInfo.isPromote then
			--推广员			
			if userInfo.redeemCode and userInfo.redeemCode ~= "" then
				self.txtCode:setString(userInfo.redeemCode)
				-- self.panelRedeemCode:setVisible(true)
			end

			self.txtCodeTips:setVisible(false)
			self.btnBindCode:setVisible(false)

		else
			self.panelRedeemCode:setVisible(false)

			if userInfo.redeemCode and userInfo.redeemCode ~= "" then
				self.btnBindCode:setVisible(false)
				self.txtCodeTips:setString("已绑定")
			else
				self.txtCodeTips:setString("您还未绑定推广码！")
			end
		end

		self.panelProgress:setVisible(false)
	end

	sdk.account:getHeadImage(userInfo.userId, userInfo.nickName, self.imgHead, userInfo.headImage)

	self.txtToltalNum:setString("0")
	-- self.txtRevenue:setString("0")
	-- self.txtReward:setString("0")

	self.txtNumB:setString("0")
	self.txtRevenueB:setString("0")
	self.txtRewardB:setString("0")

	if isEnabledPromotion == false then
		self.txtDescB:setString("总人数")
		
		self.panelD:setVisible(false)
		self.panelC:setVisible(false)
	end

	self.txtNumC:setString("0")
	self.txtRevenueC:setString("0")
	self.txtRewardC:setString("0")

	self.txtNumD:setString("0")
	self.txtRevenueD:setString("0")
	self.txtRewardD:setString("0")

	self.loadingbar:setPercent(0)

	-- self.btnGetCach:setEnabled(false)
	Assist:setNodeGray(self.btnGetCach)
	self.totalIncome = 0
end

function prototype:setPromotionInfo(info)
	local promoterInfo = info.promoterInfo
	--推广任务进度
	local progressStatus = promoterInfo.progressStatus	
	local pro = string.split(progressStatus, "/")
	local percent = math.floor(tonumber(pro[1]) / tonumber(pro[2]) * 100)
	if percent > 100 then percent = 100 end

	self.txtProgressStatus:setString(progressStatus)
	self.loadingbar:setPercent(percent)

	-- if percent >= 100 then
	-- 	Assist:setNodeColorful(self.btnGetCach)
	-- end

	--已推广总人数
	local totalJoiner = promoterInfo.totalJoiner or 0
	self.txtToltalNum:setString(promoterInfo.totalJoiner)
	--昨日税收奖励
	-- local yesterDayTotalDraw = promoterInfo.yesterDayTotalDraw or 0
	-- self.txtReward:setString(yesterDayTotalDraw)
	-- --昨日总税收
	-- local yesterDayTotalLevelDraw = promoterInfo.yesterDayTotalLevelDraw or 0
	-- self.txtRevenue:setString(yesterDayTotalLevelDraw)

	local promoteNumCount = info.promoteNumCount
	local first = promoteNumCount.first
	local second = promoteNumCount.second
	local third = promoteNumCount.third

	-------------------B-------------------
	--总人数
	local totalJoiner = first.totalJoiner or 0
	self.txtNumB:setString(totalJoiner)
	--税收总奖励
	-- local totalAllocDraw = first.totalAllocDraw or 0
	-- self.txtRewardB:setString(totalAllocDraw)
	-- --未提取总额
	-- local allocDraw = first.allocDraw or 0
	-- self.txtRevenueB:setString(allocDraw)

	------------------C-------------------
	totalJoiner = second.totalJoiner or 0
	self.txtNumC:setString(totalJoiner)
	--税收总奖励
	-- totalAllocDraw = second.totalAllocDraw or 0
	-- self.txtRewardC:setString(totalAllocDraw)
	-- --未提取总额
	-- allocDraw = second.allocDraw or 0
	-- self.txtRevenueC:setString(allocDraw)

	------------------D---------------------
	totalJoiner = third.totalJoiner or 0
	self.txtNumD:setString(totalJoiner)
	--税收总奖励
	-- totalAllocDraw = third.totalAllocDraw or 0
	-- self.txtRewardD:setString(totalAllocDraw)
	-- --未提取总额
	-- allocDraw = third.allocDraw or 0
	-- self.txtRevenueD:setString(allocDraw)
end

function prototype:onBtnCopyIdClick()
	util:fireCoreEvent(REFLECT_EVENT_SET_CLIPBOARD_STRING, 0, 0, self.txtCode:getString())
end

--绑定推广码
function prototype:onBtnCodeBindTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		ui.mgr:open("Promotion/PromotionBindCodeView")
	end
end

--提现
function prototype:onBtnCachTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local userInfo = Model:get("Account"):getUserInfo()
		if self.loadingbar:getPercent() >= 100 or userInfo.isPromote then
			if self.totalIncome > 0 then
				Model:get("User"):requestPickupIncome()
			else
				local data = {
					content = "当前没有可提现额度，继续加油吧！"
				}
				ui.mgr:open("Dialog/DialogView", data)

				Assist:setNodeGray(self.btnGetCach)
			end
		else
			local data = {
				content = "您还没有成为推广员，无法提现！"
			}
			ui.mgr:open("Dialog/DialogView", data)

			Assist:setNodeGray(self.btnGetCach)
		end
	else
		if self.totalIncome > 0 then
			Assist:setNodeColorful(self.btnGetCach)
		else
			Assist:setNodeGray(self.btnGetCach)
		end
	end
end

--提现成功
function prototype:onPushPickupIncome()
	-- local data = {
	-- 	content = "恭喜，提现成功！"
	-- }
	-- ui.mgr:open("Dialog/ConfirmView", data)

	ui.mgr:open("Promotion/ShareAwardView", {value=self.totalIncome, type=Common_pb.Gold})

	self.txtRevenueB:setString("0")
	self.txtRevenueC:setString("0")
	self.txtRevenueD:setString("0")

	self.totalIncome = 0

	self.btnGetCach:setEnabled(false)
	Assist:setNodeGray(self.btnGetCach)
end

function prototype:onPushQueryIncome(data)
	if not data then
		return
	end

	-- log(data)

	--总奖励
	local totalIncomea = math.floor(tonumber(data.totalIncomea))
	self.txtRewardB:setString(Assist.NumberFormat:amount2TrillionText(totalIncomea))
	--未提取总额
	local incomea = math.floor(tonumber(data.incomea))
	self.txtRevenueB:setString(Assist.NumberFormat:amount2TrillionText(incomea))

	--总奖励
	local totalIncomeb = math.floor(tonumber(data.totalIncomeb))
	self.txtRewardC:setString(Assist.NumberFormat:amount2TrillionText(totalIncomeb))
	--未提取总额
	local incomeb = math.floor(tonumber(data.incomeb))
	self.txtRevenueC:setString(Assist.NumberFormat:amount2TrillionText(incomeb))

	--总奖励
	local totalIncomec = math.floor(tonumber(data.totalIncomec))
	self.txtRewardD:setString(Assist.NumberFormat:amount2TrillionText(totalIncomec))
	--未提取总额
	local incomec = math.floor(tonumber(data.incomec))
	self.txtRevenueD:setString(Assist.NumberFormat:amount2TrillionText(incomec))

	self.totalIncome = tonumber(data.incomea) + tonumber(data.incomeb) + tonumber(data.incomec)
	if self.totalIncome > 0 then
		Assist:setNodeColorful(self.btnGetCach)
	else
		Assist:setNodeGray(self.btnGetCach)
	end
end

function prototype:onPushBindCode(redeemCode)
	local isEnabledPromotion = Model:get("Account"):isEnabledPromotion()
	if isEnabledPromotion then
		if redeemCode and redeemCode ~= "" then
			self.txtCode:setString(redeemCode)
			self.panelRedeemCode:setVisible(true)
			self.txtCodeTips:setVisible(false)

			self.btnBindCode:setVisible(false)
		else
			self.txtCode:setString("")
			self.panelRedeemCode:setVisible(false)
			self.txtCodeTips:setVisible(true)

			self.btnBindCode:setVisible(true)
		end
	else
		local userInfo = Model:get("Account"):getUserInfo()
		if userInfo.isPromote then
			--推广员			
			if redeemCode and redeemCode ~= "" then
				self.txtCode:setString(redeemCode)
				-- self.panelRedeemCode:setVisible(true)
			end

			self.txtCodeTips:setVisible(false)
		else
			self.panelRedeemCode:setVisible(false)

			if redeemCode and redeemCode ~= "" then				
				self.txtCodeTips:setString("已绑定")
			else
				self.txtCodeTips:setString("您还未绑定推广码！")
			end
		end

		self.btnBindCode:setVisible(false)
		self.panelProgress:setVisible(false)
	end
end

