module(..., package.seeall)

class = GameStage.class:subclass()

local fileUtils = cc.FileUtils:getInstance()

--游戏状态
function class:initialize(name)
	super.initialize(self)

	self.gameName = name
	-- self.isPack = isPack or false
end

function class:onStageActive()
	local pathView = ""
	-- if not self.isPack then
	-- 	pathView = string.format("Games/%s/%sView", self.gameName, self.gameName)
	-- else
	-- 	pathView = string.format("%s/%sView", self.gameName, self.gameName)
	-- end

	local file = string.format("resource/csb/Games/%s/%sView.csb", self.gameName, self.gameName)
	if not fileUtils:isFileExist(file) then
		pathView = string.format("%s/%sView", self.gameName, self.gameName)
	else
		pathView = string.format("Games/%s/%sView", self.gameName, self.gameName)
	end

	ui.mgr:replaceScene(pathView)

	-- log("GameStage :: Game name : " .. self.gameName)
	-- sys.sound:playMusic(string.upper(self.gameName))

	self.isTimeOut = false
end

function class:onStageClose()

end

function class:onEnterBackground()
	-- body
	-- log("onEnterBackground ***************************")
	local rootLayer = ui.mgr:getDialogRootNode()
	if rootLayer and rootLayer.onEnterBackground then
		rootLayer:onEnterBackground()
	end

	--在游戏中，进入后台超过一分钟，断开连接
	if self:existEvent('BACKGROUND_TIMEOUT_TIMER') then
		self:cancelEvent('BACKGROUND_TIMEOUT_TIMER')
	end
	util.timer:after(60 * 1000, self:createEvent('BACKGROUND_TIMEOUT_TIMER', 'onBackGroundTimeout'))
end

function class:onBackGroundTimeout()
	log("background timeout **********************")
	net.mgr:disconnect()
	Model:get("HeartBeat"):stopUpdateHeart()

	self.isTimeOut = true
end

function class:onEnterForeground()
	-- body
	-- log("onEnterForeground ***************************")
	local rootLayer = ui.mgr:getDialogRootNode()
	if rootLayer and rootLayer.onEnterForeground then
		rootLayer:onEnterForeground()
	end

	util.timer:after(1, function()
		if self:existEvent('BACKGROUND_TIMEOUT_TIMER') then
			self:cancelEvent('BACKGROUND_TIMEOUT_TIMER')
		end

		if self.isTimeOut then
			Model:get("Account"):connect()
			self.isTimeOut = false
		end
	end)
	

	-- self:fireEvent(GameStage.EVT.ENTER_FOREGROUND)
end

function class:getGameName()
	return self.gameName
end
