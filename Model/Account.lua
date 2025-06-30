module(..., package.seeall)

class = Model.class:subclass()

EVT = Enum
{
	"SETSECRET",
	"PUSH_CONNECT_RESULT",
	"PUSH_LOGIN_ERROR",
	"PUSH_WEIXIN_ERROR",
	"PUSH_GETBACK_PASSWORD",
}

local AccountLogin_pb = AccountLogin_pb

-- API_ROOT = "http://game711.tunnel.echomod.cn"
-- API_ROOT = "https://www.yfgame777.com"

local AUTO_CONNECT_DELAY = 1 * 1000

local DEVICE_ID = nil
--是否使用账号登录
local USE_ACCOUNT_LOGIN = true
--是否测试服
local IS_APP_TEST = false
--是否使用三级代理
local ENABLE_PROMOTION = false
--威尼斯三级代理，聚成指定代理，大富豪指定代理，777指定代理

function class:initialize()
    super.initialize(self)
    
    -- MsgAccount:on("REGIST_SUC", self:createEvent("onRegistSuc"))
    -- MsgAccount:on("REGIST_FAIL", self:createEvent("onRegistFail"))
    -- MsgAccount:on("LOGIN_ACCOUNT", self:createEvent("onLoginFail"))
    -- MsgAccount:on("LOGIN_KEY", self:createEvent("onSetSecret"))
    -- MsgAccount:on("SERVERLIST", self:createEvent("onServerList"))

    local EVT = Net.Mgr.EVT
	net.mgr:on(EVT.CONN, self:createEvent("onNetworkConnect"))
	net.mgr:on(EVT.CLOSE, self:createEvent("onNetworkClose"))

    net.msg:on(MsgDef_pb.MSG_ACOUNT_LOGIN, self:createEvent("onLoginResponse"))
    net.msg:on(MsgDef_pb.MSG_PLAYER_OFF_LINE, self:createEvent("onPlayerOffLineResponse"))
    net.msg:on(MsgDef_pb.MSG_OPENACCOUNT_LOGIN, self:createEvent("onLoginOpenResponse"))
    net.msg:on(MsgDef_pb.MSG_GETBACKPASSWD, self:createEvent("onGetBackPassword"))

	self.selectedServerIdx = 1

	self.canLogin = false
	self.autoLogin = false
	self.autoConnectNum = 0
	self.isForceClose = false
	self.promotionInfo = nil

	self.canLoginByCode = true
	self.canLoginByToken = true

	self.isShowBindDialog = true
	self.isShowBindAccount = true
end

function class:getIsTest()
	return IS_APP_TEST
end

function class:isEnabledPromotion()
	return ENABLE_PROMOTION
end

function class:isAccountLogin()
	return USE_ACCOUNT_LOGIN
end

function class:isCanLogin()
	return self.canLogin
end

function class:connect()
	if self:getIsTest() == true then
		-- net.mgr:connect("112.74.62.145", 10005) --测试服
		-- net.mgr:connect("154.223.40.144", 10005) --威尼斯娱乐
		net.mgr:connect("192.168.0.110", 10005) --陈韶威
		
	elseif util:getPlatform() == "win32" then
		-- net.mgr:connect("192.168.0.108", 10005) --付志华
		net.mgr:connect("192.168.0.110", 10005) --陈韶威
		-- net.mgr:connect("112.74.62.145", 10005) --测试服
		 -- net.mgr:connect("47.107.248.127", 10005) --777游戏
		-- net.mgr:connect("154.223.40.144", 10005) --威尼斯娱乐
		-- net.mgr:connect("154.223.40.146", 10005) --大富豪
		
	else
		-- net.mgr:connect("192.168.0.110", 10005) --陈韶威
		-- net.mgr:connect("120.79.140.61", 10005) --正式服
		--net.mgr:connect("192.168.0.108", 10005) --付志华
		-- net.mgr:connect("39.108.73.162", 10005)	--易发棋牌（老叶）
		net.mgr:connect("103.233.254.95", 10005) --聚城娱乐
		-- net.mgr:connect("47.107.248.127", 10005) --777游戏
		--net.mgr:connect("154.223.40.144", 10005) --威尼斯娱乐
		-- net.mgr:connect("154.223.40.187", 10005) --天天娱乐
	end
	ui.mgr:open("Net/Connect")

	self.isForceClose = false
