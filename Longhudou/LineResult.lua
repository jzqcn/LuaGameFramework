module (..., package.seeall)

prototype = Controller.prototype:subclass()

local SpriteRes = {
	"resource/Longhudou/csbimages/img_long.png",
	"resource/Longhudou/csbimages/img_hu.png",
	"resource/Longhudou/csbimages/img_he.png",
}

local SHOW_NUM = 20
local OFF_SPACE = 38

function prototype:enter()
	self.iconPos = cc.p(self.imgResult_1:getPosition())
	self.resultSprites = {self.imgResult_1}
end

function prototype:clearSprites()
	for i, v in ipairs(self.resultSprites) do
		v:setVisible(false)
	end
end

function prototype:initData(sixtySideResult)	
	self:clearSprites()

	if not sixtySideResult or #sixtySideResult == 0 then
		return
	end

	local tempSprite = self.resultSprites[1]
	local sprite
	local num = #sixtySideResult
	if num <= SHOW_NUM then
		for i, v in ipairs(sixtySideResult) do
			if i > #self.resultSprites then
				sprite = tempSprite:clone()
				self.rootNode:addChild(sprite)

				table.insert(self.resultSprites, sprite)
			else
				sprite = self.resultSprites[i]
			end

			sprite:setVisible(true)
			sprite:loadTexture(SpriteRes[v[1]])
			sprite:setPosition(cc.p(self.iconPos.x + (i-1) * OFF_SPACE, self.iconPos.y))

			local icon = sprite:getChildByTag(100)
			if icon then
				icon:removeFromParent(true)
			end
			--是否明牌
			if v[2] then
				icon = cc.Sprite:create("resource/Longhudou/csbimages/iconMing_1.png")
				icon:setPosition(17, 17)
				sprite:addChild(icon, 1, 100)
			end
		end
	else
		local start = num - SHOW_NUM + 1
		local index = 1
		local result
		for i = start, num do
			if index > #self.resultSprites then
				sprite = tempSprite:clone()
				self.rootNode:addChild(sprite)

				table.insert(self.resultSprites, sprite)
			else
				sprite = self.resultSprites[index]
			end

			result = sixtySideResult[i]
			sprite:setVisible(true)
			sprite:loadTexture(SpriteRes[result[1]])
			sprite:setPosition(cc.p(self.iconPos.x + (index-1) * OFF_SPACE, self.iconPos.y))

			local icon = sprite:getChildByTag(100)
			if icon then
				icon:removeFromParent(true)
			end
			--是否明牌
			if result[2] then
				icon = cc.Sprite:create("resource/Longhudou/csbimages/iconMing_1.png")
				icon:setPosition(17, 17)
				sprite:addChild(icon, 1, 100)
			end

			index = index + 1
			if index > SHOW_NUM then
				break
			end
		end
	end
end

function prototype:refreshResultData(sixtySideResult)
	if not sixtySideResult or #sixtySideResult == 0 then
		self:clearSprites()
		return
	end

	local tempSprite = self.resultSprites[1]
	local sprite
	local toPos
	local num = #sixtySideResult
	local delay = 0
	if num <= SHOW_NUM then
		if num > #self.resultSprites then
			sprite = tempSprite:clone()
			self.rootNode:addChild(sprite)

			table.insert(self.resultSprites, sprite)
		else
			sprite = self.resultSprites[num]
		end

		toPos = cc.p(self.iconPos.x + (num-1)*OFF_SPACE, self.iconPos.y)

		if #self.resultSprites > num then
			for i = num, #self.resultSprites do
				self.resultSprites[i]:setVisible(false)
			end
		end
	else

		if SHOW_NUM > #self.resultSprites then
			sprite = tempSprite:clone()
			self.rootNode:addChild(sprite)

			table.insert(self.resultSprites, sprite)
		else
			sprite = self.resultSprites[1]
			table.remove(self.resultSprites, 1)
			table.insert(self.resultSprites, sprite)
		end

		for i = 1, SHOW_NUM - 1 do
			self.resultSprites[i]:runAction(cc.MoveBy:create(0.3, cc.p(-OFF_SPACE, 0)))
		end

		toPos = cc.p(self.iconPos.x + (SHOW_NUM-1)*OFF_SPACE, self.iconPos.y)
		delay = 0.4
		sprite:setVisible(false)
	end

	local result = sixtySideResult[num]
	sprite:loadTexture(SpriteRes[result[1]])

	-- sprite:setColor(cc.c3b(255, 255, 0))

	local icon = sprite:getChildByTag(100)
	if icon then
		icon:removeFromParent(true)
	end
	--是否明牌
	if result[2] then
		icon = cc.Sprite:create("resource/Longhudou/csbimages/iconMing_1.png")
		icon:setPosition(17, 17)
		sprite:addChild(icon, 1, 100)
	end

	self:runAction(sprite, toPos)
end

function prototype:runAction(sprite, toPos, delay)
	delay = delay or 0
	sprite:setPosition(cc.p(toPos.x + 50, toPos.y + 50))
	local seq = cc.Sequence:create(cc.FadeOut:create(0.2), cc.FadeIn:create(0.2))

	local showAction = cc.Sequence:create(
		cc.DelayTime:create(delay),
		cc.CallFunc:create(function() sprite:setVisible(true) end),
		cc.MoveTo:create(0.4, toPos),
		cc.Repeat:create(seq, 2))
	sprite:runAction(showAction)
end

function prototype:onBtnDetailsClick()
	self:fireUIEvent("Longhudou.ShowDetails")
end
