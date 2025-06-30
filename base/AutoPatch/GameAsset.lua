module(..., package.seeall)

class = Events.class:subclass()

function class:initialize(mgr)
	super.initialize(self)
	self.mgr = mgr
	self.assetsManagers = {}
	self.reqId = 0
end

function class:dispose()
	super.dispose(self)

	for k, v in pairs(self.assetsManagers) do
		if v ~= nil then
			v:release()
		end
	end

	self.assetsManagers = nil
end

function class:checkVersion(gameName, event)
	if not gameName or gameName == "" then
		return
	end

	ui.mgr:open("Net/Connect")

	self.reqId = self.reqId + 1

	local reqId = self.reqId
	self:bindEvent(reqId, event)

	-- local API_ROOT = AutoPatch.Mgr.API_ROOT
	-- local url = string.format("%s%s", API_ROOT, string.lower(gameName))

	local config = sdk.config:getConfig("server", "autopatch")
	local gameModule = string.lower(gameName)
	local zoneId = config.zoneId or 1
	local serverId = config.serverId or 10

	local url = self.mgr:formatPlatformUri(config.ver, gameModule, zoneId, serverId)

	-- log(url)

	local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr.reqId = reqId
    xhr.gameName = gameName
    xhr:open("GET", url)    

   	xhr:registerScriptHandler(function()
		log("xhr.readyState is:" .. xhr.readyState .. " xhr.status is:" .. xhr.status)
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			local data = xhr.response
			self:fireEvent(xhr.reqId, xhr.gameName, data)
		else
			self:fireEvent(xhr.reqId, xhr.gameName)
		end

		ui.mgr:close("Net/Connect")

		xhr:unregisterScriptHandler()
	end)

    xhr:send()
end

function class:startDownload(info)
	if nil == info then
		return
	end

	local _downFile = function()
		self:downloadByInfo(info)
	end

	local totalSize = info.size
	if totalSize > (1 * 1024 * 1024) and util:getPlatform() ~= "win32" and NETWORK_WIFI ~= util:getNetType() then
		local tip = "资源包大于%sM，设备不在WiFi网络下，是否继续更新？"
		tip = string.format(tip, math.floor(totalSize / (1024 * 1024)))
		self.mgr:promptExit({content=tip, okBtnTitle="确定", okFunc=_downFile})
		return
	end

	_downFile()
end

function class:downloadByInfo(info)
	-- log(info)
	
	if not self:checkAvaliableStorageSize(info.size) then
		local tip = "可用存储空间过低，无法完成自动更新，请释放空间后重试！"
		self.mgr:promptExit({content=tip, okBtnTitle="确定"})
		return
	end

	local size = lfs.attributes(info.filepath, "size") or 0
	if size >= info.size then
		info.onSuccess()
		return
	end

	local assetsManager = self.assetsManagers[info.flag]
	if assetsManager ~= nil then
		assetsManager:release()
        assetsManager = nil
	end

	if assetsManager == nil then
		assetsManager = cc.AssetsManager:new(info.url, "", info.filepath)
	    assetsManager:retain()
	    assetsManager:setDelegate(info.onError, cc.ASSETSMANAGER_PROTOCOL_ERROR)
	    assetsManager:setDelegate(info.onProgress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
	    assetsManager:setDelegate(info.onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS)
	    assetsManager:setConnectionTimeout(3)

	    self.assetsManagers[info.flag] = assetsManager
    end    

    assetsManager:checkUpdate()
end

function class:downloadFinish(info)

end

function class:stopDownload(flag)
	local assetsManager = self.assetsManagers[flag]
	if assetsManager ~= nil then
		assetsManager:release()
        assetsManager = nil
        self.assetsManagers[flag] = nil

        -- log("stopDownload flag ============ " .. flag)
	end
end


--------------internal-----------------
function class:checkAvaliableStorageSize(totalSize)
	local avaliableSize = util:getAvaliableStorageSize()
	if 0 == avaliableSize then 
		return true 
	end

	--可用空间(单位为MB)要求大于下载包大小(单位为Byte)的3倍
	return avaliableSize > (totalSize * 3 / (1024 * 1024))
end