end

function class:onNetworkConnect(succ)
	ui.mgr:close("Net/Connect")

	if succ then
		log("[Account::onNetworkConnect] connect success")
		self.canLogin = true
		if not StageMgr:isStage("Login") then
			--游戏中掉线，自动请求重新加入游戏
			if USE_ACCOUNT_LOGIN or IS_APP_TEST then
				self:relogin()
				-- self:login(self.userInfo.accountId, self.userInfo.password)
			else
				self:weixinTokenLogin()
			end
		else
			if self.autoLogin then
				if USE_ACCOUNT_LOGIN or IS_APP_TEST then
					self:relogin()
					-- self:login(self.userInfo.accountId, self.userInfo.password)
				else
					if self.loginInfo then
						if self.loginInfo.isCode then
							self:weixinLoginByCode(self.loginInfo.info)
						else
							self:weixinLoginByToken(self.loginInfo.info)
						end
					else
						self:weixinTokenLogin()
					end
					-- self:weixinTokenLogin()
				end
				-- self:login(self.userInfo.accountId, self.userInfo.password)

				self.autoLogin = false
			end
		end

		Model:get("Announce"):clear()
	else
		if not StageMgr:isStage("Login") then
			if self.autoConnectNum < 2 then
				self.autoConnectNum = self.autoConnectNum + 1
				self:connect()
				return
			else
				self.autoConnectNum = 0
			end			
		end

		self.canLogin = false
		log("[Account::onNetworkConnect] connect failed")

		local NET_SHOW_MSG = Net.Mgr.NET_SHOW_MSG
		local data = {
			content = NET_SHOW_MSG.CONNECT_SERVER_FAILED,
			okFunc = bind(self.connect, self),
			cancelFunc = bind(self.onLogout, self)
		}
		ui.mgr:open("Dialog/ConfirmDlg", data)

		if USE_ACCOUNT_LOGIN or IS_APP_TEST then
			self:fireEvent(EVT.PUSH_CONNECT_RESULT, false)
		else
			self:fireEvent(EVT.PUSH_WEIXIN_ERROR)
		end
	end
end

function class:onNetworkClose()
	log("Account::onNetworkClose")

	self.canLogin = false
	self.promotionInfo = nil

	if not StageMgr:isStage("Login") and self.isForceClose==false then
		--网络断开后，自动重连
		util.timer:after(AUTO_CONNECT_DELAY, self:createEvent('AUTO_CONNECT_TIMER', 'connect'))

		--[[local NET_SHOW_MSG = Net.Mgr.NET_SHOW_MSG
		local data = {
			content = NET_SHOW_MSG.DISCONNECT_SERVER,
			-- okFunc = bind(self.tryAgainLogin, self)
		}
		ui.mgr:open("Dialog/ConfirmDlg", data)--]]
	end

	sdk.yvVoice:logout()
end

--保存设备id
function class:setDeviceId(deviceId)
	DEVICE_ID = deviceId
end

function class:getDeviceId()
	if not DEVICE_ID then
		--当前帧回调 setDeviceId
		util:fireCoreEvent(REFLECT_EVENT_GET_DEVICE_ID, 0, 0, "")
	end

	return DEVICE_ID
end

function class:relogin()
	if self.loginInfo then
		self:accountLogin(self.loginInfo.name, self.loginInfo.password)
		return
	end

	-- if util:getPlatform() == "win32" then
	-- 	self:win32Login()
	-- 	return
	-- end

	local accountId = db.var:getSysVar("account_login_id")
	local accountName = db.var:getSysVar("account_login_name")
	local accountPassword = db.var:getSysVar("account_login_password")
	-- log(accountName)
	-- log(accountPassword)
	if accountName and accountName~="" and accountPassword and accountPassword~="" then
		--存在账号密码，非游客账号
		self:accountLogin(accountName, accountPassword)
	else
		--游客账号				
		self:visitorlogin()
	end
