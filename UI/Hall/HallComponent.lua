module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	util.timer:after(200, self:createEvent("playAction"))
end

function prototype:playAction()
	self:playActionTime(0, true)

	self:loadParticle()

	--俱乐部流光效果
    -- local vsh = "resource/shaders/simple.vsh"
    -- local fsh = "resource/shaders/stream2.fsh"
    -- Assist.Shader:create(vsh, fsh, self.imgClubIcon)
end

function prototype:onEnterBackground()
	self:pauseActionTime()

	self:removeParticle()
end

function prototype:onEnterForeground()
	util.timer:after(200, self:createEvent("playAction"))
end

--粒子特效
function prototype:loadParticle()
	local particle = cc.ParticleSystemQuad:create("resource/particle/defaultParticle.plist")
	particle:setPosition(95, 76.5)
	particle:setScale(0.25)
    self.rootNode:addChild(particle, 0, 1000)

    local particle = cc.ParticleSystemQuad:create("resource/particle/diamondStar.plist")
   	particle:setBlendFunc(cc.blendFunc(gl.SRC_ALPHA, gl.ONE))
	particle:setPosition(406, 360)
    self.rootNode:addChild(particle, 0, 1001)
end

--移除特效
function prototype:removeParticle()
	local particle = self.rootNode:getChildByTag(1000)
	if particle then
		particle:removeFromParent(true)
	end

	particle = self.rootNode:getChildByTag(1001)
	if particle then
		particle:removeFromParent(true)
	end
end

--俱乐部
function prototype:onBtnClubTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		ui.mgr:open("Club/ClubView")
		-- local data = {
		-- 	content = "暂未开放，敬请期待！"
		-- }
		-- ui.mgr:open("Dialog/ConfirmView", data)
	end
end

--金币场
function prototype:onBtnGoldTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		--判断玩家是否在游戏中，房卡场游戏未开始前，可以退回大厅
		local gameName = StageMgr:getStage():getPlayingGameName()
		if gameName then
			StageMgr:chgStage("Game", gameName)
			return
		end
		ui.mgr:open("Hall/GoldGameView", Common_pb.Gold)
	end
end

--银币体验场
function prototype:onBtnSilverTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local gameName = StageMgr:getStage():getPlayingGameName()
		if gameName then
			StageMgr:chgStage("Game", gameName)
			return
		end

		ui.mgr:open("Hall/GoldGameView", Common_pb.Sliver)
	end
end

--创建房卡计分场
function prototype:btnCreateScoreTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local gameName = StageMgr:getStage():getPlayingGameName()
		if gameName then
			StageMgr:chgStage("Game", gameName)
			return
		end

		ui.mgr:open("Hall/RoomGameView", {currencyType = Common_pb.Score})
	end
end

--创建房卡金币场
function prototype:btnCreateGoldTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local gameName = StageMgr:getStage():getPlayingGameName()
		if gameName then
			StageMgr:chgStage("Game", gameName)
			return
		end

		ui.mgr:open("Hall/RoomGameView", {currencyType = Common_pb.Gold})
	end
end

--加入房间
function prototype:onBtnAddRoomTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local gameName = StageMgr:getStage():getPlayingGameName()
		if gameName then
			StageMgr:chgStage("Game", gameName)
			return
		end

		ui.mgr:open("Hall/CreateRoom/AddRoomView")
	end
end

