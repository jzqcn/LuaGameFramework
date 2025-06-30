--------------------------------------------------
-- 版本更新管理类
--
-- 2017.3.2
--------------------------------------------------
module(..., package.seeall)

local Version = require "AutoPatch.Version"
local Package = require "AutoPatch.Package"
local Asset   = require "AutoPatch.Asset"
local GameAsset = require "AutoPatch.GameAsset"

local ENABLE_AUTOPATCH = true

EVT = enum
{
	'CHECK_PASS',			        -- 自动更新检测通过
	'DOWNLOAD_ASSET',				-- 下载asset

	'PATCH_START',			        -- 自动更新开始
	'PATCH_SUC',			        -- 应用更新成功


	'CONNECT_VERSION_SERVER_FAIL',  -- 连接版本服务器失败
	'VERSION_IS_EMPTY',             -- 版本文件为空
	'CHECK_VERSION_FAIL',	        -- 检查版本文件失败	
	'REFUSE_UPDATE_VERSION',	    -- 拒绝更新到最新版本
	'STORAGE_NOT_ENOUGH',	        -- 可用存储空间不足
	'DOWN_ZIP_FAIL',		        -- 下载Zip包失败
	'MOVE_FILE_FAIL',		        -- 移动更新文件失败
	
	'ERROR',				        -- 错误提示
}

-- API_ROOT = "http://192.168.0.108:8080/AppVersion/appversion?module="

class = Events.class:subclass()

function class:initialize()
	super.initialize(self)

	self.version = Version.class:new(self)
	self.package = Package.class:new(self)
	self.asset = Asset.class:new(self)
	self.gameAsset = GameAsset.class:new(self)

	self.checkedGameVer = {}
end

function class:dispose()
	self.gameAsset:dispose()
	self.asset:dispose()
	self.package:dispose()
	self.version:dispose()

	super.dispose(self)
end

function class:start()
	log4patch:info("[=AutoPatch.Mgr:start]=")

	if ENABLE_AUTOPATCH and util:getPlatform() ~= "win32" then
		self.version:start()
	else
		self:checkPass()
	end
end

function class:checkCanAutoPatch()
	local versionInfo = self.version:getInfo()
	if versionInfo == nil or versionInfo.program == nil then
		return true
	end

	local platformType = util:getPlatform()
	local package
	if platformType == "ios" then
		package = versionInfo.ios
	elseif platformType == "android" then
		package = versionInfo.android
	end

	if package == nil then
		return true
	end

	local versionApp = sdk.platform:getInfo("versionApp")
	if versionInfo.program <= package then
		return true
	end

	-- appstore版本审核中 不允许更新
	-- program可以认为是当前审核中的版本号
	if versionApp >= versionInfo.program and platformType == "ios" then
		return false
	end
	return true
end

function class:checkPass()
	log4patch:info("[=AutoPatch.Mgr:checkPass]")
	sdk.platform:initSdk()
	self:fireEvent(EVT.CHECK_PASS)
end

function class:downloadPackage(andorid_url, ios_url)
	self.package:start(andorid_url, ios_url)
end

function class:downloadAsset()
	self:fireEvent(EVT.PATCH_START)
	self.asset:start()
end

function class:onDownLoadingAsset(recv, total)
	self:fireEvent(EVT.DOWNLOAD_ASSET, recv, total)
end

function class:onAssetFinish()
	self:fireEvent(EVT.PATCH_SUC)
	util.timer:after(1000, function ()
		util:rebootGame()
	end)
end



function class:isCheckedGameVer(var)
	return self.checkedGameVer[var]
end

function class:setCheckedGameVer(var)
	self.checkedGameVer[var] = true
end

function class:gameVertionStart(gameName, event)
	-- if util:getPlatform() ~= "win32" then
		self.gameAsset:checkVersion(gameName, event)
	-- end
end

function class:gameDownloadStart(info)
	-- if util:getPlatform() ~= "win32" then
		self.gameAsset:startDownload(info)
	-- end
end

function class:gameDownloadStop(flag)
	self.gameAsset:stopDownload(flag)
end


----------------assist----------------
--
function class:promptGM(content, func)
	local info = 
	{
		content = content,
		okFunc = func,
		okBtnTitle = "重试",
		cancelBtnTitle = "联系客服",
		cancelFunc = function () sdk.feedback:contactGM() end,
	}
	ui.confirm:open(info)
end

function class:promptExit(content, func)
	local info
	if type(content) == "table" then
		info = content
	else
		info = 
		{
			content = content,
			okFunc = func,
			okBtnTitle = "重试",
			cancelBtnTitle = "退出",
			cancelFunc = function () util:exitGame() end,
		}
	end
	ui.confirm:open(info)
end

function class:formatPlatformUri(url, module, zoneId, serverId)
	--格式说明：
	-- "ver": "/client/autopatch/res/%s/%s_%s/%s/version.xml",
	-- res/gameName/platfromId_platformName/deviceName/version.xml
	-- gameName: congfig.dat中配置  "gameName": "game1",
	-- platfromId_platformName: platform.dat中配置   1_myDev
	-- deviceName: 设备类型 ios ard w32   
	-- local gameName = sdk.config:getGameName()
	-- local platformId = sdk.platform:getInfo("platformId")
	-- local platformName = sdk.platform:getInfo("platformName")
	-- local deviceName = sdk.config:getDeviceConfigName()

	-- local str = string.format(url, gameName, platformId, platformName, deviceName)
	zoneId = zoneId or 1
	serverId = serverId or 10

	--test
	-- url = "http://192.168.0.108:8080/AppVersion/appversion?module=%s&zoneId=%d&serverId=%d"

	local str = string.format(url, module, zoneId, serverId)
	return str
end

function class:httpRequest(host, port, uri, event)
	log4patch:info(string.format(
			"[=AutoPatch.Mgr:httpRequest] host:%s port:%d uri:%s", 
			host, port, uri))

	local info = {}
	info.ip = host
	info.port = port 
	info.uri = uri
	info.method = "GET"

	local reqId = net.http:send(info, event)
	net.monitor:addIgnore(reqId)
end



