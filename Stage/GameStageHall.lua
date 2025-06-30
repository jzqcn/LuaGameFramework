module(..., package.seeall)

class = GameStage.class:subclass()

function class:initialize(playingGameName)
	super.initialize(self)

	self.playingGameName = playingGameName
end

function class:onStageActive()
	Model:load({
		"PlayBack",
	})
	-- ui.mgr:replaceScene("Hall/RootHall")
	ui.mgr:replaceScene("Hall/HallView")

	util.timer:after(200, self:createEvent("playMusic"))
end

function class:playMusic()
	sys.sound:playMusic("HALL")
end

function class:onStageClose()

end

function class:onEnterBackground()
	-- body
	-- log("onEnterBackground")
	local rootLayer = ui.mgr:getDialogRootNode()
	if rootLayer then
		rootLayer:onEnterBackground()
	end
end

function class:onEnterForeground()
	-- body
	-- log("onEnterForeground")
	util:checkClipboardString()

	local rootLayer = ui.mgr:getDialogRootNode()
	if rootLayer then
		rootLayer:onEnterForeground()
	end

	-- local textureCache = cc.Director:getInstance():getTextureCache()
	-- log(textureCache:getCachedTextureInfo())
end

--判断玩家是否在游戏中，房卡场游戏未开始前，可以退回大厅
function class:isPlayingGame()
	return self.playingGameName ~= nil
end

function class:getPlayingGameName()
	return self.playingGameName
end
