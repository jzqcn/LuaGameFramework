module (..., package.seeall)

prototype = Controller.prototype:subclass()

CARDCOLOR = Enum
{
	"DIAMOND",		--方块
	"CLUB",			--梅花
	"HEART",		--红心
	"SPADE",		--黑桃
	"JOKER",		--鬼
}

local pokerIcon = {
	{"diamondIcon.png", "diamondIcon2.png"},
	{"clubIcon.png", "clubIcon2.png"},
	{"heartIcon.png", "heartIcon2.png"},
	{"spadeIcon.png", "spadeIcon2.png"},
}

local pokerBg = {
	"cardBack.png",
	"cardBack2.png"
}

function prototype:enter()
	self.isSelected = false
	self.offPos = cc.p(0, 0)
	self.index = 0
end

function prototype:setCardInfo(playerId, info)
	self.playerId = playerId

	if not self.id or self.id < 0 then
		self.imgBg:loadTexture("resource/csbimages/CardPoker/"..pokerBg[1])
		self.panelCard:setVisible(false)
	end

	if not info then
		self.id = -99
		return
	end

	self.id = info.id or 0
	self.color = tonumber(info.color)
	self.size = tonumber(info.size)
	self.value = info.value
	if self.value == nil then
		self.value = self.size
	end
end

function prototype:getCardId()
	return self.id
end

function prototype:getCardColor()
	return self.color
end

function prototype:getCardValue()
	return self.value
end

function prototype:getCardSize()
	return self.size
end

function prototype:setCardIndex(index)
	self.index = index
end

function prototype:getCardIndex()
	return self.index
end

function prototype:setIsSelected(var, offPos)
	self.isSelected = var

	if var == true then
		offPos = offPos or cc.p(0, 0)
		local x, y = self.rootNode:getPosition()
		self.rootNode:setPosition(x + offPos.x, y + offPos.y)
		self.offPos = offPos
	else
		local x, y = self.rootNode:getPosition()
		self.rootNode:setPosition(x - self.offPos.x, y - self.offPos.y)
		self.offPos = cc.p(0, 0)
	end
end

function prototype:getIsSelected()
	return self.isSelected
end

function prototype:setCardColor(color)
	self.rootNode:setColor(color)
end

function prototype:showCardValue()
	if self.id == -99 then
		return
	end

	self.panelCard:setVisible(true)
	self.imgBg:loadTexture("resource/csbimages/CardPoker/cardFront.png")

	if self.size == CardKind_pb.C0 then
		--小鬼
		self.imgJoker:loadTexture("resource/csbimages/CardPoker/joker_2.png")
		self.imgJokerIcon:loadTexture("resource/csbimages/CardPoker/joker_icon_2.png")
		self.imgIcon:setVisible(false)
		self.imgNum:setVisible(false)
		self.imgSmallIcon:setVisible(false)
		self.imgJokerIcon:setVisible(true)
		self.imgJoker:setVisible(true)
	elseif self.size == CardKind_pb.C14 then
		--大鬼
		self.imgJoker:loadTexture("resource/csbimages/CardPoker/joker_1.png")
		self.imgJokerIcon:loadTexture("resource/csbimages/CardPoker/joker_icon_1.png")
		self.imgIcon:setVisible(false)
		self.imgNum:setVisible(false)
		self.imgSmallIcon:setVisible(false)
		self.imgJokerIcon:setVisible(true)
		self.imgJoker:setVisible(true)
	else
		--A-K
		local iconRes = pokerIcon[self.color]
		self.imgIcon:loadTexture("resource/csbimages/CardPoker/"..iconRes[1])
		self.imgSmallIcon:loadTexture("resource/csbimages/CardPoker/"..iconRes[2])

		if self.color == CARDCOLOR.SPADE or self.color == CARDCOLOR.CLUB then
			self.imgNum:loadTexture(string.format("resource/csbimages/CardPoker/black_%d.png", self.size))
		else
			self.imgNum:loadTexture(string.format("resource/csbimages/CardPoker/red_%d.png", self.size))
		end

		self.imgIcon:setVisible(true)
		self.imgNum:setVisible(true)
		self.imgSmallIcon:setVisible(true)
		self.imgJokerIcon:setVisible(false)
		self.imgJoker:setVisible(false)
	end
