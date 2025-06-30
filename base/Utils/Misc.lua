
module("util", package.seeall)

function encrypt(_, str)
	return CUtil:GetSingleton():Encrypt(str)
end

function decrypt(_, str)
	return CUtil:GetSingleton():Decrypt(str)
end

function md5(_, str)
	return CMd5(str):GetResult()
end

function md5File(_, filename, isPackFile)
	isPackFile = isPackFile or false
	return CMd5(filename, isPackFile):GetResult()
end

function unzip(_, filepath, unzipFolder)
	return Unzip(filepath, unzipFolder)
end



----------dir or file---------------
--
--优先散文件 然后整文件
function openFile(_, filepath, isEncrypted)
	local data = FilePackOpen(filepath)
	if nil == data or '' == data then 
		log4misc:warn("openFile failed:" .. filepath)
		return nil 
	end

	if isEncrypted then
		data = util:decrypt(data)
	end
	return data
end

function deleteFile(_, filepath)
	CDirUtils:DelFile(filepath)
end

function clearFolder(_, folderpath)
	CDirUtils:ClrContent(folderpath)
end

--移动或重命名文件夹(覆盖旧的)
function renameFolder(_, oldDir, newDir)
	return CDirUtils:Rename(oldDir, newDir)
end

--散文件
function fileExist(_, filepath)
	local suc, file, size = CDirUtils:FileStat(filepath)
	return suc, size
end

function dirExist(_, dirpath)
	return CDirUtils:DirStat(dirpath)
end

--散文件
local _fileCache = {}
function getFullPath(_,	 filePath)
	if _fileCache[filePath] then
		return _fileCache[filePath]
	end

	local path = filePath
	local patchDir = db.var:getSysVar(GV_PATCHPATH)
	path = string.gsub(path, patchDir, '')

	local resDir = db.var:getSysVar(GV_RESPATH)
	path = string.gsub(path, resDir, '') 

	local fullpath
	if util:fileExist(patchDir .. path) then 
		fullpath = patchDir .. path
	else
		fullpath = resDir .. path
	end

	_fileCache[fullpath] = fullpath

	if IsDevMode() and not util:fileExist(fullpath) then
		log4misc:warn("getFullPath file not exist:" .. fullpath)
	end
	return fullpath
end
--
-----------------------------

function getPlatform(_)
	if CUtil:GetPlatform() == CUtil.E_TP_WIN32 then
		return "win32"
	end

	if CUtil:GetPlatform() == CUtil.E_TP_MAC then
		return "mac"
	end

	if CUtil:GetPlatform() == CUtil.E_TP_IOS then
		return "ios"
	end

	if CUtil:GetPlatform() == CUtil.E_TP_ANDROID then
		return "android"
	end

	if CUtil:GetPlatform() == CUtil.E_TP_WP8 then
		return "wp8"
	end
	return "unknown"
end

-- enum NETWORK_STATUS
-- {
-- 	NETWORK_NONE,		// 未连接
-- 	NETWORK_WIFI,		// WIFI
-- 	NETWORK_MOBILE,		// 运营商网络
-- 	NETWORK_OTHER,		// 其它网络
-- };
local _netType = NETWORK_NONE
function getNetType(_)
	util:fireCoreEvent(REFLECT_EVENT_CHECK_NETWORK)
	return _netType
end

function setNetType(_, newStatus, oldStatus)
	_netType = newStatus
end

local _avaliableSize = 0
function getAvaliableStorageSize(_)
	util:fireCoreEvent(REFLECT_EVENT_CHECK_STORAGESIZE)
	return _avaliableSize
end

function setAvaliableStorageSize(_, size)
	_avaliableSize = size
end

function openUrl(_, url)
	if url == nil or url == '' then 
		return 
	end

	if util:getPlatform() == "win32" then
		os.execute("cmd /c start iexplore " .. url)
		return
	end

	util:fireCoreEvent(REFLECT_EVENT_OPEN_URL, 0, 0, url)
end

function rebootGame(_)
	CEnvRoot:GetSingleton():SetReloadAll()
end

function exitGame(_)
	util:fireCoreEvent(REFLECT_EVENT_EXIT)
end

function fireCoreEvent(_, evt, nFlag, nData, strData)
	-- log("fireCoreEvent evt type : "..evt)
	nFlag = nFlag or 0
	nData = nData or 0
	strData = strData or ""
	local evt = ReflectEvtArgs(evt, nFlag, nData, strData)
	CReflectSystem:GetSingleton():FireEvent(evt)