end

function class:win32Login()
	if not util:fileExist("account.txt") then
		log4ui:warn("win32 login not exist account.txt file")
		return
	end

	local data = util:openFile("account.txt")
    if nil == data or #data == 0 then
    	log4ui:warn("account.txt file data is nil")
        return 
    end

    --读取本地文件。存在设备id时，用设备id登录。否则账号密码登录
    local status, info = pcall(loadstring(data))
    if info.sid then
    	log("win32 visitor login :: device id ===== " .. info.sid)

    	local loginRequest = AccountLogin_pb.AccountLoginRequest()
		loginRequest.account.sid = info.sid
		loginRequest.account.isVisitor = true

		net.msg:send(MsgDef_pb.MSG_ACOUNT_LOGIN, loginRequest:SerializeToString())
    else
    	log("win32 account login :: accountId == " .. info.name .. ", password == " .. info.password)

	    local loginRequest = AccountLogin_pb.AccountLoginRequest()
		loginRequest.account.accountId = info.name
		loginRequest.account.password = info.password
		loginRequest.account.userId = "0"
		net.msg:send(MsgDef_pb.MSG_ACOUNT_LOGIN, loginRequest:SerializeToString())
	end
end

--游客登录
function class:visitorlogin()
	-- local info = 
	-- {
	-- 	sid = sid,
	-- 	isVisitor = isVisitor,
	-- 	-- accountId = name,
	-- 	-- password = password,
	-- }
	-- self.userInfo = info
	-- MsgAccount:post("LOGIN_ACCOUNT", info)

	if not self.canLogin then
		self:connect()
		self.autoLogin = true
		return
	end

	local deviceId = ""
	if util:getPlatform() == "win32" then
		-- self:win32Login()
		-- return
		if not util:fileExist("account.txt") then
			log4ui:warn("win32 login not exist account.txt file")
			return
		end

		local data = util:openFile("account.txt")
	    if nil == data or #data == 0 then
	    	log4ui:warn("account.txt file data is nil")
	        return 
	    end

	    --读取本地文件。存在设备id时，用设备id登录。否则账号密码登录
    	local status, info = pcall(loadstring(data))
	    deviceId = info.sid
	else
		--获取设备id REFLECT_EVENT_GET_DEVICE_ID
		deviceId = self:getDeviceId()
	end

	log("visitor login :: device id ===== " .. deviceId)

	local loginRequest = AccountLogin_pb.AccountLoginRequest()
	loginRequest.account.sid = deviceId
	loginRequest.account.isVisitor = true

	net.msg:send(MsgDef_pb.MSG_ACOUNT_LOGIN, loginRequest:SerializeToString())
end

--账号登录
function class:accountLogin(accountId, password)
	if not self.canLogin then
		self:connect()
		self.autoLogin = true

		self.loginInfo = {name = accountId, password = password}
		return
	end

	local info = 
	{
		accountId = accountId,
		password = password,
	}
	self.userInfo = info

	log("account login :: accountId == " .. accountId .. ", password == " .. password)

	local loginRequest = AccountLogin_pb.AccountLoginRequest()
	loginRequest.account.accountId = accountId
	loginRequest.account.password = password
	-- loginRequest.account.userId = "0"
	loginRequest.account.isVisitor = false

	net.msg:send(MsgDef_pb.MSG_ACOUNT_LOGIN, loginRequest:SerializeToString())
end

