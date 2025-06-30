module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:hasBgMask()
	return false
end

function prototype:enter()
	local EVT = Net.Mgr.EVT
	net.mgr:on(EVT.CONN, self:createEvent("onNetworkConnect"))
	net.mgr:on(EVT.CLOSE, self:createEvent("onNetworkClose"))

	--Model消息事件
	self:bindModelEvent("Account.EVT.PUSH_GETBACK_PASSWORD", "onPushGetbackPassword")
	self:bindModelEvent("VerifyCode.EVT.SEND_VERIFY_CODE_SUCCESS", "onPushVirifyCode")

	self.tfTelphoneNo:setInputMode(ccui.EditBox.InputMode.phonenumber)
	self.tfCode:setInputMode(ccui.EditBox.InputMode.phonenumber)
	self.btnVerificationCodeDisable:setVisible(false)
	self.txtCountdown:setVisible(false)

	self.canSendMsg = false
	self.autoVerifyCode = false
	self.autoFindPassword = false
end

function prototype:onNetworkConnect(succ)
	if succ then
		log("[FindPasswordView::onNetworkConnect] connect success")
		self.canSendMsg = true

		if self.autoVerifyCode then
			local telNo = self.tfTelphoneNo:getString()
			telNo = string.gsub(telNo, " ", "")
			Model:get("VerifyCode"):sendVerifyCode(telNo, VerifyCode_pb.GetBackPasswd)
		end

		if self.autoFindPassword then
			local telNo = self.tfTelphoneNo:getString()
			local verifyCode = self.tfCode:getString()
			local password = self.tfPassword:getString()
			local password2 = self.tfPassword2:getString()

			telNo = string.gsub(telNo, " ", "")
			verifyCode = string.gsub(verifyCode, " ", "")

			Model:get("Account"):getBackPassword(telNo, password, verifyCode)
		end		
	else
		log("[FindPasswordView::onNetworkConnect] connect failed")
	end

	self.autoVerifyCode = false
	self.autoFindPassword = false
end

function prototype:onNetworkClose()
	log("FindPasswordView::onNetworkClose")
	self.canSendMsg = false
end

function prototype:onTFTelphoneEvent(sender, eventType)
	if eventType == ccui.TextFiledEventType.attach_with_ime then
		if self.tfTelphoneNo:getPlaceHolder() == "请输入11位手机号码" then
			self.tfTelphoneNo:setPlaceHolder("")
		end
	elseif eventType == ccui.TextFiledEventType.detach_with_ime then

	end

	Assist.TextField:onEvent(sender, eventType)
end

function prototype:onTFCodeEvent(sender, eventType)
	if eventType == ccui.TextFiledEventType.attach_with_ime then
		if self.tfCode:getPlaceHolder() == "请输入验证码" then
			self.tfCode:setPlaceHolder("")
		end
	elseif eventType == ccui.TextFiledEventType.detach_with_ime then

	end

	Assist.TextField:onEvent(sender, eventType)
end

function prototype:onTFPwEvent(sender, eventType)
	if eventType == ccui.TextFiledEventType.attach_with_ime then
		if self.tfPassword:getPlaceHolder() == "请输入账号密码" then
			self.tfPassword:setPlaceHolder("")
		end
	elseif eventType == ccui.TextFiledEventType.detach_with_ime then

	end

	Assist.TextField:onEvent(sender, eventType)
end

function prototype:onTFPwAgainEvent(sender, eventType)
	if eventType == ccui.TextFiledEventType.attach_with_ime then
		if self.tfPassword2:getPlaceHolder() == "请再次输入账号密码" then
			self.tfPassword2:setPlaceHolder("")
		end
	elseif eventType == ccui.TextFiledEventType.detach_with_ime then

	end

	Assist.TextField:onEvent(sender, eventType)
end

