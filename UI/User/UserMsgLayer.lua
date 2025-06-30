module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self:bindModelEvent("User.EVT.PUSH_CHANGE_HEAD_IMG", "onPushChangeHeadImg")

	local accountLogin = Model:get("Account"):isAccountLogin()
	local accountInfo = Model:get("Account"):getUserInfo()

	if accountLogin then
		local headImageIndex = tonumber(accountInfo.headImage) or 1
		-- log("headImageIndex : " .. headImageIndex)
		self.imgHead:loadTexture(string.format("resource/csbimages/User/headImages/touxiang_%d.png", headImageIndex))

		if headImageIndex <= 10 then
			self.imgSexBoy:setVisible(true)
			self.imgSexGirl:setVisible(false)
		else
			self.imgSexBoy:setVisible(false)
			self.imgSexGirl:setVisible(true)
		end
	else
		if accountInfo.sex == 1 then
			self.imgSexBoy:setVisible(true)
			self.imgSexGirl:setVisible(false)
		else
			self.imgSexBoy:setVisible(false)
			self.imgSexGirl:setVisible(true)
		end
		sdk.account:loadHeadImage(accountInfo.userId, accountInfo.nickName, accountInfo.headImage, 
			self:createEvent('LOAD_HEAD_IMG', 'onLoadHeadImage'), self.imgHead)
	end

	self.txtAccount:setString(accountInfo.userId)
	self.txtNickname:setString(accountInfo.nickName)

	self.fntGold:setString(Assist.NumberFormat:amount2Hundred(accountInfo.gold))
	self.fntCard:setString(tostring(accountInfo.cardNum))

	if not accountLogin then
		--非账号登录（微信）
		self.btnChangeHeadImg:setVisible(false)
		self.btnChangeNickName:setVisible(false)
		self.imgBindPhoneBg:setVisible(false)

		self.imgBindCodeBg:setPositionY(250)
	else
		if not accountInfo.isVisitor then
			local accountId = accountInfo.accountId
			local firstStr = string.sub(accountId, 1, 3)
			local endStr = string.sub(accountId, -4)
			self.txtBindPhoneNum:setString(firstStr .. "****" .. endStr)

			self.btnBindPhone:setVisible(false)
		end
	end

	--判断是否开启三级分销，是否推广员
	local isEnablePromote = Model:get("Account"):isEnabledPromotion()
	if isEnablePromote then
		if accountInfo.redeemCode and accountInfo.redeemCode~="" then
			self.txtBindCodeNum:setString(accountInfo.redeemCode)
			self.btnBindCode:setVisible(false)
		else
			self.btnCopyCode:setVisible(false)
		end
	else
		if accountInfo.isPromote then
			self.txtBindCodeNum:setString(accountInfo.redeemCode)
			self.btnBindCode:setVisible(false)
		else
			if accountInfo.pRedeemCode and accountInfo.pRedeemCode~="" then
				self.btnBindCode:setVisible(false)
				self.btnCopyCode:setVisible(false)
				self.txtBindCodeNum:setString(accountInfo.pRedeemCode)
			else
				self.btnCopyCode:setVisible(false)
			end
		end
	end

	local posInfo = Model:get("Position"):getUserPosition()
	self.txtPos:setString(posInfo.address)
end

function prototype:onLoadHeadImage(filename)
	self.imgHead:loadTexture(filename)
end

--复制账号
function prototype:onBtnCopyClick()
	util:fireCoreEvent(REFLECT_EVENT_SET_CLIPBOARD_STRING, 0, 0, self.txtAccount:getString())
end

--修改昵称
function prototype:onBtnModifyClick()
	ui.mgr:open("User/ModifyNickNameView")
end

function prototype:setNickName(name)
	self.txtNickname:setString(name)
end

--绑定账号（手机号码）
function prototype:onBtnBindPhoneClick()
	self:fireUIEvent("UserMsgView.BindMsg")
end

--绑定推广码
function prototype:onBtnBindCodeClick()
	ui.mgr:open("Promotion/PromotionBindCodeView")
end

--复制推广码
function prototype:onBtnCopyCodeClick()
	util:fireCoreEvent(REFLECT_EVENT_SET_CLIPBOARD_STRING, 0, 0, self.txtBindCodeNum:getString())
end

function prototype:setBindTelphone(phoneNo)
	local firstStr = string.sub(phoneNo, 1, 3)
	local endStr = string.sub(phoneNo, -4)
	self.txtBindPhoneNum:setString(firstStr .. "****" .. endStr)

	self.btnBindPhone:setVisible(false)
end

-- function prototype:onCheckSixBoyClick()
-- 	self.checkbox_girl:setSelected(false)
-- 	self.checkbox_boy:setEnabled(false)

-- end

-- function prototype:onCheckSixGirlClick()
-- 	self.checkbox_boy:setSelected(false)
-- 	self.checkbox_girl:setEnabled(false)
-- end

--更换头像
function prototype:onBtnChangeHeadClick()
	ui.mgr:open("User/ChangeHeadImgView")
end

--更换头像返回
function prototype:onPushChangeHeadImg()
	local data = {
		content = "头像修改成功",
	}
	ui.mgr:open("Dialog/DialogView", data)

	local accountInfo = Model:get("Account"):getUserInfo()
	local headImageIndex = accountInfo.headImageIndex
	accountInfo.headImage = headImageIndex
	-- log("headImageIndex:" .. headImageIndex)

	self.imgHead:loadTexture(string.format("resource/csbimages/User/headImages/touxiang_%d.png", headImageIndex))

	if headImageIndex <= 10 then
		self.imgSexBoy:setVisible(true)
		self.imgSexGirl:setVisible(false)
	else
		self.imgSexBoy:setVisible(false)
		self.imgSexGirl:setVisible(true)
	end
end

--切换账号
function prototype:onBtnSwitchAccountClick()
	net.mgr:disconnect()			
	StageMgr:chgStage("Login", false)
end

