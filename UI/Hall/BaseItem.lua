module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self.gameName = ""
end

function prototype:exit()
	if self.versionInfo then
		patch.mgr:gameDownloadStop(self.versionInfo.flag)
	end
end

function prototype:setItemInfo(itemInfo, type, clubId)
	self.itemInfo = itemInfo
	self.currencyType = type
	self.clubId = clubId
end

function prototype:getItemInfo()
	return self.itemInfo
end

function prototype:getCurrencyType()
	return self.currencyType
end

function prototype:onPushLevelConfigData(goldData)
	ui.mgr:open("Hall/RoomLevel", {goldData, self.gameName, self.currencyType})
	-- if self.currencyType == Common_pb.Gold then
	-- 	ui.mgr:open("Hall/RoomLevel", {goldData, self.gameName, self.currencyType})
	-- else 
	-- 	ui.mgr:open("Hall/RoomLevel", {silverData, self.gameName, self.currencyType})
	-- end
end

function prototype:versionPass()

end

function prototype:checkIsPlayingGame()
	local gameName = StageMgr:getStage():getPlayingGameName()
	if gameName then
		StageMgr:chgStage("Game", gameName)
		return true
	end

	return false
end

--检测版本
function prototype:checkVersion()
	--判断版本号
	if util:getPlatform() ~= "win32" then
		if self.assertProgress then
			return
		end

		local gameVer = "GV_" .. string.upper(self.gameName) .. "_VER"
		local resVer = db.var:getSysVar(gameVer)
		resVer = resVer and tonumber(resVer) or 0
		-- log("game item res ver:" .. resVer)
		if resVer > 0 and patch.mgr:isCheckedGameVer(gameVer) == true then
			self:versionPass()
		else
			--版本检测
			local event = self:createEvent('CHECK_VERSION', 'onCheckVersion')
			patch.mgr:gameVertionStart(self.gameName, event)
		end
	else
		self:versionPass()
	end
end

function prototype:onCheckVersion(name, data)
	local gameVer = "GV_" .. string.upper(self.gameName) .. "_VER"
	local resVer = db.var:getSysVar(gameVer)
	resVer = resVer and tonumber(resVer) or 0
	-- log(data)
	if data == nil then		
		if resVer > 0 then
			self:versionPass()
		else
			local data = {
				content = "获取游戏包版本失败，请稍后重试",
			}
			ui.mgr:open("Dialog/DialogView", data)
		end
	else
		local verinfo = json.decode(data)
		if verinfo.ack_code and string.lower(verinfo.ack_code) == "fail" then
			local errorModel = verinfo.errorModel
			local err
			if errorModel and errorModel.error_msg then
				err = errorModel.error_msg
			else
				err = "获取游戏包版本失败，请稍后重试"
			end

			local data = {
				content = err,
			}
			ui.mgr:open("Dialog/DialogView", data)
			return
		end

		if resVer >= verinfo.version then
			self:versionPass()
		else
			local dir = db.var:getDocDir('zip_tmp')
			verinfo.filepath = dir .. '/' .. verinfo.flag ..".zip"
			verinfo.onError = bind(self.onError, self)
			verinfo.onProgress = bind(self.onProgress, self)
			verinfo.onSuccess = bind(self.onSuccess, self)

			self.versionInfo = verinfo

			--log(verinfo)

			self:startDownload()
		end
	end
end

function prototype:removeAssertProgress()
	if self.assertProgress then
		self.assertProgress:removeFromParent()
		self.assertProgress = nil
	end

	self.panelBg:setColor(cc.c3b(255, 255, 255))
end

--开始下载
function prototype:startDownload()
	if self.assertProgress then
		return
	end

	patch.mgr:gameDownloadStart(self.versionInfo)

	local node = self:getLoader():loadAsLayer("Hall/GameAssertUpdate")
	if node then
		local size = self.rootNode:getContentSize()
		node:setAnchorPoint(cc.p(0.5, 0.5))
		node:setPosition(size.width/2, size.height/2)
		self.rootNode:addChild(node)

		node:onDownloadAsset(0, self.versionInfo.size)
		self.assertProgress = node
	end

	--下载时控件变暗
	self.panelBg:setColor(cc.c3b(127, 127, 127))
