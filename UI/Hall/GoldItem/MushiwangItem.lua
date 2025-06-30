local BaseItem = require "Hall.BaseItem"

module (..., package.seeall)

prototype = BaseItem.prototype:subclass()

function prototype:enter()
	Model:load({"Games/MuShiWangGoldConfig", "Games/Mushiwang"})

	self.gameName = "Mushiwang"

	self:bindModelEvent("Games/MuShiWangGoldConfig.EVT.PUSH_LEVEL_CONFIG_DATA", "onPushLevelConfigData")

	local size = self.panelBg:getContentSize()
	--DragonBones骨骼动画
	local factory = dragonBones.CCFactory:getFactory()
	factory:loadDragonBonesData("resource/csbimages/Hall/GoldItem/mushiwang_ske.dbbin", "mushiwang")
    factory:loadTextureAtlasData("resource/csbimages/Hall/GoldItem/mushiwang_tex.json", "mushiwang")
    local itemAnimation = factory:buildArmatureDisplay("armatureName", "mushiwang")
    if itemAnimation then
	    itemAnimation:getAnimation():play("Animation1", 0)

	    itemAnimation:setPosition(size.width/2, size.height/2+15)
	    itemAnimation:setScale(0.5)
	    -- itemAnimation:setTag(100)
	    self.panelBg:addChild(itemAnimation)

	    self.itemAnimation = itemAnimation
	end
end

function prototype:exit()
	super.exit(self)
	--DragonBones骨骼动画资源释放
	-- local armatureDisplay = self.panelBg:getChildByTag(100)
	if self.itemAnimation then
		self.itemAnimation:removeFromParent()
		self.itemAnimation:dispose()

		dragonBones.CCFactory:getFactory():removeDragonBonesData("mushiwang")
		dragonBones.CCFactory:getFactory():removeTextureAtlasData("mushiwang")
	end	
end

function prototype:playAction()
	self:playActionTime(0, true)
end

function prototype:versionPass()
	Model:get("Games/MuShiWangGoldConfig"):requestGetLevelConfig(self.itemInfo.typeId)
end

function prototype:onBtnItemTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		if self:checkIsPlayingGame() then
			return
		end
		
		if self.itemInfo then
			-- log("game typeId : "..self.itemInfo.typeId)
			if self.itemInfo.isOpen == true then
				--判断版本号
				self:checkVersion()
				-- self:versionPass()
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