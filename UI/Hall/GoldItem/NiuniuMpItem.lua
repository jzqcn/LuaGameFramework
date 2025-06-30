local BaseItem = require "Hall.BaseItem"

module (..., package.seeall)

prototype = BaseItem.prototype:subclass()

--明牌牛牛
function prototype:enter()
	Model:load({"Games/NiuniuGoldConfig", "Games/Niuniu"})

	self.gameName = "Niuniu"

	self:bindModelEvent("Games/NiuniuGoldConfig.EVT.PUSH_LEVEL_CONFIG_DATA", "onPushLevelConfigData")

	-- util.timer:after(300, self:createEvent("playAction"))
	local size = self.panelBg:getContentSize()
	--DragonBones骨骼动画
	local factory = dragonBones.CCFactory:getFactory()
	factory:loadDragonBonesData("resource/csbimages/Hall/GoldItem/niuniump_ske.dbbin", "niuniump")
    factory:loadTextureAtlasData("resource/csbimages/Hall/GoldItem/niuniump_tex.json", "niuniump")
    local itemAnimation = factory:buildArmatureDisplay("armatureName", "niuniump")
    if itemAnimation then
	    itemAnimation:getAnimation():play("Animation1", 0)

	    itemAnimation:setPosition(size.width/2, size.height/2 - 30)
	    -- itemAnimation:setScale(0.5)
	    self.panelBg:addChild(itemAnimation, 1, 100)

	    self.itemAnimation = itemAnimation
	end
end

function prototype:exit()
	--DragonBones骨骼动画资源释放
	-- local armatureDisplay = self.panelBg:getChildByTag(100)
	if self.itemAnimation then
		self.itemAnimation:removeFromParent()
		self.itemAnimation:dispose()

		dragonBones.CCFactory:getFactory():removeDragonBonesData("niuniump")
		dragonBones.CCFactory:getFactory():removeTextureAtlasData("niuniump")
	end
end

function prototype:playAction()
	self:playActionTime(0, true)
end

function prototype:versionPass()
	Model:get("Games/NiuniuGoldConfig"):requestGetLevelConfig(self.itemInfo.typeId)
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

