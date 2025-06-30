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

	--A-K
	local iconRes = pokerIcon[self.color]
	self.imgIcon:loadTexture("resource/csbimages/CardPoker/"..iconRes[1])
	self.imgSmallIcon:loadTexture("resource/csbimages/CardPoker/"..iconRes[2])

	if self.color == CARDCOLOR.SPADE or self.color == CARDCOLOR.CLUB then
		self.imgNum:loadTexture(string.format("resource/csbimages/CardPoker/black_%d.png", self.size))
	else
		self.imgNum:loadTexture(string.format("resource/csbimages/CardPoker/red_%d.png", self.size))
	end

	-- self.imgIcon:setVisible(true)
	-- self.imgNum:setVisible(true)
	-- self.imgSmallIcon:setVisible(true)
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

function prototype:getCardNode()
	return self.panelCard
end

function prototype:stopAction()
	self.panelCard:stopAllActions()
	self.panelCard:setPosition(self.pos)
	self.panelCard:setScale(1.0)
end

function prototype:playFireEffect()
	local skeletonNode = self.panelCard:getChildByTag(999)
	if skeletonNode == nil then
		skeletonNode = sp.SkeletonAnimation:create("resource/Longhudou/csbimages/anim/WinCard/LHD_Shengli.json", "resource/Longhudou/csbimages/anim/WinCard/LHD_Shengli.atlas")
		
		local size = self.panelCard:getContentSize()
    	skeletonNode:setPosition(cc.p(size.width/2, size.height/2))
		self.panelCard:addChild(skeletonNode, 1, 999)
	end

	skeletonNode:setAnimation(0, "animation", true)
end

