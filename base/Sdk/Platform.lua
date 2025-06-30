module(..., package.seeall)


class = objectlua.Object:subclass()

function class:initialize(...)
	super.initialize(self)

	self:initPlatformInfo()
end

function class:dispose()
	super.dispose(self)
end

function class:getInfo(key)
	return self.platformInfo[string.lower(key)]
end

function class:isDevMode()
	return self:getInfo("devMode")
end

function class:checkConfig()
	if self:getInfo("platformid") then
		return true, nil
	end
	local proxyId = self:getInfo("proxyId")
	local err = proxyId .. ' not configed in operator.dat'
	return false, err
end

function class:getResVerion()
	--整包中的版本号
	local verInPack = util:openFile("config/resver.ini")
	if verInPack then
		verInPack = string.gsub(verInPack, "%s", "")
		verInPack = verInPack and tonumber(verInPack) or 0
	end

	--更新过散包的最新版本号
	local saveResVer = db.var:getSysVar(GV_RES_VER)
	saveResVer = saveResVer and tonumber(saveResVer) or 0 

	return verInPack > saveResVer and verInPack or saveResVer
end

function class:saveResVerion(ver)
	db.var:setSysVar(GV_RES_VER, ver)
end

function class:getUIShowVersion()
	local packVer = self:getInfo("versionName")
	local resVersion = self:getResVerion()
	resVersion = string.sub(resVersion, -6, -1)
	return packVer .. ":" .. resVersion
end


function class:initSdk()
	-- "sdkInfo": {
	-- 	"appId": "100003",
	-- 	"appKey": "4b8bf763f720bf17b5a4f33f17b18ab6"
	-- },
	local data = sdk.config:getConfig('sdkInfo', 'config')
	data = json.encode(data or {}) or ''
	util:fireCoreEvent(REFLECT_EVENT_INIT_SDK, 0, 0, data)

	--呀呀语音sdk初始化
	sdk.yvVoice:initSdk()
end



--------------private-----------------
--
function class:initPlatformInfo()
	local info = {}
	local root = CEnvRoot:GetSingleton() 
	local variable = CVariableSystem:GetSingleton()

	info["versionapp"] 	= tonumber(variable:GetSysVariable(GV_VERSION))
	info["versionname"] = root:GetVersionName()
	info["versionexe"] 	= tonumber(variable:GetSysVariable(GV_EXE_VER))
	info["devicename"] 	= variable:GetSysVariable(GV_DEVICE_NAME)
	info["identifier"] 	= variable:GetSysVariable(GV_PKG_IDENTIFIER)
	info["uniqueid"] 	= root:GetUniqueId()
	info["idfa"] 		= root:GetIdfa()
	info["idfv"] 		= variable:GetSysVariable(GV_IDFV)
	info["mac"] 		= root:GetMacAddr()
	info["proxyid"] 	= root:GetOperatorProxyId()
	info["proxypath"] 	= variable:GetSysVariable(GV_OPERATORPATH)

	info["platformid"] 	= sdk.config:getConfig("id", "platform")
	info["platformname"]= sdk.config:getConfig("name", "platform")
	info["devmode"] 	= sdk.config:getConfig("devMode", "platform")

	self.platformInfo = info
	log(self.platformInfo)

end





