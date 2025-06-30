module (..., package.seeall)

prototype = Dialog.prototype:subclass()

local Sel_Type = Enum
{
	"User_Msg",
	"Bind_Msg",
}

function prototype:enter(data)
	self:bindUIEvent("UserMsgView.BindMsg", "uiEvtBindMsg")

	self:bindModelEvent("User.EVT.PUSH_SET_ACCOUNT", "onPushSetAccount")

	local accountInfo = Model:get("Account"):getUserInfo()
	if not accountInfo.isVisitor or Model:get("Account"):isAccountLogin() == false then
		self.btnUserMsg:setEnabled(false)

		self.btnBindPhone:setVisible(false)
		self.imgBindPhoneSel:setVisible(false)
		self.nodeBindMsg:setVisible(false)
	else
		self:setSelectType(Sel_Type.User_Msg)
	end
	if data~=nil and data == "Bind_Msg" then
		self:setSelectType(Sel_Type.Bind_Msg)
	end
	self.rootNode:setAnchorPoint(cc.p(0.5, 0.5))
	
	local function actionOver()
		self.action:dispose()
		self.action = nil
	end
	self.action = self:createJumpOutBezierConfig(self.rootNode, actionOver)
end

function prototype:uiEvtBindMsg()
	self:setSelectType(Sel_Type.Bind_Msg)
end

function prototype:onBtnUserMsgClick()
	self:setSelectType(Sel_Type.User_Msg)
end

function prototype:onBtnBindNoClick()
	self:setSelectType(Sel_Type.Bind_Msg)
end

function prototype:setSelectType(_type)
	if self.selType == _type then
		return
	end

	if _type == Sel_Type.User_Msg then
		self.imgUserMsgSel:setVisible(true)
		self.imgBindPhoneSel:setVisible(false)

		self.nodeRoleMsg:setVisible(true)
		self.nodeBindMsg:setVisible(false)
	else
		self.imgUserMsgSel:setVisible(false)
		self.imgBindPhoneSel:setVisible(true)

		self.nodeRoleMsg:setVisible(false)
		self.nodeBindMsg:setVisible(true)
	end	

	self.selType = _type
end

function prototype:onPushSetAccount()
	local accountId, password = self.nodeBindMsg:getAccountMsg()
	db.var:setSysVar("account_login_name", accountId)
	db.var:setSysVar("account_login_password", password)

	local accountInfo = Model:get("Account"):getUserInfo()
	accountInfo.isVisitor = false
	accountInfo.accountId = accountId
	accountInfo.password = password

	Model:get("Account"):saveAccountData(accountId, password, accountInfo.userId)

	local data = {
		content = "账号绑定成功！",
	}
	ui.mgr:open("Dialog/DialogView", data)

	self.imgUserMsgSel:setVisible(true)
	self.btnUserMsg:setEnabled(false)
	self.nodeRoleMsg:setVisible(true)
		
	self.btnBindPhone:setVisible(false)
	self.imgBindPhoneSel:setVisible(false)
	self.nodeBindMsg:setVisible(false)

	self.nodeRoleMsg:setBindTelphone(accountId)
end

function prototype:updateUserNickName(nickName)
	self.nodeRoleMsg:setNickName(nickName)
end

function prototype:onBtnCloseClick()
	self:close()
end
