module(..., package.seeall)


local DOWNFILE_RETRY_TIMES = 1

class = Events.class:subclass()

function class:initialize(mgr)
	super.initialize(self)
	self.mgr = mgr
end

function class:dispose()
	super.dispose(self)

	if nil ~= self.assetsManager then
        self.assetsManager:release()
        self.assetsManager = nil
    end
end

function class:start()
	log4patch:info("[=21AutoPatch.Asset:start]")
	-- if self:existEvent("CHECK_VERSION") then
	-- 	log4patch:info('AutoPatch.Asset check twise!')	
	-- 	return
	-- end

	ui.mgr:open("Net/Connect")

	-- local API_ROOT = AutoPatch.Mgr.API_ROOT
	-- local url = string.format("%s%s", API_ROOT, "resource")

	local config = sdk.config:getConfig("server", "autopatch")
	local resModule = config.resModule or "resource"
	local zoneId = config.zoneId or 1
	local serverId = config.serverId or 10

	local url = self.mgr:formatPlatformUri(config.ver, resModule, zoneId, serverId)


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
	log4patch:info("[=22AutoPatch.Asset:onCheckVersion]" .. "code:" .. code .. " data:" .. tostring(data))
	self:cancelEvent('CHECK_VERSION')
	
	local err 
	local version
	if code ~= 0 then
		err = string.format("亲，网络不给力哦\n请检查一下网络吧")
	else
		if '' == data then
			err = "资源版本文件内容为空，是否重试？"
		else
			version = json.decode(data)
			if nil == version or version.ack_code == "FAIL" then
			  	err = "资源版本文件内容错误，是否重试？"
			end
		end
	end
	
	if err then
		self.mgr:promptExit(err, bind(self.start, self))
		return
	end

	self.versionInfo = version
	self:dealVersionData()
end

function class:dealVersionData()
	-- assets.xml
	-- [{
	--     "md5":"798f69427c0a280e3d7c805ec7dd033c",
	--     "size":2575828,
	--     "url":"ow/1_eyDev/ard/291289.zip",
	--     "version":291289
	--   },{
	--     "md5":"2571c027acd3e4363f4afd1f53d828e1",
	--     "size":2602587,
	--     "url":"ow/1_eyDev/ard/291239.zip",
	--     "version":291239
	-- }]
	-- table.sort(self.versionInfo, function(l, r)
	-- 	return l.version < r.version
	-- end) 

	-- {"flag":"resource","size":18265,"version":18072014,"url":"http://192.168.0.108/app/resource.zip","md5":"394648e1f117272c9bfd4124592477ba"}
	local resVer = sdk.platform:getResVerion()
	-- for i = #self.versionInfo, 1, -1 do
	-- 	local info = self.versionInfo[i]
	-- 	if info.version and info.version <= resVer then
	-- 		table.remove(self.versionInfo, i)
	-- 	else
	-- 		local filename = string.match(info.url, '.+/([^/]*%.%w+)$')
	-- 		local dir = db.var:getDocDir('zip_tmp')
	-- 		info.filepath =  dir .. '/' .. filename
	-- 	end
	-- end

	local info = self.versionInfo
	-- log("asset ver:" .. resVer .. " newver:" .. info.version)
	if info.version <= resVer then
		self.versionInfo = nil
	else
		local dir = db.var:getDocDir('zip_tmp')
		info.filepath = dir .. '/' .. info.flag ..".zip"
	end

	-- log("filepath : "..info.filepath)
	-- if #self.versionInfo <= 0 then
	if not self.versionInfo then
		log4patch:info('error, please check assets.xml')

		local err = "资源版本文件内容错误，是否重试？"
		local retry = bind(self.start, self)
		self.mgr:promptExit(err, retry)
		return
	end

	self:startDownload()
end

function class:startDownload()
	log4patch:info("[=23AutoPatch.Asset:startDownload]")

	self.curDown = 1
	self.retryTimes = {}
	self.downSizeInfo = {downloadFile = 0, curFile = 0}
	local _downFile = function()
		-- self:downloadByInfo(self.versionInfo[self.curDown])
		self:downloadByInfo(self.versionInfo)
	end

	local totalSize = self:getTotalSize()
	if totalSize > (1 * 1024 * 1024) and util:getPlatform() ~= "win32" and NETWORK_WIFI ~= util:getNetType() then
		local tip = "资源包大于%sM，设备不在WiFi网络下，是否继续更新？"
		tip = string.format(tip, math.floor(totalSize / (1024 * 1024)))
		self.mgr:promptExit({content=tip, okBtnTitle="确定", okFunc=_downFile})
		return
	end

	_downFile()
