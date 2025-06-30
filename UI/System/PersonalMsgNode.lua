module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self:bindModelEvent("User.EVT.PUSH_PERSONAL_SIGN", "onPushPersonalSign")

	local accountInfo = Model:get("Account"):getUserInfo()
	-- local sex = accountInfo.sex or 1 --性别,1-男、2-女
	-- if sex == 1 then
	-- 	self.imgRole:loadTexture("resource/csbimages/Hall/Component/boy.png")
	-- else
	-- 	self.imgRole:loadTexture("resource/csbimages/Hall/Component/girl.png")
	-- end

	self.fntGold:setString(Assist.NumberFormat:amount2Hundred(accountInfo.gold))
	self.fntCard:setString(tostring(accountInfo.cardNum))
	self.txtName:setString(Assist.String:getLimitStrByLen(accountInfo.nickName))
	self.txtId:setString(accountInfo.userId)

	local isEnablePromote = Model:get("Account"):isEnabledPromotion()
	if isEnablePromote then
		if accountInfo.redeemCode and accountInfo.redeemCode~="" then
			self.txtCode:setString(accountInfo.redeemCode)
			self.imgCode:setVisible(true)
			self.btnCopyCode:setVisible(true)
			self.txtCodeTips:setVisible(false)
			self.btnBindCode:setVisible(false)
		else		
			self.txtCodeTips:setVisible(true)
			self.btnBindCode:setVisible(true)
			self.imgCode:setVisible(false)
			self.btnCopyCode:setVisible(false)
		end
	else
		if accountInfo.isPromote then
			self.txtCode:setString(accountInfo.redeemCode)
			self.btnBindCode:setVisible(false)
			self.txtCodeTips:setVisible(false)
		else
			self.imgCode:setVisible(false)
			if accountInfo.redeemCode and accountInfo.redeemCode~="" then
				self.txtCodeTips:setString("已绑定")
				self.btnBindCode:setVisible(false)
				self.btnCopyCode:setVisible(false)
			else
				self.txtCodeTips:setString("您还未绑定推广码！")
				self.btnCopyCode:setVisible(false)
			end
		end
	end

	-- if util:getPlatform() == "win32" then
	-- 	sdk.account:getHeadImage(accountInfo.userId, accountInfo.nickName, self.headIcon)
	-- else
		sdk.account:getHeadImage(accountInfo.userId, accountInfo.nickName, self.headIcon, accountInfo.headImage)
	-- end

	local posInfo = Model:get("Position"):getUserPosition()
	self.txtPos:setString(posInfo.address)

	self.btnEditFinish:setVisible(false)
	if accountInfo.personalSign == "" then
		self.txtPersonalSign:setString("这家伙很懒，什么都没留下")
	else
		self.txtPersonalSign:setString(accountInfo.personalSign)
	end
	self.tfContent:setString("")

	self.tfContent:setPlaceHolderColor(cc.c3b(127, 127, 127))
	self.tfContent:setTextColor(cc.c3b(42, 31, 31))
	-- self.tfContent:setVisible(false)

	self.personalSign = accountInfo.personalSign

	self.exitEditing = false
end

function prototype:onBtnIdCopyTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		util:fireCoreEvent(REFLECT_EVENT_SET_CLIPBOARD_STRING, 0, 0, self.txtId:getString())
	end
end

function prototype:onBtnCodeCopyTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		util:fireCoreEvent(REFLECT_EVENT_SET_CLIPBOARD_STRING, 0, 0, self.txtCode:getString())
	end
end

function prototype:onBtnCodeBindTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		ui.mgr:open("Promotion/PromotionBindCodeView")
	end
end

function prototype:onTFContentEvent(sender, eventType)
	if eventType == ccui.TextFiledEventType.attach_with_ime then
		if self.tfContent:getString() == "" then
			self.tfContent:setString(self.personalSign)
		end

		self.txtPersonalSign:setVisible(false)
		self.btnEditFinish:setVisible(true)
	elseif eventType == ccui.TextFiledEventType.detach_with_ime then
		self.exitEditing = true
		util.timer:after(200, function ()
    		self.exitEditing = false
    	end)
	end

	Assist.TextField:onEvent(sender, eventType)
end

function prototype:isExitEditing()
	return self.exitEditing
end

-- function prototype:onBtnEditTouch(sender, eventType)
-- 	if eventType == ccui.TouchEventType.ended then
-- 		self.tfContent:setVisible(true)
-- 		self.txtPersonalSign:setVisible(false)
-- 		self.btnEdit:setVisible(false)
-- 		self.btnEditFinish:setVisible(true)

-- 		self.tfContent:attachWithIME()
-- 	end
-- end

function prototype:onBtnEditFinishTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		-- Assist.TextField:onEvent(self.tfContent, ccui.TextFiledEventType.detach_with_ime)
		-- self.tfContent:setDetachWithIME(true)
		-- self.tfContent:closeIME()
		
		local content = self.tfContent:getString()
		if content == "" then
			local data = {
				content = "签名不能为空！",
			}
			ui.mgr:open("Dialog/DialogView", data)
			return
		elseif getStrShowWidth(content) > 60 then
			local data = {
				content = "内容长度不能超过60个字符！",
			}
			ui.mgr:open("Dialog/DialogView", data)
			return
		end

		if content ~= self.personalSign then
			Model:get("User"):requestSetPersonalSign(content)
		end

		self.btnEditFinish:setVisible(false)

		self.txtPersonalSign:setString(content)
		self.txtPersonalSign:setVisible(true)
		-- sel.tfContent:setVisible(false)

		self.tfContent:setString("")
	end
end

function prototype:onPushPersonalSign(isSuccess)	
	if not isSuccess then
		self.txtPersonalSign:setString(self.personalSign)
	else
		local accountInfo = Model:get("Account"):getUserInfo()

		local data = {
			content = "个性签名设置成功！"
		}
		ui.mgr:open("Dialog/ConfirmView", data)

		accountInfo.personalSign = self.txtPersonalSign:getString()
		self.personalSign = self.txtPersonalSign:getString()
	end
end
