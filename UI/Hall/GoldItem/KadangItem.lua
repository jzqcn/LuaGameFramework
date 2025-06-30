local BaseItem = require "Hall.BaseItem"

module (..., package.seeall)

prototype = BaseItem.prototype:subclass()

function prototype:enter()
	-- ui.aniMgr:load("Effect/Star/Star01", self.rootNode)
	Model:load({"Games/KadangGoldConfig", "Games/Kadang"})

	self.gameName = "Kadang"
	
	self:bindModelEvent("Games/KadangGoldConfig.EVT.PUSH_LEVEL_CONFIG_DATA", "onPushLevelConfigData")
	-- util.timer:after(300, self:createEvent("playAction"))

	local size = self.panelBg:getContentSize()
	--DragonBones骨骼动画
	local factory = dragonBones.CCFactory:getFactory()
	factory:loadDragonBonesData("resource/csbimages/Hall/GoldItem/kadang_ske.dbbin", "kadang")
    factory:loadTextureAtlasData("resource/csbimages/Hall/GoldItem/kadang_tex.json", "kadang")
    local itemAnimation = factory:buildArmatureDisplay("armatureName", "kadang")
    if itemAnimation then
	    itemAnimation:getAnimation():play("Animation1", 0)

	    itemAnimation:setPosition(size.width/2, size.height/2)
	    itemAnimation:setScale(0.5)
	    -- itemAnimation:setName("kadang_item")
	    self.panelBg:addChild(itemAnimation, 1, 100)

	    self.itemAnimation = itemAnimation
	end
end

function prototype:exit()
	--DragonBones骨骼动画资源释放
	-- local armatureDisplay = self.panelBg:getChildByName("kadang_item")
	if self.itemAnimation then		
		self.itemAnimation:removeFromParent()
		self.itemAnimation:dispose()
		

		dragonBones.CCFactory:getFactory():removeDragonBonesData("kadang")
		dragonBones.CCFactory:getFactory():removeTextureAtlasData("kadang")
	end
end

function prototype:versionPass()
	Model:get("Games/KadangGoldConfig"):requestGetLevelConfig(self.itemInfo.typeId)
end

function prototype:onBtnItemTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		if self:checkIsPlayingGame() then
			return
		end

		if self.itemInfo then
			-- log("game typeId : "..self.itemInfo.typeId)
			if self.itemInfo.isOpen == true then
				self:versionPass()
			else
				local data = {
					content = "暂未开放，敬请期待！"
				}
				ui.mgr:open("Dialog/ConfirmView", data)
			end
		else
			assert(false)
		end
	end
end

function prototype:playAction()
	self:playActionTime(0, true)

	-- ui.aniMgr:load("Effect/Star/Star01", self.rootNode)
	-- local rotate =  cc.RotateTo:create(1.2, -6)
	-- local rotateBack = cc.RotateTo:create(1.6, 2)
	-- local seq = cc.Sequence:create(rotate, rotateBack)
	-- self.imgBody1:runAction(cc.RepeatForever:create(seq))
end
