require "Account"

module (..., package.seeall)

local USE_NET = true
-- local AccountState = MsgTestJson:typeDef("AccountState")

prototype = Controller.prototype:subclass()

function prototype:isFullWinodwMode()
	return true
end

function prototype:enter(bAutoEnter)
	bAutoEnter = bAutoEnter or false
	-- MsgTestJson:on("Test01", self:createEvent("onTest01"))

	-- local EVT = Net.Mgr.EVT
	-- net.mgr:on(EVT.CONN, self:createEvent("onNetworkConnect"))

	Model:load({"Announce"})

	self:bindModelEvent("Account.EVT.PUSH_CONNECT_RESULT", "onPushConnectResult")
	self:bindModelEvent("Account.EVT.PUSH_LOGIN_ERROR", "onPushLoginError")
	self:bindModelEvent("Account.EVT.PUSH_WEIXIN_ERROR", "onPushWeixinError")

	self:initControl()

	if USE_NET then
		Model:get("Account"):connect()
	end

	self.tryAgain = false
	self.initConnect = true

	if Model:get("Account"):isAccountLogin() or Model:get("Account"):getIsTest() then
		--账号登录
		self.btnWxLogin:setVisible(false)

		--获取记录账号信息：id、账号、密码
		local accountId = db.var:getSysVar("account_login_id")
		local accountName = db.var:getSysVar("account_login_name")
		local accountPassword = db.var:getSysVar("account_login_password")
		if accountName and accountName~="" then
			self.txtAccountId:setString(accountName)
		else						
			self.txtAccountId:setString(accountId or "游客登录")
		end

		if util:getPlatform() == "win32" then
			-- self.txtAccountId:setString("游客登录")
			return
		end

		if bAutoEnter then
			self.panelLoginInfo:setVisible(false)
			self.imgClause:setVisible(false)
			self.checkAgree:setVisible(false)

			if accountName and accountName~="" and accountPassword and accountPassword~="" then
				--存在账号密码，非游客账号
				Model:get("Account"):accountLogin(accountName, accountPassword)
			else
				--游客账号				
				Model:get("Account"):visitorlogin()
			end
		else
			self.imgClause:setVisible(true)
			self.checkAgree:setVisible(true)
		end
	else
		--微信登录
		self.panelLoginInfo:setVisible(false)

		local isSucc = false
		if bAutoEnter then
			isSucc = Model:get("Account"):weixinTokenLogin()
		end

		if isSucc then
			self.imgClause:setVisible(false)
			self.checkAgree:setVisible(false)
			self.btnWxLogin:setVisible(false)
		else
			self.imgClause:setVisible(true)
			self.checkAgree:setVisible(true)
			self.btnWxLogin:setVisible(true)
		end
	end
end

function prototype:refreshShowAccount()
	local accountId = db.var:getSysVar("account_login_id")
	local accountName = db.var:getSysVar("account_login_name")
	local accountPassword = db.var:getSysVar("account_login_password")
	if accountName and accountName~="" then
		self.txtAccountId:setString(accountName)
	else						
		self.txtAccountId:setString(accountId or "游客登录")
	end
end

function prototype:initControl()
	-- self.loadingBar:setPercent(0)
	local version = sdk.platform:getUIShowVersion()
	self.textVersion:setString(version)

	-- self:setFrameEventCallFunc(bind(self.frameEventCallback, self))
	-- self:setLastFrameCallFunc(function () end)
	-- self:playActionTime(0, false)

	self:autoSetAccount()
end

function prototype:autoSetAccount()
	---根据配置 自动设置账户 密码   临时使用 方便大家用不同的账号
	-- account.txt放在根目录  不要传上来
	-- 格式：
			-- return
			-- {
			--     name = "s001",
			--     password = "123456",
			-- }
	-- if not util:fileExist("account.txt") then
	-- 	return
	-- end
	-- local data = util:openFile("account.txt")
 --    if nil == data or #data == 0 then
 --        return 
 --    end

 --    local status, info = pcall(loadstring(data))
 --    assert(status) 
 --    self.tfName:setString(info.name)
	-- self.tfPassword:setString(info.password)
end

