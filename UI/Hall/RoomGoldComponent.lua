module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self.pos = cc.p(self.rootNode:getPosition())
	self.winSize = cc.Director:getInstance():getWinSize()
	self.panelSize=self.panel_1:getContentSize()
	-- util.timer:after(200, self:createEvent("playAction"))
	self.itemPos = {
		cc.p(self.panel_1:getPosition()),--俱乐部
		cc.p(self.panel_2:getPosition()),--创建房间
		cc.p(self.panel_3:getPosition())--加入房间
	}

	self.itemPanels = {
		self.panel_1,
		self.panel_2,
		self.panel_3,
	}

	self.itemAnimations = {}

	local factory = dragonBones.CCFactory:getFactory()
	for i = 1, 3 do
		local armatureName = string.format("hall_man_%d",i)
		local BonesData = string.format("resource/csbimages/Hall/ComponentRoom/man_%d_ske.dbbin",i)
		local TextureAtlasData = string.format("resource/csbimages/Hall/ComponentRoom/man_%d_tex.json",i)
		factory:loadDragonBonesData(BonesData, armatureName)
		factory:loadTextureAtlasData(TextureAtlasData, armatureName)

		local itemAnim = factory:buildArmatureDisplay("armatureName", armatureName)
		if itemAnim then
			itemAnim:setName(armatureName)
			itemAnim:getAnimation():play("newAnimation", 0)
			itemAnim:setPosition(cc.p(self.panelSize.width/2,self.panelSize.height/2))

			self.itemPanels[i]:addChild(itemAnim, 1, 100)

			table.insert(self.itemAnimations, itemAnim)
		end
	end

end

function prototype:exit()
	self:removeAnimation()
end

function prototype:removeAnimation(isClean)
	isClean = isClean or false

	--这里只释放对象，骨骼资源继续缓存
	for i, v in ipairs(self.itemAnimations) do
		if v then
			v:removeFromParent()
			v:dispose()

			if isClean then
				dragonBones.CCFactory:getFactory():removeDragonBonesData(v:getName())
				dragonBones.CCFactory:getFactory():removeTextureAtlasData(v:getName())
			end
		end
	end

	self.itemAnimations = {}
end

function prototype:show()
	self.rootNode:setPosition(self.pos)
	self.rootNode:setVisible(true)
	for i, v in ipairs(self.itemPanels) do
		v:setPosition(cc.p(self.winSize.width+300, self.itemPos[i].y))

		local action = cc.MoveTo:create(0.4, self.itemPos[i])
		v:runAction(cc.Sequence:create(cc.DelayTime:create(0.15), cc.EaseSineIn:create(action)))
	end
end

function prototype:hide()
	local moveBy = cc.MoveBy:create(0.5, cc.p(-self.winSize.width, 0))
	self.rootNode:runAction(cc.Sequence:create(cc.EaseOut:create(moveBy, 2.5), cc.CallFunc:create(function()
		self.rootNode:setVisible(false)
	end)))
	
end

function prototype:onTouch2(sender, eventType)
	if eventType == ccui.TouchEventType.ended then 
		local gameName = StageMgr:getStage():getPlayingGameName()
		if gameName then
			StageMgr:chgStage("Game", gameName)
			return
		end

		ui.mgr:open("Hall/RoomGameView", {currencyType = Common_pb.Gold})
	end
end

function prototype:onTouch3(sender, eventType)
	if eventType == ccui.TouchEventType.ended then 
		local gameName = StageMgr:getStage():getPlayingGameName()
		if gameName then
			StageMgr:chgStage("Game", gameName)
			return
		end

		ui.mgr:open("Hall/CreateRoom/AddRoomView")
	end
end

function prototype:onTouch1(sender, eventType)
	if eventType == ccui.TouchEventType.ended then 
		ui.mgr:open("Club/ClubView")	
	end
end