end

function setClipboardString(_, str)
	util:fireCoreEvent(REFLECT_EVENT_SET_CLIPBOARD_STRING, 0, 0, str)
end

function getClipboardString()
	return CEnvRoot:GetSingleton():GetClipboardString()
end

--微信分享文字，复制后，进入游戏检查是否包含房间号，直接申请进入房间
function checkClipboardString()
	local strClipboardString = CEnvRoot:GetSingleton():GetClipboardString()
	if strClipboardString ~= "" then
		local paramTable = string.split(strClipboardString, "-")
		if #paramTable >= 3 then
			local roomId = tonumber(paramTable[3])
			if roomId and roomId > 0 and roomId < 10000 then
				--房间号4位数
				Model:get("Room"):requestAddRoomById(roomId)
				--清空剪切板
				util:fireCoreEvent(REFLECT_EVENT_SET_CLIPBOARD_STRING, 0, 0, "")
			end
		end
		-- local beignIndex, endIndex = string.find(strClipboardString, "房间:")
		-- if beignIndex and endIndex then
		-- 	local roomId = tonumber(string.sub(strClipboardString, endIndex + 1, endIndex + 4))
		-- 	if roomId and roomId > 999 and roomId < 10000 then
		-- 		--房间号4位数
		-- 		Model:get("Room"):requestAddRoomById(roomId)
		-- 		--清空剪切板
		-- 		util:fireCoreEvent(REFLECT_EVENT_SET_CLIPBOARD_STRING, 0, 0, "")
		-- 	end
		-- end
	end
end

--屏幕截图
function captureScreen()
	local patchDir = db.var:getSysVar(GV_PATCHPATH)
	local folder = patchDir .. "share/"
	CDirUtils:MkDir(folder)

	local function afterCaptured(succeed, outputFile)
		if succeed then
			--http://www.yfgame777.com/download/download.html
			
			local shareTable = {}
			shareTable.ShareType = "Image" --内容（文本：Text， 链接：Link, 图片：Image）
			-- shareTable.Scene = "SceneSession"  --分享类型（朋友圈：SceneTimeline， 好友：SceneSession）

			shareTable.Title = "777游戏"
			shareTable.Desc = "激情玩牌，斗智斗勇乐不停！"
			shareTable.ImagePath = outputFile
			shareTable.Width = 150
			shareTable.Height = 80

			ui.mgr:open("System/WeixinShareView", shareTable)
		else
			local data = {
				content = "分享失败！"
			}
			ui.mgr:open("Dialog/DialogView", data)
		end
	end

	--使用jpg，png生成图片太大
	local fileName = folder .. "CaptureScreen.jpg"
	cc.utils:captureScreen(afterCaptured, fileName)

	sys.sound:playEffect("PHOTO")
end

function captureScreenToCamera()
	local function afterCaptured(succeed, outputFile)
		if succeed then
			log("outputFile : " .. outputFile)

			local data = {
				content = "图片已保存至相册！"
			}
			ui.mgr:open("Dialog/DialogView", data)

			util:fireCoreEvent(REFLECT_EVENT_SAVE_PIC, 0, 0, outputFile)
		else
			local data = {
				content = "图片保存失败！"
			}
			ui.mgr:open("Dialog/DialogView", data)
		end
	end

	local patchDir = db.var:getSysVar(GV_PATCHPATH)
	local folder = patchDir .. "share/"
	CDirUtils:MkDir(folder)

	local fileName = folder .. "sharePicture.jpg"

	-- local time_t = util.time:getTimeDate()
	-- local fileName = string.format("IMG_%d%02d%02d_%02d%02d.jpg", time_t.year, time_t.month, time_t.day, time_t.hour, time_t.min)
	--使用jpg，png生成图片太大
	-- local fileName = folder .. "CaptureScreen.jpg"
	-- local folder = cc.FileUtils:getInstance():getWritablePath()
	-- log("writeable path : " .. folder)
	-- if util:getPlatform() == "android" then
	-- 	folder = "/storage/emulated/0/DCIM/Camera/"
	-- end

	-- fileName = folder .. fileName

	cc.utils:captureScreen(afterCaptured, fileName)

	sys.sound:playEffect("PHOTO")
end
