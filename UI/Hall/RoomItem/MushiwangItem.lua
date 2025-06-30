local BaseItem = require "Hall.BaseItem"

module (..., package.seeall)

prototype = BaseItem.prototype:subclass()

function prototype:enter()
	--Model:load({"Games/MushiwangGoldConfig", "Games/Mushiwang"})

	self.gameName = "Mushiwang"

	--self:bindModelEvent("Games/MushiwangGoldConfig.EVT.PUSH_LEVEL_CONFIG_DATA", "onPushLevelConfigData")

	local size = self.panelBg:getContentSize()
	--DragonBones骨骼动画
	local factory = dragonBones.CCFactory:getFactory()
	factory:loadDragonBonesData("resource/csbimages/Hall/RoomItem/mushiwang_item_ske.dbbin", "mushiwang_item")
    factory:loadTextureAtlasData("resource/csbimages/Hall/RoomItem/mushiwang_item_tex.json", "mushiwang_item")
    local itemAnimation = factory:buildArmatureDisplay("armatureName", "mushiwang_item")
    if itemAnimation then
	    itemAnimation:getAnimation():play("Animation1", 0)

	    itemAnimation:setPosition(size.width/2, size.height/2+20)
	    itemAnimation:setScale(0.5)
	    -- itemAnimation:setTag(100)
	    self.panelBg:addChild(itemAnimation)

	    self.itemAnimation = itemAnimation
	end
end

function prototype:exit()
	--DragonBones骨骼动画资源释放
	-- local armatureDisplay = self.panelBg:getChildByTag(100)
	if self.itemAnimation then
		self.itemAnimation:removeFromParent()
		self.itemAnimation:dispose()

		dragonBones.CCFactory:getFactory():removeDragonBonesData("mushiwang_item")
		dragonBones.CCFactory:getFactory():removeTextureAtlasData("mushiwang_item")
	end	
end

function prototype:playAction()
	self:playActionTime(0, true)
end

function prototype:versionPass()
	self.gameName = "Mushiwang"
	local typeId = Model:get("Hall"):getCardTypeId(self.gameName)
	-- log("self.currencyType "..self.currencyType,"typeId "..typeId,"self.clubId "..tostring(self.clubId))
	ui.mgr:open("Hall/CreateRoom/CreateRoomView", {currencyType = self.currencyType, typeId = typeId, gameName = self.gameName, clubId = self.clubId})
end

function prototype:onBtnItemTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		if self.itemInfo then
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




