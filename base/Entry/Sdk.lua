


function OnPackageUpdateFinish()
	--只有配置错误 或 获取的配置信息没有新的版本 才会调用回这里
	--正常lua已经判断过文件内容  以及是否有新版本  是不会再出现这种情况的
	--而是直接走整包更新流程 下载完后安装新包
	--可留作错误检测
	log4misc:warn("update package error.")
end

function OnLogin(nFlag, acct)
	local co = coroutine.create(function(ret)
		Logic:Get('AcctAdpt'):OnLogin(ret)
	end)

	if 0 ~= nFlag or nil == acct then
		coroutine.resume(co, {ret = false, tip = '登录返回数据为空'})
		return
	end

	acct = json.decode(acct)
	if type(acct) ~= 'table' then
		coroutine.resume(co, {ret = false, tip = '登录返回数据错误'})
		return
	end

	if nil ~= acct.checkSidFuncParam then
		co = coroutine.create(function()
            local param = acct.checkSidFuncParam
			local ret, tip, user = Singleton(Sdk):CheckSid(param)
            user = table.merge(user, { ret = ret, tip = tip })
			Logic:Get('AcctAdpt'):OnLogin(user)
		end)

		coroutine.resume(co)
		return
	end

	acct.nickName = (acct.nickName ~= "") and acct.nickName or nil
	coroutine.resume(co, {
        ret             = true,
        userId          = tostring(acct.userId),
        nickName        = acct.nickName or ('用户' .. acct.userId), 
        ext             = acct.extParam,
        tencentLoginRet = acct.tencentLoginRet,
    })
end

function OnLogout()
	local co = coroutine.create(function()
		Logic:Get('AcctAdpt'):OnLogout(true)
	end)

	coroutine.resume(co)
end

function OnServerLst(serverLst)
	local servers = json.decode(serverLst)
	if not servers or not servers.list then 
        local tip = '服务器列表数据为空'
		Singleton(Server):OnQueryServerLst({ret = false, tip = tip})
		return
	end

	servers = Singleton(Sdk):OnSeverList(servers.list)
    local ret = Singleton(Server):InitServerLst(servers)
    local tip = ret and '' or '解析服务器列表数据失败'
	Singleton(Server):OnQueryServerLst({ret = ret, tip = tip})
end

function OnDeviceToken(nFlag, strData)
	-- Singleton(ComLogic):SetDeviceToken(nFlag, strData)
end

function OnAPPItemBuyed(data)
	Singleton(EnvLogic):SetAppStorePayRst(data)
end

function CheckOperate()
end

-- deprecated

function SetSdkFuncStatus(strFlag, nStatus)
end

function SetFBShareRst(strData)
	Singleton(Promote):SetFBShareRst(strData)
end

function SetGooglePlusLoginRst( strData )
	Singleton(Promote):SetGooglePlusLoginRst(strData)
end

function SetGooglePlusUserInfoRst(strData)
	Singleton(Promote):SetGooglePlusUserInfoRst(strData)
end

function SetGooglePayRst( strData )
	Singleton(EnvLogic):SetGooglePayRst(strData)
end

function SetGooglePayConsumeRst( strData )
	Singleton(EnvLogic):SetGooglePayConsumeRst(strData)
end

function SetGooglePayGetPriceRst( Info )
	Singleton(EnvLogic):SetGooglePayGetPriceRst(Info)
end

function SetGooglePayGetInventoryRst( Info )
	Singleton(EnvLogic):GooglePayGetInventoryRst(Info)
end

function SetWeiBoLoginRst( strData )
	Singleton(Promote):SetWeiBoLoginRst(strData)
end

function SetGameCenterLoginRst(strData)
	Singleton(Promote):SetGameCenterLoginRst(strData)
end

function SetFBLoginRst(strData)
	Singleton(Promote):SetFBLoginRst(strData)
end

function SetFBcurrentAccessTokenRst(strData)
	Singleton(Promote):SetFBcurrentAccessTokenRst(strData)
end

function SetFBLogoutRst(strData)
	Singleton(Promote):SetFBLogoutRst(strData)
end

function SetFBgetUserInfoRst(strData)
	Singleton(Promote):SetFBgetUserInfoRst(strData)
end

function SetCallHttpLinkRst(strData)
	Singleton(Promote):SetCallHttpLinkRst(strData)
end

function SetFBPermissionsRst(strData)
	Singleton(Promote):SetFBPermissionsRst(strData)
end

function SetFBGameRequestRst(strData)
	Singleton(Promote):SetFBGameRequestRst(strData)
end

function SetFBGameInviteRst(strData)
	Singleton(Promote):SetFBGameInviteRst(strData)
end

function SetWeixinErrorRst(strData)
	Model:get("Account"):winxinErrorRst(strData)
end

--微信登录授权code返回
function SetWeixinCodeRst(strData)
	Model:get("Account"):weixinLoginByCode(strData)
end

--微信登录请求token返回
function SetWeixinTokenRst(strData)
	Model:get("Account"):weixinLoginByToken(strData)
end

--微信分享结果
function SetWeixinShareRst(strData)
	-- Model:get("Account"):weixinShareRst(strData)
	-- Singleton(Promote):SetWeixinShareRst(strData)
end

function SetQQShareRst(strData)
	Singleton(Promote):SetQQShareRst(strData)
end

--获取设备ID
function GetDeviceIdRst(strData)
	Model:get("Account"):setDeviceId(strData)
end

function GetWiFiIdRst(strData)
	-- Singleton(EnvLogic):GetWiFiIdRst(strData)
end

function GetWiFiIdExRst(strData)
	-- Singleton(EnvLogic):GetWiFiIdExRst(strData)
end

function GetAndroidIdRst(strData)
	Singleton(EnvLogic):GetAndroidIdRst(strData)
end

function GetAndUniqueIdRst(strData)
	Singleton(EnvLogic):GetAndUniqueIdRst(strData)
end

function OnOpenUrlRst(rst)
	Singleton(Promote):OnOpenUrlRst(rst)
end

function OnSetPlatformInfo(strInfo)
	local info
	local succ, msg = pcall(function() 
		info = json.decode(strInfo)
	end)

	if succ then
		Singleton(ComLogic):SetOperatorProxyInfo(info)
	end
end

function OnGetHostByNameRst(rst)
	NetCenter:getSingleton():OnGetHostByNameRst(rst)
end

function GetLocationMsgRst(strData)
	if strData and strData ~= "" then
		local info = json.decode(strData)
		local latitude = tostring(info.latitude)
		local longitude = tostring(info.longitude)
		Model:get("Position"):setUserPosition(longitude, latitude)
	end
end

function GetAddressRst(strData)
	-- Model:get("Position"):setPlayerAddress(strData)
end

function GetIPAddressRst(strData)
	if strData then
		Model:get("Position"):setUserIpAddress(strData)
	end
end