end

function class:getTotalSize()
	if self.totalSize then
		return self.totalSize
	end

	local totalSize = self.versionInfo.size
	-- for _, info in ipairs(self.versionInfo) do
	-- 	if info.size then
	-- 		totalSize = totalSize + info.size
	-- 	end
	-- end
	self.totalSize = totalSize
	return totalSize
end

function class:onError(errorCode)
	if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
       	local err = "资源版本文件内容错误，是否重试？"
		local retry = bind(self.start, self)
		self.mgr:promptExit(err, retry)
    elseif errorCode == cc.ASSETSMANAGER_NETWORK then
        log4patch:info("network error")
        local tip = "亲，网络不给力哦\n请检查一下网络吧"
        self.mgr:promptExit(tip, bind(self.start, self))
    end
end

function class:onProgress(percent)
	local recv = self:getTotalSize() * (percent / 100)
    self.mgr:onDownLoadingAsset(recv, self:getTotalSize())
end

function class:onSuccess()
	self:onDownloadFile(0)
end

function class:getAssetsManager()
	if self.assetsManager == nil then
        local assetsManager = cc.AssetsManager:new(self.versionInfo.url, "", self.versionInfo.filepath)
        assetsManager:retain()
        assetsManager:setDelegate(bind(self.onError, self), cc.ASSETSMANAGER_PROTOCOL_ERROR)
        assetsManager:setDelegate(bind(self.onProgress, self), cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
        assetsManager:setDelegate(bind(self.onSuccess, self), cc.ASSETSMANAGER_PROTOCOL_SUCCESS)
        assetsManager:setConnectionTimeout(3)

        self.assetsManager = assetsManager
	end
    
    return self.assetsManager
end

  -- {
  --   "file": doc + "zip_tmp/" + url
  --   "md5":"798f69427c0a280e3d7c805ec7dd033c",
  --   "size":2575828,
  --   "url":"ow/1_eyDev/ard/291289.zip",
  --   "version":291289
  -- },
function class:downloadByInfo(verInfo)
	log4patch:info("[=24AutoPatch.Asset:startDownload] idx:" .. self.curDown)

	if not self:checkAvaliableStorageSize() then
		local tip = "可用存储空间过低，无法完成自动更新，请释放空间后重试！"
		self.mgr:promptExit({content=tip, okBtnTitle="确定"}, function() util:exitGame() end)
		return
	end

	local size = lfs.attributes(verInfo.filepath, "size") or 0
	self.downSizeInfo.curFile = size
	if size >= verInfo.size then
		self:onDownloadFile(0)
		return
	end

	self:getAssetsManager():checkUpdate()

	--[[local function onError(errorCode)
        if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
            log4patch:info("no new version")
        elseif errorCode == cc.ASSETSMANAGER_NETWORK then
            log4patch:info("network error")
            local tip = "亲，网络不给力哦\n请检查一下网络吧"
            self.mgr:promptExit(tip, bind(self.start, self))
        end
    end

    local function onProgress( percent )
    	local recv = self:getTotalSize() * (percent / 100)
        self.mgr:onDownLoadingAsset(recv, self:getTotalSize())
    end

    local function onSuccess()
        -- progressLable:setString("downloading ok")
        util.timer:after(1000, self:createEvent('downloadFinish'))
    end

	local function getAssetsManager()
		local pathToSave = verInfo.filepath
        local assetsManager = cc.AssetsManager:new(verInfo.url,
                                       "",
                                       pathToSave)
        assetsManager:retain()
        assetsManager:setDelegate(onError, cc.ASSETSMANAGER_PROTOCOL_ERROR )
        assetsManager:setDelegate(onProgress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
        assetsManager:setDelegate(onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS )
        assetsManager:setConnectionTimeout(3)

        return assetsManager
    end

    local assetsManager = getAssetsManager()
    assetsManager:checkUpdate()--]]

	-- local config = sdk.config:getConfig("server", "autopatch")
	-- local info = {}
	-- info.ip = config.downHost
	-- info.port = config.downPort
	-- info.uri = config.downAsset .. verInfo.url 
	-- info.method = "GET"
	-- info.filename = verInfo.filepath
	-- info.listen = function (recv, total)
	-- 	self.downSizeInfo.curFile = recv
	-- 	self.mgr:onDownLoadingAsset(self.downSizeInfo.downloadFile + recv, self:getTotalSize())
	-- end

	-- net.http:send(info, self:createEvent("DOWNLOAD_FILE", "onDownloadFile"))
end

function class:onDownloadFile(code, data)
	log4patch:info("[=25AutoPatch.Asset:onDownloadFile] code:" .. code)
	-- self:cancelEvent('DOWNLOAD_FILE')

	-- local curInfo = self.versionInfo[self.curDown]
	local curInfo = self.versionInfo
	if code ~= 0 or not self:checkFile(curInfo.filepath, curInfo.md5) then
		util:deleteFile(curInfo.filepath)

		if self:tryAutoRedown(self.curDown) then
			self.curDown = self.curDown - 1
		else
			local tip = "下载更新包失败，是否重试？"
			self.mgr:promptExit(tip, function() self:downloadByInfo(curInfo) end)
			return
		end
	end
	
	-- if self.curDown < #self.versionInfo then
	if self.curDown < 1 then
		self.downSizeInfo.curFile = 0
		self.downSizeInfo.downloadFile = self.downSizeInfo.downloadFile + curInfo.size

		self.curDown = self.curDown + 1
		self:downloadByInfo(self.versionInfo)
		return
	end

	util.timer:after(1000, self:createEvent('downloadFinish'))
end

function class:downloadFinish()
	log4patch:info("[=26AutoPatch.Asset:downloadFinish]")
	self.downSizeInfo.curFile = 0
	self.downSizeInfo.downloadFile = self:getTotalSize()

	if not self:unzipFile() then 
		return 
	end

	local tmpFileDir = db.var:getDocDir('unzip_tmp')
	local patchFileDir = db.var:getSysVar(GV_PATCHPATH)
	local ret = util:renameFolder(tmpFileDir, patchFileDir)

	local zipFileDir = db.var:getDocDir('zip_tmp')
	util:clearFolder(zipFileDir)
	util:clearFolder(tmpFileDir)

	if not ret then
		db.var:setSysVar(GV_RES_VER, 0)
		util:clearFolder(patchFileDir)
	
		local tip = "更新文件失败，是否重新下载？"
		self.mgr:promptExit(tip, function() util:rebootGame() end)
		return
	end

	-- local resVer = self.versionInfo[#self.versionInfo].version
	local resVer = self.versionInfo.version
	db.var:setSysVar(GV_RES_VER, resVer)
	self.mgr:onAssetFinish()

	if self.assetsManager ~= nil then
		self.assetsManager:release()
		self.assetsManager = nil
	end
end

function class:unzipFile()
	local unzipPath = db.var:getDocDir('unzip_tmp')
	util:clearFolder(unzipPath)

	local ret = util:unzip(self.versionInfo.filepath, unzipPath)
	if ret ~= 0 then
		local tip = "文件解压失败，是否重试？"
		self.mgr:promptExit(tip, bind(self.downloadFinish, self))
		return false
	end

	return true 
end





--------------internal-----------------
function class:checkFile(filename, md5)
	local fileMd5 = util:md5File(filename, false)
	if string.upper(fileMd5) ~= string.upper(md5) then
		return false
	end

	return true 
end

function class:tryAutoRedown(idx)
	self.retryTimes[idx] = (self.retryTimes[idx] or 0) + 1
	return self.retryTimes[idx] <= DOWNFILE_RETRY_TIMES
end


function class:checkAvaliableStorageSize()
	local avaliableSize = util:getAvaliableStorageSize()
	if 0 == avaliableSize then 
		return true 
	end

	local totalSize = self:getTotalSize()

	--可用空间(单位为MB)要求大于下载包大小(单位为Byte)的3倍
	return avaliableSize > (totalSize * 3 / (1024 * 1024))
end


