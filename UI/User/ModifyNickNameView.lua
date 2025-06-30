module (..., package.seeall)

prototype = Dialog.prototype:subclass()


function prototype:enter()
	self:bindModelEvent("User.EVT.PUSH_CHANGE_NICK_NAME", "onPushModifyNickName")

	local accountInfo = Model:get("Account"):getUserInfo()
	self.txtNickname:setString(accountInfo.nickName)
	self.rootNode:setAnchorPoint(cc.p(0.5, 0.5))
	local function actionOver()
		self.action:dispose()
		self.action = nil
	end
	self.action = self:createJumpOutBezierConfig(self.imgPop, actionOver)
end

function prototype:onTFNicknameEvent(sender, eventType)
	if eventType == ccui.TextFiledEventType.attach_with_ime then
		if self.tfNickname:getPlaceHolder() == "请输入玩家昵称" then
			self.tfNickname:setPlaceHolder("")
		end
	elseif eventType == ccui.TextFiledEventType.detach_with_ime then

	end

	Assist.TextField:onEvent(sender, eventType)
end

function prototype:onBtnConfirmClick()
	local nickname = self.tfNickname:getString()
	if nickname == "" then
		local data = {
			content = "昵称不能为空",
		}
		ui.mgr:open("Dialog/DialogView", data)
		return
	end

	local oldName = self.txtNickname:getString()
	if nickname == oldName then
		self:close()
		return
	end

	local accountInfo = Model:get("Account"):getUserInfo()
	accountInfo.newNickName = nickname

	Model:get("User"):requestModifyNickName(nickname)
end

--修改昵称
function prototype:onPushModifyNickName()
	local data = {
		content = "昵称修改成功",
	}
	ui.mgr:open("Dialog/DialogView", data)

	local nickname = self.tfNickname:getString()
	local layer = ui.mgr:getLayer("User/UserMsgView")
	if layer then
		layer:updateUserNickName(nickname)
	end

	local accountInfo = Model:get("Account"):getUserInfo()
	accountInfo.nickName = nickname
	accountInfo.newNickName = nil

	self:close()
end

function prototype:onBtnCloseClick()
	self:close()
end