function prototype:onPushGetbackPassword()
	local telNo = self.tfTelphoneNo:getString()
	local password = self.tfPassword:getString()
	
	telNo = string.gsub(telNo, " ", "")
	db.var:setSysVar("account_login_name", telNo)
	db.var:setSysVar("account_login_password", password)

	Model:get("Account"):saveAccountData(telNo, password)
	--打开切换账号UI
	-- local layer = ui.mgr:getLayer("Login/SwitchAccountView")
	-- if layer then
	-- 	layer:refresh()
	-- end

	ui.mgr:open("Login/SwitchAccountView")

	local data = {
		content = "密码修改成功！",
	}
	ui.mgr:open("Dialog/DialogView", data)

	self:close()
end

function prototype:onPushVirifyCode()

end

--获取验证码 60s后重发
function prototype:onBtnVerificationCodeClick()
	local telNo = self.tfTelphoneNo:getString()
	telNo = string.gsub(telNo, " ", "")

	if telNo == "" then
		local data = {
			content = "请输入绑定手机号",
		}
		ui.mgr:open("Dialog/DialogView", data)		
		return

	elseif string.len(telNo) ~= 11 then
		local data = {
			content = "请输入正确的手机号",
		}
		ui.mgr:open("Dialog/DialogView", data)		
		return
	end

	self.btnVerificationCode:setVisible(false)
	self.btnVerificationCodeDisable:setVisible(true)
	self.txtCountdown:setVisible(true)

	self.txtCountdown:setString("60")

	self.time = 60
	local action = cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function()
		self.time = self.time - 1
		self.txtCountdown:setString(tostring(self.time))

		if self.time <= 0 then
			self.rootNode:stopAllActions()
			self.btnVerificationCode:setVisible(true)
			self.btnVerificationCodeDisable:setVisible(false)
			self.txtCountdown:setVisible(false)
		end
	end))

	self.rootNode:runAction(cc.RepeatForever:create(action))

	if self.canSendMsg then
		Model:get("VerifyCode"):sendVerifyCode(telNo, VerifyCode_pb.GetBackPasswd)
	else
		Model:get("Account"):connect()
		self.autoVerifyCode = true
	end
end

function prototype:onBtnConfirmClick()
	local telNo = self.tfTelphoneNo:getString()
	local verifyCode = self.tfCode:getString()
	local password = self.tfPassword:getString()
	local password2 = self.tfPassword2:getString()

	telNo = string.gsub(telNo, " ", "")
	verifyCode = string.gsub(verifyCode, " ", "")

	if not self:checkInput(telNo, verifyCode, password, password2) then
		return 
	end

	if self.canSendMsg then
		Model:get("Account"):getBackPassword(telNo, password, verifyCode)
	else
		Model:get("Account"):connect()
		self.autoFindPassword = true
	end
end

function prototype:checkInput(telNo, verifyCode, password, password2)
	if telNo == "" then
		local data = {
			content = "请输入绑定手机号",
		}
		ui.mgr:open("Dialog/DialogView", data)
		
		return false

	elseif string.len(telNo) ~= 11 then
		local data = {
			content = "请输入正确的手机号",
		}
		ui.mgr:open("Dialog/DialogView", data)
		
		return false
	end

	if verifyCode == "" then
		local data = {
			content = "请输入验证码",
		}
		ui.mgr:open("Dialog/DialogView", data)
		
		return false
	end

	if password == "" then
		local data = {
			content = "请输入密码",
		}
		ui.mgr:open("Dialog/DialogView", data)

		return false
	end

	if password2 == "" then
		local data = {
			content = "请输入确认密码",
		}
		ui.mgr:open("Dialog/DialogView", data)

		return false
	end

	if password ~= password2 then
		local data = {
			content = "两次密码输入不一致，请重新输入",
		}
		ui.mgr:open("Dialog/DialogView", data)

		return false
	end

	return true
end

function prototype:onBtnCloseClick()
	self:close()
end
