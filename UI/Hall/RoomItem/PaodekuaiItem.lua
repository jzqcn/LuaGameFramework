local BaseItem = require "Hall.BaseItem"

module (..., package.seeall)

prototype = BaseItem.prototype:subclass()

function prototype:enter()
	-- util.timer:after(300, self:createEvent("playAction"))
	local size = self.panelBg:getContentSize()
	--DragonBones骨骼动画
	local factory = dragonBones.CCFactory:getFactory()
	factory:loadDragonBonesData("resource/csbimages/Hall/RoomItem/paodekuai_item_ske.dbbin", "paodekuai_item")
    factory:loadTextureAtlasData("resource/csbimages/Hall/RoomItem/paodekuai_item_tex.json", "paodekuai_item")
    local itemAnimation = factory:buildArmatureDisplay("Armature", "paodekuai_item")
    if itemAnimation then
	    itemAnimation:getAnimation():play("newAnimation", 0)

	    itemAnimation:setPosition(size.width/2, size.height/2)
	    -- itemAnimation:setScale(0.5)
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

		dragonBones.CCFactory:getFactory():removeDragonBonesData("paodekuai_item")
		dragonBones.CCFactory:getFactory():removeTextureAtlasData("paodekuai_item")
	end	
end

function prototype:versionPass()
	local gameName = "Paodekuai"
	local typeId = Model:get("Hall"):getCardTypeId(gameName)

	ui.mgr:open("Hall/CreateRoom/CreateRoomView", {currencyType = self.currencyType, typeId = typeId, gameName = gameName, clubId = self.clubId})
end

function prototype:onBtnItemTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
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

function prototype:playAction()
	self:playActionTime(0, true)
end