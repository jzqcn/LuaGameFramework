module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:hasBgMask()
	return false
end

function prototype:enter()
	self:bindModelEvent("User.EVT.PUSH_EXCHANGE_BANK_LIST", "onPushBankList")
	self:bindModelEvent("User.EVT.PUSH_EXCHANGE_BIND_BANK_CARD", "onPushBankCard")

	self:bindUIEvent("Exchange.BankSelected", "uiEvtBankSelected")

	local bankList = Model:get("User"):getBankList()
	if bankList == nil or #bankList == 0 then
		Model:get("User"):requestBankList()
	else
		self:onPushBankList(bankList)
	end

	local accountInfo = Model:get("Account"):getUserInfo()
	local bankno = accountInfo.bankno
	if bankno and bankno ~= "" then
		local firstStr = string.sub(bankno, 1, 4)
		local endStr = string.sub(bankno, -4)
		self.txtBindNo:setString(firstStr .. "****" .. endStr)
		
		self.imgTitle:loadTexture("resource/csbimages/Shop/titleChangeBank.png")
	else
		self.txtBindNoDesc:setVisible(false)
		self.txtBindNo:setVisible(false)
	end

	self.tfCardNumber:setInputMode(ccui.EditBox.InputMode.phonenumber)
	self.tfTelphone:setInputMode(ccui.EditBox.InputMode.phonenumber)

	self.bankListview:setVisible(false)
	self.bShowList = false

    self.imgBg:addClickEventListener(function (sender)
    	self:onBtnCancelClick()
    end)
end

function prototype:onPushBankList(listData)
	local param = 
	{
		data = listData,
		ccsNameOrFunc = "Shop/BankListItem",
		dataCheckFunc = function (info, elem) return info == elem end
	}
    self.bankListview:createItems(param)

	self.bankList = listData
end

function prototype:onPushBankCard()
	local data = {
		content = "银行卡绑定成功！",
	}
	ui.mgr:open("Dialog/DialogView", data)

	local accountInfo = Model:get("Account"):getUserInfo()
	local cardNumber = self.tfCardNumber:getString()
	cardNumber = string.gsub(cardNumber, " ", "")
	accountInfo.bankno = cardNumber

	local bankView = ui.mgr:getLayer("Shop/BankView")
	if bankView and bankView.refreshBindBankCardState then
		bankView:refreshBindBankCardState()
	end

	self:close()
end

function prototype:onTFCardNumberClick(sender, eventType)
	if eventType == ccui.TextFiledEventType.attach_with_ime then
		if self.tfCardNumber:getPlaceHolder() == "请输入您的银行卡号" then
			self.tfCardNumber:setPlaceHolder("")
		end
	elseif eventType == ccui.TextFiledEventType.detach_with_ime then

	end

	Assist.TextField:onEvent(sender, eventType)
end

function prototype:onTFNameClick(sender, eventType)
	if eventType == ccui.TextFiledEventType.attach_with_ime then
		if self.tfName:getPlaceHolder() == "开户真实姓名" then
			self.tfName:setPlaceHolder("")
		end
	elseif eventType == ccui.TextFiledEventType.detach_with_ime then

	end

	Assist.TextField:onEvent(sender, eventType)
end

function prototype:onTFTelphoneClick(sender, eventType)
	if eventType == ccui.TextFiledEventType.attach_with_ime then
		if self.tfTelphone:getPlaceHolder() == "绑定手机号" then
			self.tfTelphone:setPlaceHolder("")
		end
	elseif eventType == ccui.TextFiledEventType.detach_with_ime then

	end

	Assist.TextField:onEvent(sender, eventType)
end

--选择银行
function prototype:uiEvtBankSelected(data)
	self.bShowList = false
	self.imgArrow:setScaleY(0.53)
	self.bankListview:setVisible(false)

	self.selBankData = data
	self.txtBankName:setString(data.bankname)
	self.txtBankName:setTextColor(cc.c3b(255, 255, 255))
end

function prototype:onImageArrowClick()
	self.bShowList = not self.bShowList
	if self.bShowList then
		self.imgArrow:setScaleY(-0.53)
		self.bankListview:setVisible(true)
	else
		self.imgArrow:setScaleY(0.53)
		self.bankListview:setVisible(false)
	end
end

function prototype:onBtnCancelClick()
	if self.bShowList then
		self.bankListview:setVisible(false)
		self.bShowList = false
		self.imgArrow:setScaleY(0.53)
	end
end

--绑定
function prototype:onBtnConfirmTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local cardNumber = self.tfCardNumber:getString()
		cardNumber = string.gsub(cardNumber, " ", "")
		-- log(cardNumber)
		if cardNumber == "" or string.len(cardNumber) < 16 then
			local data = {
				content = "请输入正确的银行卡号！"
			}
			ui.mgr:open("Dialog/DialogView", data)
			return
		end

		if self.selBankData == nil then
			local data = {
				content = "请选择开户银行！"
			}
			ui.mgr:open("Dialog/DialogView", data)
			return
		end

		local bindName = self.tfName:getString()
		bindName = string.gsub(bindName, " ", "")
		-- log(bindName)
		if bindName == "" then
			local data = {
				content = "请输入开户人姓名！"
			}
			ui.mgr:open("Dialog/DialogView", data)
			return
		end

		local telphone = self.tfTelphone:getString()
		telphone = string.gsub(telphone, " ", "")
		-- log(telphone)
		if telphone == "" or string.len(telphone) ~= 11 then
			local data = {
				content = "请输入正确的手机号"
			}
			ui.mgr:open("Dialog/DialogView", data)
			return
		end

		Model:get("User"):requestBindBankCard(cardNumber, self.selBankData.bankid, bindName, telphone)
	end
end

function prototype:onBtnCancelTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then 
		self:close()
	end
end