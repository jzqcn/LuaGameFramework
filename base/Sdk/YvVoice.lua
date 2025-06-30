module(..., package.seeall)


class = objectlua.Object:subclass()

function class:initialize(...)
	super.initialize(self)
	self.appId = 1002829
	self.isCancelUpload = false
	self.isPlaying = false

	self.path = cc.FileUtils:getInstance():getWritablePath()
end

function class:dispose()
	super.dispose(self)
end

function class:getAppId()
	return self.appId
end

-- 初始化SDK
function class:initSdk()
	if util:getPlatform() == "win32" then
		return
	end

	-- appId:由云娃分配，需要向商务申请；tempPath:语音保存路径；isDebug：true为测试环境，false为正式环境；
	-- oversea:false为国内服务器版本，true为海外服务器版本。
	YVManager:GetInstance():Init(self.appId, false, false)
end

function class:login(nickname, uid)
	if util:getPlatform() == "win32" then
		return
	end

	YVManager:GetInstance():Login(nickname, uid)
	log("nickname:"..nickname..", id:"..uid)
end

function class:logout()
	if util:getPlatform() == "win32" then
		return
	end

	YVManager:GetInstance():Logout()
end

--speech:0. 普通录音( 不上传不识别)； ； 1  边录边上传然后识别；2. 边录边上传( 不识别)
function class:startRecord(fileName, speech, ext)
	if util:getPlatform() == "win32" then
		return false
	end

	AudioEngine.pauseMusic()

	-- log("writable path ==== "..self.path)

	local savePath = string.format("%s%s", self.path, fileName)
	-- savePath = string.gsub(savePath, "/", "\\")

	-- log("savePath path : "..savePath)

	speech = speech or 0
	ext = ext or ""
	return YVManager:GetInstance():StartRecord(savePath, speech, ext)
end

function class:stopRecord(isCancel)
	if util:getPlatform() == "win32" then
		return
	end

	self.isCancelUpload = isCancel

	YVManager:GetInstance():StopRecord()
end

function class:playRecord(url, path, ext)
	if util:getPlatform() == "win32" then
		return true
	end

	if self.isPlaying then
		return false
	end

	AudioEngine.pauseMusic()

	ext = ext or ""
	self.isPlaying = YVManager:GetInstance():PlayRecord(url, path, ext)

	return self.isPlaying
end

function class:playFromUrl(url, ext)
	if util:getPlatform() == "win32" then
		return
	end

	AudioEngine.pauseMusic()

	ext = ext or ""
	YVManager:GetInstance():PlayFromUrl(url, ext)
end

function class:stopPlay()
	if util:getPlatform() == "win32" then
		return
	end

	YVManager:GetInstance():StopPlay()
	self.isPlaying = false
end

function class:setIsPlaying(var)
	self.isPlaying = var
end

function class:getIsPlaying()
	return self.isPlaying
end

function class:upLoadFile(path, fileid)
	if util:getPlatform() == "win32" then
		return
	end

	if self.isCancelUpload then
		self.isCancelUpload = false
		return
	end

	fileid = fileid or ""
	YVManager:GetInstance():UpLoadFile(path, fileid)
end

function class:downloadFile(url, savePath, fileid)
	if util:getPlatform() == "win32" then
		return
	end
	
	fileid = fileid or ""
	YVManager:GetInstance():DownLoadFile(url, savePath, fileid)
end