end

function prototype:hideCardValue()
    self.imgIcon:setVisible(false)
    self.imgNum:setVisible(false)
    self.imgSmallIcon:setVisible(false)
    self.imgJokerIcon:setVisible(false)
    self.imgJoker:setVisible(false)
    self.imgBg:loadTexture("resource/csbimages/CardPoker/" .. pokerBg[1])
end

function prototype:addCardTouchEvent(callback)
	self.panelCard:addTouchEventListener(function (sender, eventType)
		callback(self, sender, eventType)
    end)
end

--[[function prototype:onBtnCardTouch(sender, event)
	if event == ccui.TouchEventType.began then
		log("btn touchBeg")

	elseif event == ccui.TouchEventType.moved then
		log("btn touchMove")

	elseif event == ccui.TouchEventType.ended then
		log("btn touchEnd")

	elseif event == ccui.TouchEventType.canceled then
		log("btn touchCanl")
	end
end--]]

--发牌动画
function prototype:runDealAction(from, to, scale, delay, action, sound)
	if action == nil then
		action = true 
	end

	self.rootNode:setRotation(0)
	self.rootNode:stopAllActions()
	self.rootNode:setAnchorPoint(cc.p(0.5, 0.5))

	if action == true then
		self.rootNode:setPosition(from)
		self.rootNode:setScale(0.4)
		self.rootNode:setVisible(false)

		-- local moveTo = cc.MoveTo:create(0.5, to)
		-- local scaleTo = cc.ScaleTo:create(0.5, scale)
		-- self.rootNode:runAction(moveTo)
		-- self.rootNode:runAction(scaleTo)

		local callFunc = cc.CallFunc:create(function ()
	    		self.rootNode:setVisible(true)
	    	end)

		local action = cc.Spawn:create(
			cc.MoveTo:create(0.4, to),
			cc.ScaleTo:create(0.4, scale),
			cc.RotateBy:create(0.4, 360)
			)

		local callFunc2 = cc.CallFunc:create(function ()
	    		self:showCardValue()
	    	end)
		self.rootNode:runAction(cc.Sequence:create(cc.DelayTime:create(delay), callFunc, action, callFunc2))

		--播放发牌音效(发单张牌音效)
		sound = sound or false
		if sound then
			sys.sound:playEffect("DEAL")
		end
	else
		self.rootNode:setVisible(true)
		self.rootNode:setPosition(to)
		self.rootNode:setScale(scale)
		self:showCardValue()
	end
end

function prototype:runDealAction2(from, to, scale, delay, action, callback)
	if action == nil then
		action = true 
	end

	self.rootNode:stopAllActions()
	self.rootNode:setAnchorPoint(cc.p(0.5, 0.5))

	if action == true then
		self.rootNode:setPosition(from)
		self.rootNode:setScale(0.4)
		self.rootNode:setVisible(false)

		local callFunc = cc.CallFunc:create(function ()
    		self.rootNode:setVisible(true)
    	end)

		local bezier ={
	        from,
	        cc.p(to.x - (to.x-from.x)/3, to.y - (to.y-from.y)/3),
	        to
	    }

		local action = cc.Spawn:create(
			cc.BezierTo:create(0.4, bezier),
			cc.ScaleTo:create(0.4, scale)
			)

		local callFunc2 = cc.CallFunc:create(function ()
    		-- self:showCardValue()
    		if callback then
    			callback(self.index)
    		end
    	end)
    	
		self.rootNode:runAction(cc.Sequence:create(cc.DelayTime:create(delay), callFunc, action, callFunc2))

	else
		self.rootNode:setVisible(true)
		self.rootNode:setPosition(to)
		self.rootNode:setScale(scale)
		-- self:showCardValue()
	end
end
