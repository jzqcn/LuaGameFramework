module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self.tfTelphoneNo:setInputMode(ccui.EditBox.InputMode.phonenumber)
	self.tfCode:setInputMode(ccui.EditBox.InputMode.phonenumber)
	self.btnVerificationCodeDisable:setVisible(false)
	self.txtCountdown:setVisible(false)
end

function prototype:onTFNameEvent(sender, eventType)
	if eventType == ccui.TextFiledEventType.attach_with_ime then
		if self.tfName:getPlaceHolder() == "必须输入昵称" then
			self.tfName:setPlaceHolder("")
		end
	elseif eventType == ccui.TextFiledEventType.detach_with_ime then

	end

	Assist.TextField:onEvent(sender, eventType)
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

	Model:get("VerifyCode"):sendVerifyCode(telNo, VerifyCode_pb.Register)

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
end

function prototype:onBtnBindPhoneClick()
	local telNo = self.tfTelphoneNo:getString()
	local verifyCode = self.tfCode:getString()
	local password = self.tfPassword:getString()
	local password2 = self.tfPassword2:getString()
	local nickName=self.tfName:getString()

	telNo = string.gsub(telNo, " ", "")
	verifyCode = string.gsub(verifyCode, " ", "")

	if not self:checkInput(telNo, verifyCode, password, password2,nickName) then
		return 
	end

	Model:get("User"):requestBindAccount(telNo, password, verifyCode,nickName)
end

function prototype:getAccountMsg()
	local telNo = self.tfTelphoneNo:getString()
	local password = self.tfPassword:getString()
	return telNo, password
end

function prototype:checkInput(telNo, verifyCode, password, password2,nickName)
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

	if nickName == "" then
		local data = {
			content = "必须输入昵称",
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