function class:onLoginResponse(data)
	local loginResponse = AccountLogin_pb.AccountLoginResponse()
	loginResponse:ParseFromString(data)
	if loginResponse.resultType == AccountLogin_pb.SUCCESS then
		local accountInfo = loginResponse.account

		if self.userInfo == nil then
			self.userInfo = {}
		end

		self.userInfo.accountId = accountInfo.accountId
		-- self.userInfo.password = accountInfo.password
		self.userInfo.userId = accountInfo.userId
		self.userInfo.gold = tonumber(accountInfo.gold)
		self.userInfo.silver = tonumber(accountInfo.sliver)
		self.userInfo.vip = tonumber(accountInfo.vip)
		self.userInfo.nickName = accountInfo.nickName
		self.userInfo.cardNum = tonumber(accountInfo.cardNum) or 0
		self.userInfo.headImage = accountInfo.headImage 	--头像url
		self.userInfo.token = accountInfo.token --令牌，用于访问非游戏服务端时使用，如查询推广信息
		self.userInfo.redeemCode = accountInfo.redeemCode --推广码
		self.userInfo.sex = accountInfo.sex --性别,1-男、2-女
		self.userInfo.personalSign = accountInfo.personalSign or "" --个性签名
		self.userInfo.isPromote = accountInfo.isPromote --是否推广员
		self.userInfo.bankno = accountInfo.bankno --绑定银行卡号
		self.userInfo.sid = accountInfo.sid --手机序列号
		self.userInfo.isVisitor = accountInfo.isVisitor --是否游客
		self.userInfo.pRedeemCode = accountInfo.pRedeemCode --上级推广码

		-- log(self.userInfo)

		db.var:setSysVar("account_login_id", self.userInfo.userId)

		local accountId = self.userInfo.accountId or ""
		db.var:setSysVar("account_login_name", accountId)

		local password = self.userInfo.password or ""
		db.var:setSysVar("account_login_password", password)

		--保存到账号列表
		self:saveAccountData(accountId, password, self.userInfo.userId)

		self:onLoginSuccess()
		-- util.timer:after(500, self:createEvent("onLoginSuccess"))

	else
		local data = {
			content = loginResponse.error
		}
		ui.mgr:open("Dialog/DialogView", data)

		self:fireEvent(EVT.PUSH_LOGIN_ERROR)
	end

	self.loginInfo = nil
end

--找回密码
function class:getBackPassword(accountId, password, verificationCode)
	local request = AccountLogin_pb.GetBackPasswdRequest()
	request.account = accountId
	request.passwd = password
	request.passwd2 = password
	request.verificationCode = verificationCode

	net.msg:send(MsgDef_pb.MSG_GETBACKPASSWD, request:SerializeToString())
end

function class:onGetBackPassword(data)
	local response = AccountLogin_pb.GetBackPasswdResponse()
	response:ParseFromString(data)
	if response.isSuccess then
		self:fireEvent(EVT.PUSH_GETBACK_PASSWORD)
	else
		local errMsg = response.errMsg
		if not errMsg or errMsg == "" then			 
			errMsg = "密码重置失败，请稍后重试！"
		end

		local data = {
			content = errMsg,
		}
		ui.mgr:open("Dialog/DialogView", data)
	end
end

function class:saveAccountData(name, password, id)
	local accountList = db.var:getSysVar("account_list_data")
	if accountList and accountList ~= "" then
		accountList = json.decode(accountList)
	else
		accountList = {}
	end

	local bExist = false
	if id then
		for i, v in ipairs(accountList) do
			if v.id and v.id == id then
				v.name = name
				v.password = password

				bExist = true

				local item = v
				table.remove(accountList, i)

				table.insert(accountList, 1, item)
				break
			end
		end
	end

	if not bExist then
		for i, v in ipairs(accountList) do
			if v.name == name then			
				v.name = name
				v.password = password

				bExist = true

				local item = v
				table.remove(accountList, i)

				table.insert(accountList, 1, item)
				break
			end
		end
	end

	if not bExist then
		local item = 
		{
			id = id,
			name = name, 
			password = password
		}

		table.insert(accountList, 1, item)
	end

	-- log(accountList)

	local saveStr = json.encode(accountList)
	db.var:setSysVar("account_list_data", saveStr)
end

