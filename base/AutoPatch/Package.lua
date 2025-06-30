module(..., package.seeall)

local EVT = AutoPatch.Mgr.EVT

class = Events.class:subclass()

function class:initialize(mgr)
	super.initialize(self)
	self.mgr = mgr
end

function class:dispose()
	super.dispose(self)
end

function class:start(andorid_url, ios_url)
	log4patch:info("[=11AutoPatch.Package:start]")

	local config = sdk.config:getConfig("server", "autopatch")

	-- --整包版本信息
	-- local versionUri = self.mgr:formatPlatformUri(config.package)
	-- local versionUrl = net.http:getUrl(config.host, config.port, versionUri)

	-- --放安装包的地方
	-- local gameName = sdk.config:getGameName()
	-- local downPackage = string.format(config.downPackage, gameName)
	-- local downUrl = net.http:getUrl(config.downHost, config.downPort, config.downPackage)

	local versionUrl = ""
	local downUrl = ""
	if util:getPlatform() == "ios" then
		downUrl = ios_url
	elseif util:getPlatform() == "android" then
		downUrl = andorid_url
	end
	
	self:checkUpdate(versionUrl, downUrl, config.timeOut) 
end

function class:checkUpdate(versionUrl, downUrl, timeOut)
	log4patch:info("[=12AutoPatch.Package:checkUpdate] verUrl:" 
			.. versionUrl .. " downUrl:" .. downUrl)
	local data = { versionUrl 	= versionUrl, 
				   downUrl 		= downUrl,
				   timeOut 		= timeOut, }

	data = json.encode(data)
	util:fireCoreEvent(REFLECT_EVENT_CHECK_UPDATE, 0, 0, data)
end