-- function prototype:onNetworkConnect(succ)
-- 	if succ then
-- 		self.canLogin = true
-- 		if self.tryAgain == true then
-- 			ui.mgr:close("Net/Connect")
-- 			self:startLogin()
-- 		end
-- 	else
-- 		if not self.initConnect then
-- 			local NET_SHOW_MSG = Net.Mgr.NET_SHOW_MSG
-- 			local data = {
-- 				content = NET_SHOW_MSG.UN_CONNECT_SERVER,
-- 				-- okFunc = bind(self.tryAgainLogin, self)
-- 			}
-- 			ui.mgr:open("Dialog/ConfirmDlg", data)
-- 			ui.mgr:close("Net/Connect")
-- 			-- ui.confirm:popup("连接服务器失败")
-- 		else
-- 			self.initConnect = false
-- 		end
-- 	end
-- end


-- function prototype:tryAgainLogin()
-- 	self.tryAgain = true
-- 	Model:get("Account"):connect()

-- 	ui.mgr:open("Net/Connect")
-- end

function prototype:onPushConnectResult()
	self.panelLoginInfo:setVisible(true)
end

function prototype:onPushLoginError()
	if Model:get("Account"):isAccountLogin() or Model:get("Account"):getIsTest() then
		self.panelLoginInfo:setVisible(true)
	else		
		self.btnWxLogin:setVisible(true)
	end

	self.imgClause:setVisible(true)
	self.checkAgree:setVisible(true)
end

function prototype:startLogin()
	-- if util:getPlatform() == "win32" then
	-- 	Model:get("Account"):visitorlogin()
	-- 	return
	-- end

	--获取记录账号信息：id、账号、密码
	local accountId = db.var:getSysVar("account_login_id")
	local accountName = db.var:getSysVar("account_login_name")
	local accountPassword = db.var:getSysVar("account_login_password")
	if accountName and accountName~="" and accountPassword and accountPassword~="" then
		--存在账号密码，非游客账号
		Model:get("Account"):accountLogin(accountName, accountPassword)
	else
		--游客账号				
		Model:get("Account"):visitorlogin()
	end
end

--切换账号
function prototype:onBtnSwitchAccountClick()
	ui.mgr:open("Login/SwitchAccountView")
end

--账号登录
function prototype:onBtnAccountLoginClick()
	self:startLogin()
end

--微信登录
function prototype:onWinxinLoginClick()
	if self.checkAgree:isSelected() == true then
		Model:get("Account"):weixinLogin()
	else
		local data = {
			content = "请确认并同意用户协议及隐私条款！",
		}
		ui.mgr:open("Dialog/ConfirmDlg", data)
	end
end

function prototype:onPushWeixinError(msg)
	self.imgClause:setVisible(true)
	self.checkAgree:setVisible(true)
	self.btnWxLogin:setVisible(true)
end

--隐私条款
function prototype:onProtolMsgClick()
	ui.mgr:open("Dialog/UserProtolView")
end

function prototype:onCheckProtol()

end

function prototype:onBtnLoginClick(sender)
	self:startLogin()
end

function prototype:onBtnRegisterClick()
	local name = self.tfName:getString()
	local password = self.tfPassword:getString()

	if not self:checkInput(name, password) then
		return 
	end

	Model:get("Account"):regist(name, password)  --简化处理 正常有个注册界面
end


function prototype:checkInput(name, password)
	if name == "" then
		local data = {
			content = "请输入用户名",
		}
		ui.mgr:open("Dialog/DialogView", data)
		-- ui.confirm:popup("请输入用户名")
		return false
	end

	if password == "" then
		local data = {
			content = "请输入密码",
		}
		ui.mgr:open("Dialog/DialogView", data)
		-- ui.confirm:popup("请输入密码")
		return false
	end
	return true
end



function prototype:frameEventCallback(frame)
	local name = frame:getEvent()
	-- log("gameloading framecallback:" .. name)
end

function prototype:onTFNameClick(sender, eventType)
	if eventType == ccui.TextFiledEventType.attach_with_ime then
		if self.tfName:getPlaceHolder() == "请输入" then
			self.tfName:setPlaceHolder("")
		end
	elseif eventType == ccui.TextFiledEventType.detach_with_ime then

	end

	Assist.TextField:onEvent(sender, eventType)
end

function prototype:onTFPasswordClick(sender, eventType)
	if eventType == ccui.TextFiledEventType.attach_with_ime then
		if self.tfPassword:getPlaceHolder() == "请输入" then
			self.tfPassword:setPlaceHolder("")
		end
	elseif eventType == ccui.TextFiledEventType.detach_with_ime then

	end

	Assist.TextField:onEvent(sender, eventType)
end
