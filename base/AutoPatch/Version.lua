module(..., package.seeall)

class = Events.class:subclass()

function class:initialize(mgr)
	super.initialize(self)
	self.mgr = mgr
end

function class:dispose()
	super.dispose(self)
end

function class:getInfo()
	assert(self.versionInfo)
	return self.versionInfo
end

function class:start()
	log4patch:info("[=01AutoPatch.Version:start]")
	if self:existEvent("CHECK_VERSION") then
		log4patch:warn('AutoPatch.Version check twise!')	
		return
	end

	ui.mgr:open("Net/Connect")

	-- local API_ROOT = AutoPatch.Mgr.API_ROOT
	-- local url = string.format("%s%s", API_ROOT, "main")
	--读取sdk/proxy/autopatch.dat 配置文件
	local config = sdk.config:getConfig("server", "autopatch")
	local appModule = config.appModule or "main"
	local zoneId = config.zoneId or 1
	local serverId = config.serverId or 10

	local url = self.mgr:formatPlatformUri(config.ver, appModule, zoneId, serverId)
	log("Version::start url : " .. url)

	local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("GET", url)

   	xhr:registerScriptHandler(function()
		log("xhr.readyState is:" .. xhr.readyState .. " xhr.status is:" .. xhr.status)
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			local data = xhr.response
			self:onCheckVersion(0, data)
		else
			self:onCheckVersion(-1)
		end

		ui.mgr:close("Net/Connect")

		xhr:unregisterScriptHandler()
	end)

    xhr:send()
end

function class:onCheckVersion(code, data)
	log4patch:info("[=02AutoPatch.Version:onCheckVersion]" .. "code:" .. code)
	self:cancelEvent('CHECK_VERSION')
	--{"andorid_url":"","ios_url":"","resource":0,"android":0,"ios":0}
	local err 
	local version
	if code ~= 0 then
		err = string.format("亲，网络不给力哦\n请检查一下网络吧！")
	else
		data = tostring(data)
		if '' == data then
			err = "版本文件内容为空，是否重试？"
		else
			version = json.decode(data)
			if version == nil or version.android == nil or version.ios == nil or version.resource == nil then
				err = "版本文件内容错误，是否重试？"
			end
		end
	end
	
	if err then
		local retry = bind(self.start, self)
		self.mgr:promptExit(err, retry)
		return
	end

	self.versionInfo = version
	self:dealVersionData(version)
end

function class:dealVersionData(version)
	if not self.mgr:checkCanAutoPatch() then
		self.mgr:checkPass()
		return
	end

	local versionApp = sdk.platform:getInfo("versionApp")
	-- log("versionApp:"..versionApp)
	-- log(version)
	if util:getPlatform() == "ios" and versionApp < version.ios then
		log4patch:info("[=03AutoPatch.Version:dealVersionData] package ver:" .. versionApp .. " newver:" .. version.ios)
		self.mgr:downloadPackage(version.andorid_url, version.ios_url)
		return
	elseif util:getPlatform() == "android" and versionApp < version.android then
		log4patch:info("[=03AutoPatch.Version:dealVersionData] package ver:" .. versionApp .. " newver:" .. version.android)
		self.mgr:downloadPackage(version.andorid_url, version.ios_url)
		return
	end

	local resVer = sdk.platform:getResVerion()
	if resVer < version.resource then
		log4patch:info("[=04AutoPatch.Version:dealVersionData] asset ver:" .. resVer .. " newver:" .. version.resource)
		self.mgr:downloadAsset()
		return
	end

	self.mgr:checkPass()
end




