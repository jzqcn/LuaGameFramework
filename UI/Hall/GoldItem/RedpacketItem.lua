local BaseItem = require "Hall.BaseItem"

module (..., package.seeall)

prototype = BaseItem.prototype:subclass()

function prototype:enter()
	Model:load({"Games/RedpacketGoldConfig", "Games/Redpacket"})

	self.gameName = "Redpacket"

	self:bindModelEvent("Games/RedpacketGoldConfig.EVT.PUSH_LEVEL_CONFIG_DATA", "onPushLevelConfigData")

	local size = self.panelBg:getContentSize()
	--DragonBones骨骼动画
	local factory = dragonBones.CCFactory:getFactory()
	factory:loadDragonBonesData("resource/csbimages/Hall/GoldItem/redpacket_ske.dbbin", "redpacket")
    factory:loadTextureAtlasData("resource/csbimages/Hall/GoldItem/redpacket_tex.json", "redpacket")
    local itemAnimation = factory:buildArmatureDisplay("armatureName", "redpacket")
    if itemAnimation then
	    itemAnimation:getAnimation():play("newAnimation", 0)
	    itemAnimation:setPosition(size.width/2, size.height/2-20)
	    -- itemAnimation:setScale(0.5)
	    self.panelBg:addChild(itemAnimation, 1)
	    self.itemAnimation = itemAnimation
	end

	--火爆标记
	local skeletonNode = sp.SkeletonAnimation:create("resource/csbimages/Hall/SignAnim/HuoBAO.json", "resource/csbimages/Hall/SignAnim/HuoBAO.atlas")
	if skeletonNode then
		skeletonNode:setAnimation(0, "animation", true)
		skeletonNode:setTag(101)
		skeletonNode:setPosition(20, size.height-30)
		self.panelBg:addChild(skeletonNode,100)
	end
end

function prototype:exit()
	super.exit(self)
	
	if self.itemAnimation then
		self.itemAnimation:removeFromParent()
		self.itemAnimation:dispose()
		dragonBones.CCFactory:getFactory():removeDragonBonesData("redpacket")
		dragonBones.CCFactory:getFactory():removeTextureAtlasData("redpacket")
	end

end

function prototype:versionPass()
	Model:get("Games/RedpacketGoldConfig"):requestGetLevelConfig(self.itemInfo.typeId)
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
				ui.mgr:open("Dialog/DialogView", data)
			end
		else
			assert(false)
		end
	end
end

function prototype:onPushLevelConfigData(goldData)
	if not goldData or #goldData == 0 then
		log4ui:warn("[RedpacketItem::onPushLevelConfigData] get level data failed !")
		return
	end

	ui.mgr:open("Redpacket/RoomLevelView", goldData)
end

