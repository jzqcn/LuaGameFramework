local BaseItem = require "Hall.BaseItem"

module (..., package.seeall)

prototype = BaseItem.prototype:subclass()

function prototype:enter()
	--Model:load({"Games/ShisanshuiGoldConfig", "Games/Shisanshui"})

	self.gameName = "Shisanshui"

	self:bindModelEvent("Games/ShisanshuiGoldConfig.EVT.PUSH_LEVEL_CONFIG_DATA", "onPushLevelConfigData")

	-- util.timer:after(300, self:createEvent("playAction"))
	local size = self.panelBg:getContentSize()
	--DragonBones骨骼动画
	local factory = dragonBones.CCFactory:getFactory()
	factory:loadDragonBonesData("resource/csbimages/Hall/GoldItem/shisanshui_ske.dbbin", "shisanshui")
    factory:loadTextureAtlasData("resource/csbimages/Hall/GoldItem/shisanshui_tex.json", "shisanshui")
    local itemAnimation = factory:buildArmatureDisplay("Armature", "shisanshui")
    if itemAnimation then
	    itemAnimation:getAnimation():play("newAnimation", 0)

	    itemAnimation:setPosition(size.width/2, size.height/2 - 20)
	    -- itemAnimation:setScale(0.5)
	    self.panelBg:addChild(itemAnimation, 1, 100)

	    self.itemAnimation = itemAnimation
	end
end

function prototype:exit()
	--DragonBones骨骼动画资源释放
	local itemAnimation = self.itemAnimation --self.panelBg:getChildByTag(100)
	if itemAnimation then
		itemAnimation:removeFromParent()
		itemAnimation:dispose()

		dragonBones.CCFactory:getFactory():removeDragonBonesData("shisanshui")
		dragonBones.CCFactory:getFactory():removeTextureAtlasData("shisanshui")
	end
end

function prototype:playAction()
	self:playActionTime(0, true)
end

function prototype:versionPass()
	Model:get("Games/ShisanshuiGoldConfig"):requestGetLevelConfig(self.itemInfo.typeId)
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
				-- self:checkVersion()
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




