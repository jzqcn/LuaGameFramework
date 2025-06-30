module (..., package.seeall)

prototype = Controller.prototype:subclass()

function prototype:enter()
	self.arrowPos = cc.p(self.imgArrow:getPosition())
end

function prototype:onImgSelectTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self:fireUIEvent("Hall.SwitchRoomLevelTab", self.typeId)
	end
end

function prototype:refresh(data)
	self.typeId = data.dealerType
	self.imgUnselect:loadTexture(string.format("resource/csbimages/Hall/RoomLevel/%s_1.png", data.dealerTypeCode))
	self.imgSelect:loadTexture(string.format("resource/csbimages/Hall/RoomLevel/%s_2.png", data.dealerTypeCode))
	self.imgSelect:setVisible(false)
end

function prototype:setSelectedType(typeId, isEnd)
	if typeId == self.typeId then
		self.imgSelect:setVisible(true)
		self.imgUnselect:setVisible(false)

		self.imgArrow:setVisible(true)
		
		local seq = cc.Sequence:create(cc.MoveBy:create(1.2, cc.p(0, 10)), cc.MoveBy:create(1.2, cc.p(0, -10)))
		self.imgArrow:runAction(cc.RepeatForever:create(seq))
	else
		self.imgSelect:setVisible(false)
		self.imgUnselect:setVisible(true)

		self.imgArrow:setVisible(false)
		self.imgArrow:stopAllActions()
		self.imgArrow:setPosition(self.arrowPos)
		
	end

	if isEnd then
		self.imgLine:setVisible(false)
	end
end