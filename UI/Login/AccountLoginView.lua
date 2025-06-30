module (..., package.seeall)

prototype = Dialog.prototype:subclass()

function prototype:hasBgMask()
	return false
end

function prototype:enter()
	self.tfTelphoneNo:setInputMode(ccui.EditBox.InputMode.phonenumber)
	self.rootNode:setAnchorPoint(cc.p(0.5, 0.5))
	local function actionOver()
		self.action:dispose()
		self.action = nil
	end
	self.action = self:createJumpOutBezierConfig(self.imgPop, actionOver)
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

function prototype:onTFPasswordEvent(sender, eventType)
	if eventType == ccui.TextFiledEventType.attach_with_ime then
		if self.tfPassword:getPlaceHolder() == "请输入账号密码" then
			self.tfPassword:setPlaceHolder("")
		end
	elseif eventType == ccui.TextFiledEventType.detach_with_ime then

	end

	Assist.TextField:onEvent(sender, eventType)
end

--忘记密码
function prototype:onBtnForgotPwClick()
	ui.mgr:open("Login/FindPasswordView")
end

--登录
function prototype:onBtnLoginClick()
	local telNo = self.tfTelphoneNo:getString()
	local password = self.tfPassword:getString()
	telNo = string.gsub(telNo, " ", "")

	if not self:checkInput(telNo, password) then
		return 
	end

	Model:get("Account"):accountLogin(telNo, password)
end

function prototype:checkInput(telNo, password)
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

	if password == "" then
		local data = {
			content = "请输入密码",
		}
		ui.mgr:open("Dialog/DialogView", data)

		return false
	end

	return true
end

function prototype:onBtnCloseClick()
	self:close()
end
