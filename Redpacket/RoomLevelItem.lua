module (..., package.seeall)

prototype = Controller.prototype:subclass()


function prototype:enter()

end

function prototype:initWithInfo(index, info)
	local size = self.panelBg:getContentSize()
	--DragonBones骨骼动画
	local animationName = "redpacket_level_" .. index

	local factory = dragonBones.CCFactory:getFactory()
	factory:loadDragonBonesData(string.format("resource/csbimages/Hall/RoomLevel/common/Level%d_ske.dbbin", index), animationName)
    factory:loadTextureAtlasData(string.format("resource/csbimages/Hall/RoomLevel/common/Level%d_tex.json", index), animationName)

    self.animationName = animationName

    local itemAnimation = factory:buildArmatureDisplay("armatureName", self.animationName)
    if itemAnimation then
	    itemAnimation:getAnimation():play("Animation1", 0)

	    itemAnimation:setPosition(size.width/2, size.height/2)

	    self.panelBg:addChild(itemAnimation, 1)

	    self.itemAnimation = itemAnimation
	end

	local minValue = info.coinRanges[1]
	local maxValue = info.coinRanges[#info.coinRanges]
	self.txtRange:setString(minValue .. "-" .. maxValue)

	self.fntNum:setString(tostring(info.numberRanges[#info.numberRanges]))

	self.fntMutiple:setString(tostring(info.mutiple))

	self.levelInfo = info
end

function prototype:show()
	self.rootNode:setVisible(true)
end

function prototype:hide()
	self.rootNode:setVisible(false)
end

function prototype:exit()
	if self.itemAnimation then
		self.itemAnimation:removeFromParent()
		self.itemAnimation:dispose()

		dragonBones.CCFactory:getFactory():removeDragonBonesData(self.animationName)
		dragonBones.CCFactory:getFactory():removeTextureAtlasData(self.animationName)
	end
end

function prototype:onPanelLevelTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		Model:get("Games/Redpacket"):requestEnterRoom(self.levelInfo.playId, self.levelInfo.typeId)
	end
end

