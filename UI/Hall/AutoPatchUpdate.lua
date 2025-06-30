module (..., package.seeall)

--在游戏中，玩家没有下载包重登进来，先更新包
prototype = Dialog.prototype:subclass()

local EVT = AutoPatch.Mgr.EVT

function prototype:hasBgMask()
    return false
end

function prototype:enter(verinfo)
	local dir = db.var:getDocDir('zip_tmp')
	verinfo.filepath = dir .. '/' .. verinfo.flag ..".zip"
	verinfo.onError = bind(self.onError, self)
	verinfo.onProgress = bind(self.onProgress, self)
	verinfo.onSuccess = bind(self.onSuccess, self)

	self.verInfo = verinfo

	self:startDownload()

	-- self.panelPercent:setVisible(false)
	self.txtLoading:setString("")
	self.loadingBar:setPercent(0)
end

--开始下载
function prototype:startDownload()
	patch.mgr:gameDownloadStart(self.verInfo)
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
			content = "亲，网络不给力哦\n请检查一下网络吧",
		}
		ui.mgr:open("Dialog/DialogView", data)
    end
end

function prototype:onProgress(percent)
	-- log("donwload game percent : " .. percent)
	--下载进度
	if self.assertProgress then
		local recv = self.verInfo.size * (percent / 100)
		local total = self.verInfo.size

		local str = string.format("%d%%，总大小%.02fM", math.floor(recv/total*100), total/1024/1024)
		self.txtLoading:setString(str)
		self.loadingBar:setPercent(recv/total*100, 0.1)
	end
end

--下载完成
function prototype:onSuccess()
	if not self:checkFile(self.verInfo.filepath, self.verInfo.md5) then
		util:deleteFile(self.verInfo.filepath)

		local tip = "下载更新包失败，是否重试？"
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

		local ret = util:unzip(self.verInfo.filepath, unzipPath)
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
		end

		local gameName = self.verInfo.gameName
		--设置版本号
		local gameVer = "GV_" .. string.upper(gameName) .. "_VER"
		db.var:setSysVar(gameVer, self.verInfo.version)

		-- local tip = "游戏下载成功！"
		-- local data = {
		-- 	content = tip
		-- }
		-- ui.mgr:open("Dialog/DialogView", data)
		
		--下载完成进入游戏
		Model:get("Games/" .. gameName):enterGameStage(gameName)
	end
end

function prototype:checkFile(filename, md5)
	local fileMd5 = util:md5File(filename, false)
	if string.upper(fileMd5) ~= string.upper(md5) then
		return false
	end

	return true 
end