function class:delAccountData(name)
	if name == "" then
		return
	end

	local accountList = db.var:getSysVar("account_list_data")
	if accountList and accountList ~= "" then
		accountList = json.decode(accountList)
	else
		accountList = {}
	end

	for i, v in ipairs(accountList) do
		if v.name == name then
			table.remove(accountList, i)
			break
		end
	end

	local saveStr = json.encode(accountList)
	db.var:setSysVar("account_list_data", saveStr)
end

function class:getAccountData()
	local accountList = db.var:getSysVar("account_list_data")
	if accountList and accountList ~= "" then
		accountList = json.decode(accountList)
	else
		accountList = {}
	end

	return accountList
end

----------------------------微信登录---------------------------------

--微信登录出错
function class:winxinErrorRst(data)
	if data then
		local info = json.decode(data)
		log(info)
		if info.errorType == "WeixinInfo" then
			if tonumber(info.bWeixinInstall) == 0 then
				local data = {
					content = "请先安装微信应用！",
				}
				ui.mgr:open("Dialog/DialogView", data)

			elseif tonumber(info.bWeixinOpenApi) == 0 then
				local data = {
					content = "微信版本过低！",
				}
				ui.mgr:open("Dialog/DialogView", data)
			end
		elseif info.errorType == "ConnectError" then
			local data = {
				content = "网络连接失败！",
			}
			ui.mgr:open("Dialog/DialogView", data)
		end
	end
	self:fireEvent(EVT.PUSH_WEIXIN_ERROR, data)
end

--请求获取微信登录code
function class:weixinLogin()
	local data = { 
		scope = "snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact", 
	   	state = tostring(math.random(1000, 9999))
	}
	data = json.encode(data)
	util:fireCoreEvent(REFLECT_EVENT_WEIXIN_LOGIN, 0, 0, data)
end

function class:weixinTokenLogin()
	local access_token = db.var:getSysVar("access_token")
	if access_token and access_token ~= "" then
		--存在token，则不用获取code。
		local refresh_token = db.var:getSysVar("refresh_token")
		local openid = db.var:getSysVar("openid")
		local data = { 
			access_token = access_token, 
		   	refresh_token = refresh_token,
		   	openid = openid
		}
		data = json.encode(data)
		util:fireCoreEvent(REFLECT_EVENT_WEIXIN_ACCESSTOKEN, 0, 0, data)

		return true
	end

	return false
end

function class:weixinLoginByCode(data)
	if not self.canLogin then
		self:connect()
		self.autoLogin = true

		self.loginInfo = {info = data, isCode = true}
		return
	end

	local info = json.decode(data)
	-- log(info)
	if not info.errcode then
		if self.canLoginByCode then
			local request = OpenAccountLogin_pb.OpaLoginRequest()
			request.platformType = Common_pb.wx
			request.code = info.code
			-- log("[Account::weixinLoginByCode] code:"..info.code..", state:"..info.state)
			net.msg:send(MsgDef_pb.MSG_OPENACCOUNT_LOGIN, request:SerializeToString())

			self.canLoginByCode = false

			util.timer:after(5.0*1000, self:createEvent("ENABLE_LOGIN_CODE", function()
				self.canLoginByCode = true
			end))
		end
	else
		log4model:warn(info.errcode)
	end
end

function class:weixinLoginByToken(data)
	if not self.canLogin then
		self:connect()
		self.autoLogin = true

		self.loginInfo = {info = data, isCode = false}
		return
	end
	
	local info = json.decode(data)
	-- log(info)
	if not info.errcode then
		if self.canLoginByToken then
			local request = OpenAccountLogin_pb.OpaLoginRequest()
			request.platformType = Common_pb.wx
			request.access_token = info.access_token
			request.openid = info.openid
			request.refresh_token = info.refresh_token
			net.msg:send(MsgDef_pb.MSG_OPENACCOUNT_LOGIN, request:SerializeToString())

			self.canLoginByToken = false

			util.timer:after(5.0*1000, self:createEvent("ENABLE_LOGIN_TOKEN", function()
				self.canLoginByToken = true
			end))
		end
	else
		self:weixinLogin()
	end
