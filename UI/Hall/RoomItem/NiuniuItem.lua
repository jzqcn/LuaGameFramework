local BaseItem = require "Hall.BaseItem"

module (..., package.seeall)

prototype = BaseItem.prototype:subclass()

function prototype:enter()
	Model:load({"Games/NiuniuGoldConfig", "Games/Niuniu"})

	-- util.timer:after(100, self:createEvent("playAction"))

	local size = self.panelBg:getContentSize()
	--DragonBones骨骼动画
	local factory = dragonBones.CCFactory:getFactory()
	factory:loadDragonBonesData("resource/csbimages/Hall/RoomItem/niuniu_item_ske.dbbin", "niuniu_item")
    factory:loadTextureAtlasData("resource/csbimages/Hall/RoomItem/niuniu_item_tex.json", "niuniu_item")
    local itemAnimation = factory:buildArmatureDisplay("armatureName", "niuniu_item")
    if itemAnimation then
	    itemAnimation:getAnimation():play("Animation1", 0)

	    itemAnimation:setPosition(size.width/2, size.height/2-10)
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

		dragonBones.CCFactory:getFactory():removeDragonBonesData("niuniu_item")
		dragonBones.CCFactory:getFactory():removeTextureAtlasData("niuniu_item")
	end	
end

function prototype:versionPass()
	local gameName = "Niuniu"
	local typeId = Model:get("Hall"):getCardTypeId(gameName)
	if typeId <= 0 then
		typeId = 201
	end

	ui.mgr:open("Hall/CreateRoom/CreateRoomView", {currencyType = self.currencyType, typeId = typeId, gameName = gameName, clubId = self.clubId})
	-- Model:get("Games/NiuniuGoldConfig"):requestGetLevelConfig(self.itemInfo.typeId)
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

	--[[local particle = cc.ParticleSystemQuad:create("resource/particle/niuniuStar.plist")
    self.rootNode:addChild(particle)

    local size = self.rootNode:getContentSize()
    particle:setPosition(size.width/2, size.height/2+40)

    -- particle:setBlendAdditive(true)
	--]]
    
    --[[
    1.cc.POSITION_TYPE_FREE 当B运动时，若设置Free，A发出的粒子则会出现拖尾现象。若设置其他的，则不会出现拖尾。
	2.cc.POSITION_TYPE_RELATIVE 当A相对B中坐标变动的时，若设置Relative，A发出的粒子则会出现拖尾现象。
	3.cc.POSITION_TYPE_GROUPED 而设置Grouped，不管什么坐标改变都不会发生拖尾现象。--]]
	--设置不带拖尾效果
    -- particle:setPositionType(cc.POSITION_TYPE_GROUPED)

end