end

function prototype:onError(errorCode)
	if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
       	local err = "资源版本文件内容错误，是否重试？"
       	local retry = bind(self.startDownload, self)
		local data = {
			okFunc = retry,
			content = tip
		}
		ui.mgr:open("Dialog/ConfirmDlg", data)
    elseif errorCode == cc.ASSETSMANAGER_NETWORK then
        local data = {
			content = "亲，网络不给力哦,请检查一下网络吧!",
		}
		ui.mgr:open("Dialog/DialogView", data)
    end

    if self.assertProgress then
		self.assertProgress:removeFromParent()
		self.assertProgress = nil
	end
end

function prototype:onProgress(percent)
	--log("donwload game percent : " .. percent)
	--下载进度
	if self.assertProgress then
		local recv = self.versionInfo.size * (percent / 100)
		self.assertProgress:onDownloadAsset(recv, self.versionInfo.size)
	end

	--如果有两个相同的包在下载，另一个下载直接提示完成
	if percent >= 100 then
		self:fireUIEvent("GoldGame.DownGameSuccess", self:getName(), self.gameName)
	end
end

--下载完成
function prototype:onSuccess()
	if self.assertProgress then
		self.assertProgress:removeFromParent()
		self.assertProgress = nil
	end

	if not self:checkFile(self.versionInfo.filepath, self.versionInfo.md5) then
		util:deleteFile(self.versionInfo.filepath)

		local tip = "下载游戏包失败，是否重试？"
		local retry = bind(self.startDownload, self)
		local data = {
			okFunc = retry,
			content = tip
		}
		ui.mgr:open("Dialog/ConfirmDlg", data)
		return
	else
		local unzipPath = db.var:getDocDir('unzip_tmp')
		util:clearFolder(unzipPath)

		local ret = util:unzip(self.versionInfo.filepath, unzipPath)
		if ret ~= 0 then
			local tip = "文件解压失败，是否重试？"
			local retry = bind(self.startDownload, self)
			local data = {
				okFunc = retry,
				content = tip
			}
			ui.mgr:open("Dialog/ConfirmDlg", data)

			return
		end

		local tmpFileDir = db.var:getDocDir('unzip_tmp')
		local patchFileDir = db.var:getSysVar(GV_PATCHPATH)
		local ret = util:renameFolder(tmpFileDir, patchFileDir)

		local zipFileDir = db.var:getDocDir('zip_tmp')
		util:clearFolder(zipFileDir)
		util:clearFolder(tmpFileDir)

		if not ret then
			db.var:setSysVar("GV_NIUNIU_VER", 0)
			util:clearFolder(patchFileDir)
		
			local tip = "更新文件失败，是否重新下载？"
			local retry = bind(self.startDownload, self)
			local data = {
				okFunc = retry,
				content = tip
			}
			ui.mgr:open("Dialog/ConfirmDlg", data)
			return
		end

		--设置版本号
		local gameVer = "GV_" .. string.upper(self.gameName) .. "_VER"
		db.var:setSysVar(gameVer, self.versionInfo.version)

		patch.mgr:setCheckedGameVer(gameVer)

		self.panelBg:setColor(cc.c3b(255, 255, 255))

		local tip = "游戏下载成功！"
		local data = {
			content = tip
		}
		ui.mgr:open("Dialog/DialogView", data)
		-- self:versionPass()
	end
end

function prototype:checkFile(filename, md5)
	local fileMd5 = util:md5File(filename, false)
	-- log("fileMd5 : " .. fileMd5)
	-- log("md5 : " .. md5)
	if string.upper(fileMd5) ~= string.upper(md5) then
		return false
	end

	return true 
end