end

function class:setShareScene(scene, isAward)
	self.shareScene = scene
	self.shareAward = isAward or false
end

function class:weixinShareRst(data)
	if self.shareScene == "SceneSession" and self.shareAward then
		Model:get("User"):requestShareAward()
	end
end

function class:onLoginOpenResponse(data)
	-- log(data)
	local response = OpenAccountLogin_pb.OpaLoginResponse()
	response:ParseFromString(data)
	if response.resultType == AccountLogin_pb.SUCCESS then
		if self.userInfo == nil then
			self.userInfo = {}
		end
		
		local accountInfo = response.accountInfo
		self.userInfo.loginPlatformType = response.platformType
		self.userInfo.access_token = response.access_token
		self.userInfo.openid = response.openid
		self.userInfo.refresh_token = response.refresh_token

		self.userInfo.accountId = accountInfo.accountId
		self.userInfo.userId = accountInfo.userId
		self.userInfo.gold = tonumber(accountInfo.gold)
		self.userInfo.silver = tonumber(accountInfo.sliver)
		self.userInfo.vip = tonumber(accountInfo.vip)
		self.userInfo.nickName = accountInfo.nickName
		self.userInfo.cardNum = tonumber(accountInfo.cardNum) or 0
		self.userInfo.headImage = accountInfo.headImage 	--头像url
		self.userInfo.token = accountInfo.token --令牌，用于访问非游戏服务端时使用，如查询推广信息
		self.userInfo.redeemCode = accountInfo.redeemCode --推广码
		self.userInfo.sex = accountInfo.sex
		self.userInfo.personalSign = accountInfo.personalSign or "" --个性签名
		self.userInfo.isPromote = accountInfo.isPromote --是否推广员
		self.userInfo.bankno = accountInfo.bankno --绑定银行卡号

		-- log("access_token:"..db.var:getSysVar("access_token"))
		-- log("refresh_token:"..db.var:getSysVar("refresh_token"))

		-- log(self.userInfo)

		-- util.timer:after(500, self:createEvent("onLoginSuccess"))
		self:onLoginSuccess()

		--保存
		db.var:setSysVar("access_token", self.userInfo.access_token)
		db.var:setSysVar("refresh_token", self.userInfo.refresh_token)
		db.var:setSysVar("openid", self.userInfo.openid)


	else
		if response.error ~= "" then
			local data = {
				content = response.error
			}
			ui.mgr:open("Dialog/DialogView", data)
		end

		self:fireEvent(EVT.PUSH_LOGIN_ERROR)
	end

	self.loginInfo = nil
end

function class:onLoginSuccess()
	--YY语音登录
	sdk.yvVoice:login(self.userInfo.nickName, self.userInfo.userId)

	--ip、经纬度等信息
	if util:getPlatform() ~= "win32" then
		util:fireCoreEvent(REFLECT_EVENT_GET_LOCATION_MSG, 0, 0, "")
		util:fireCoreEvent(REFLECT_EVENT_GET_IP_ADDRESS, 0, 0, "")

		--保持屏幕常亮
		util:fireCoreEvent(REFLECT_EVENT_KEEP_SCREEN_ON, 1, 0, "")
	end

	self:initUserFile()
end

function class:onPlayerOffLineResponse(data)
	local response = AccountLogin_pb.PlayerOffLineResponse()
	response:ParseFromString(data)
	
	self.isForceClose = true

	local data = {
		content = "你的账号在其他设备登陆！是否重新上线？",
		okFunc = bind(self.connect, self),
		cancelFunc = bind(self.onLogout, self),
	}
	ui.mgr:open("Dialog/ConfirmDlg", data)
end

function class:onLogout()
	net.mgr:disconnect()			
	StageMgr:chgStage("Login", false)
end

function class:onLoginFail(data)
	self.userInfo = nil
	local info =
	{
		content = data.content,
		color = cc.c3b(239, 17, 39),
		fontSize = 30,
	}
	ui.confirm:popup(info)
