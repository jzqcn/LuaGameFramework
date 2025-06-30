module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self:bindModelEvent("User.EVT.PUSH_EXCHANGE_GOLD", "onPushExchangeGold")

	local accountInfo = Model:get("Account"):getUserInfo()
	self.txtID:setString("ID:" .. accountInfo.userId)

	self:updateBindBankState()

	self.txtExchangeValue:setString("0")
	--保险柜存款
	self.txtDepositNum:setString("0")
	self.saveNum = 0
end

function prototype:updateBindBankState()
	local accountInfo = Model:get("Account"):getUserInfo()
	local bankno = accountInfo.bankno
	if bankno and bankno ~= "" then
		local firstStr = string.sub(bankno, 1, 4)
		local endStr = string.sub(bankno, -4)
		self.txtBindTip:setString("收款卡号:" .. firstStr .. "****" .. endStr)
		self.imgBindCard:loadTexture("resource/csbimages/Shop/btnTxtChangeBank.png")
	else
		self.txtBindTip:setString("暂未绑定银行卡")
	end
end

function prototype:setBankSaveNum(num)
	self.saveNum = num / 100
	self.txtDepositNum:setString(Assist.NumberFormat:amount2Hundred(num))
	self.txtExchangeValue:setString("0")
end

function prototype:onBtnAddClick(sender)
	if self.saveNum < 100 then
		local data = {
			content = "仓库存款不足！请先将金币存入仓库！"
		}
		ui.mgr:open("Dialog/DialogView", data)

		return
	end

	local num = self.txtExchangeValue:getString()
	num = tonumber(num) or 0

	local name = sender:getName()
	local index = tonumber(string.sub(name, -1))
	if index == 1 then
		-- +100
		if num + 100 <= self.saveNum then
			num = num + 100
		end
	elseif index == 2 then
		-- +200
		if num + 200 <= self.saveNum then
			num = num + 200
		end
	elseif index == 3 then
		-- +500
		if num + 500 <= self.saveNum then
			num = num + 500
		end
	elseif index == 4 then
		-- +1000
		if num + 1000 <= self.saveNum then
			num = num + 1000
		end
	end

	self.txtExchangeValue:setString(tostring(num))
end

function prototype:onPushExchangeGold()
	local exchangeValue = tonumber(self.txtExchangeValue:getString())
	self.saveNum = self.saveNum - exchangeValue

	self.txtExchangeValue:setString("0")

	--更新保险箱金额
	Model:get("User"):requestBankQuery()

	local data = {
		content = "金币兑换成功！请注意查收！"
	}
	ui.mgr:open("Dialog/DialogView", data)
end

function prototype:onBtnExchangeTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then 
		local exchangeValue = tonumber(self.txtExchangeValue:getString()) or 0
		if exchangeValue >= 100 then
			if exchangeValue % 100 == 0 then
				Model:get("User"):requestExchange(exchangeValue * 100)
				-- self.btnExchange
			else
				local data = {
					content = "兑换金额必须为100的整数倍！"
				}
				ui.mgr:open("Dialog/DialogView", data)
			end
		else
			local data = {
				content = "请输入兑换金额！"
			}
			ui.mgr:open("Dialog/DialogView", data)
		end
	end
end

function prototype:onBtnBindCardClick()
	ui.mgr:open("Shop/ExchangeBindCardView")
end

function prototype:onBtnBindHelpClick()
	ui.mgr:open("Shop/ExchangeHelpView")
end

function prototype:onBtnClearClick()
	self.txtExchangeValue:setString("0")
end
