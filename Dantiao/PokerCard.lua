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

	local x, y = self.panelCard:getPosition()
	self.pos = cc.p(x, y)
end

function prototype:setCardInfo(playerId, info)
	self.playerId = playerId

	if not info then
		self.id = -99

		self.imgBg:setVisible(true)
		self.imgCard:setVisible(false)

		local effSprite = self.panelCard:getChildByTag(999)
	    if effSprite then
	    	effSprite:removeFromParent()
	    end
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

	self.imgCard:setVisible(true)
	self.imgBg:setVisible(false)
	-- self.imgBg:loadTexture("resource/csbimages/CardPoker/cardFront.png")
	if self.size == 0 then
		--小鬼
		self.imgJoker:loadTexture("resource/csbimages/CardPoker/joker_2.png")
		self.imgJokerIcon:loadTexture("resource/csbimages/CardPoker/joker_icon_2.png")
		self.imgIcon:setVisible(false)
		self.imgNum:setVisible(false)
		self.imgSmallIcon:setVisible(false)
		self.imgJokerIcon:setVisible(true)
		self.imgJoker:setVisible(true)
	elseif self.size == 14 then
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
		--dump(self.color,"self.color")
		local iconRes = pokerIcon[self.color]
		--dump(iconRes,"iconRes",5)
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
	self.imgBg:setVisible(true)
	self.imgCard:setVisible(false)
    -- self.imgIcon:setVisible(false)
    -- self.imgNum:setVisible(false)
    -- self.imgSmallIcon:setVisible(false)
    -- self.imgBg:loadTexture("resource/csbimages/CardPoker/" .. pokerBg[1])

    local effSprite = self.panelCard:getChildByTag(999)
    if effSprite then
    	effSprite:removeFromParent()
    end
end
function prototype:hideCardIcon()
	self.imgIcon:setVisible(false)
	self.imgSmallIcon:setVisible(false)
end
function prototype:fadeCardIcon(time)
	self.imgIcon:setVisible(true)
	self.imgSmallIcon:setVisible(true)
	local action=cc.Repeat:create(cc.Sequence:create(cc.FadeOut:create(0.5), cc.FadeIn:create(0.5)),time)
	self.imgIcon:runAction(action:clone())
	self.imgSmallIcon:runAction(action)
end

function prototype:getCardNode()
	return self.panelCard
end

function prototype:stopAction()
	self.panelCard:stopAllActions()
	self.panelCard:setPosition(self.pos)
	self.panelCard:setScale(1.0)
end

function prototype:playFireEffect()
	local skeletonNode = sp.SkeletonAnimation:create("resource/Dantiao/csbimages/anim/WinCard/LHD_Shengli.json", "resource/Dantiao/csbimages/anim/WinCard/LHD_Shengli.atlas")
	skeletonNode:setAnimation(0, "animation", true)
	-- local sprite = cc.Sprite:create("resource/Dantiao/csbimages/none.png")
	-- local animation = cc.Animation:create()
 --    for i = 1, 8 do
 --        animation:addSpriteFrameWithFile(string.format("resource/Dantiao/csbimages/cardFireEff/%d.png", i))
 --    end
 --    animation:setDelayPerUnit(1.0 / 8)

 --    local showAction = cc.RepeatForever:create(cc.Animate:create(animation))
 --    sprite:runAction(showAction)

    local size = self.panelCard:getContentSize()
    skeletonNode:setPosition(cc.p(size.width/2, size.height/2))
    self.panelCard:addChild(skeletonNode, 10, 999)
end