end

function class:onServerList(data)
	log4login:info("server list:\n" .. table.tostring(data))
 	self.serverList = data.list
 	self.userKey = data.userKey

 	local lastServerId = db.var:getSysVar("LastSelectedServer")
 	if lastServerId then
	 	self.selectedServerIdx = self:getServerIdxById(lastServerId)
 	end

	ui.mgr:open("Login/ServerList", data.list)
end

function class:selectServer(info)
	local idx = -1
	for i, data in ipairs(self.serverList) do
		if info.serverID == data.serverID then
			idx = i
			break
		end
	end
	
	if idx == -1 then
		return
	end
	self.selectedServerIdx = idx
	db.var:setSysVar("LastSelectedServer", info.serverID)
end

function class:getServerIdxById(id)
	for idx, info in ipairs(self.serverList) do
		if info.serverID == id then
			return idx
		end
	end
	return -1
end

function class:onSetSecret(data)
	log4login:info("Account onSetSecret:" .. data.key)
	net.mgr:setSecretKey(data.key)

	self:fireEvent(EVT.SETSECRET, data)
end


function class:getUserInfo()
	return self.userInfo
end

function class:getUserId()
	return self.userInfo.userId
end

function class:updateUserInfo(data)
	if data.gold ~= nil then
		self.userInfo.gold = data.gold
	end

	if data.silver ~= nil then
		self.userInfo.silver = data.silver
	end

	if data.vip ~= nil then
		self.userInfo.vip = data.vip
	end

	if data.cardNum ~= nil then
		self.userInfo.cardNum = data.cardNum
	end
end

function class:getLoginServer()
	return self.serverList[self.selectedServerIdx]
end

function class:initUserFile()
	local userfile = self:getUserId()
	userfile = "var_" .. util:md5(userfile)
	-- log(userfile)

 	db.var:setUsrVarFileName(userfile)
 end

function class:setIsShowBindDialog(var)
 	self.isShowBindDialog = var
 end

function class:getIsShowBindDialog()
 	if not self.userInfo.redeemCode or self.userInfo.redeemCode=="" then
	 	return self.isShowBindDialog
	else
		return false
	end
 end

 function class:setIsShowBindAccount(var)
 	self.isShowBindAccount = var
 end

function class:getIsShowBindAccount()
	if self.userInfo.isVisitor then
		return self.isShowBindAccount
	else
		return false
	end
 end

function class:getPromotionInfo(callback)
	--读取sdk/proxy/autopatch.dat 配置文件
	local config = sdk.config:getConfig("server", "autopatch")
	local url = config.promotionUrl
	-- local zoneId = config.zoneId or 1
	-- local serverId = config.serverId or 10
	url = string.format(url, self.userInfo.userId, self.userInfo.token)
	-- local url = string.format("%s/AppVersion/promotion?playerId=%s&token=%s", API_ROOT, self.userInfo.userId, self.userInfo.token)
	-- log(url)

	if self.promotionInfo == nil then
		ui.mgr:open("Net/Connect")

		local xhr = cc.XMLHttpRequest:new()
	    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	    xhr:open("GET", url)

	   	xhr:registerScriptHandler(function()
			log("xhr.readyState is:" .. xhr.readyState .. " xhr.status is:" .. xhr.status)
			if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
				local data = xhr.response
				-- log(data)

				local info = json.decode(data)
				if info == nil or info.ack_code ~= "SUCCESS" then
					local data = {
						content = "无法获取推广信息，请稍后再试！",
					}
					ui.mgr:open("Dialog/DialogView", data)
				else
					self.promotionInfo = info
					callback(self.promotionInfo)
				end
			else
				local data = {
					content = "无法获取推广信息，请稍后再试！",
				}
				ui.mgr:open("Dialog/DialogView", data)
			end

			ui.mgr:close("Net/Connect")

			xhr:unregisterScriptHandler()
		end)

	    xhr:send()
	else
		callback(self.promotionInfo)
	end
end
